import os
import random
from urllib.parse import urljoin
from playwright.sync_api import sync_playwright
from playwright_stealth import stealth_sync
from dataclasses import dataclass
import json
import time
from typing import Optional
from pathlib import Path
from dotenv import load_dotenv
from app.models.job import JobSource, JobCategory
from app.crud.job_queries import find_builtinchicago_duplicates_batch
import logging
import re
import httpx
import math


PROJECT_ROOT = Path(__file__).parent.parent
load_dotenv(dotenv_path=PROJECT_ROOT / '.env')

user_agents = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Edge/120.0.0.0",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Safari/605.1.15",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0",
]

@dataclass
class UserInput:
    method: str
    url: str

class BuiltInChicagoScraper:
    def __init__(self, user_input: UserInput, max_pages: int = 10,
                 skip_existing: bool = False,
                 job_source: Optional[JobSource] = None,
                 job_category: Optional[JobCategory] = None,
                 db_manager=None,
                 logger=None):
        self.user_input = user_input
        self.max_pages = max_pages
        self.job_source = job_source
        self.job_category = job_category
        self.jobs_processed = 0
        self.db_manager = db_manager
        self.skip_existing = skip_existing
        self.existing_urls = self.load_existing_job_urls() if skip_existing else set()
        self.base_url = "https://builtin.com"
        self.logger = logger or logging.getLogger(__name__)
        self.flaresolverr_url = os.getenv("FLARESOLVERR_URL", "http://localhost:8191/v1")

        # Clear the output file if we're not skipping existing
        if not skip_existing:
            output_file = '../data/output_builtin_jobs.json'
            if os.path.exists(output_file):
                os.remove(output_file)
                print("🗑️ Cleared existing output file")

    def send_flaresolverr_request(self, url: str, max_retries=3):
        """Send FlareSolverr request with retries"""
        for attempt in range(max_retries):
            try:
                if attempt > 0:
                    time.sleep(random.uniform(2, 5))

                self.logger.info(f"FlareSolverr attempt {attempt + 1}/{max_retries} for URL: {url}")

                r_headers = {"Content-Type": "application/json"}
                payload = {
                    "cmd": "request.get",
                    "url": url,
                    "maxTimeout": 180000
                }

                with httpx.Client(timeout=180.0) as client:
                    response = client.post(
                        url=self.flaresolverr_url,
                        headers=r_headers,
                        json=payload
                    )

                    response.raise_for_status()
                    response_data = response.json()

                    if response_data.get('solution', {}).get('response'):
                        return response_data['solution']['response']

                    self.logger.warning(f"FlareSolverr returned no solution on attempt {attempt + 1}")

            except httpx.RequestError as e:
                self.logger.error(f"FlareSolverr request error on attempt {attempt + 1}: {e}")
            except json.JSONDecodeError as e:
                self.logger.error(f"FlareSolverr JSON parse error on attempt {attempt + 1}: {e}")
            except Exception as e:
                self.logger.error(f"FlareSolverr unexpected error on attempt {attempt + 1}: {e}")

        self.logger.error(f"❌ FlareSolverr failed after {max_retries} attempts")
        return None

    def get_builtinchicago_job_id(self, url: str) -> str:
        """Extract the job ID from a BuiltIn job URL"""
        match = re.search(r'/(\d+)$', url)
        return match.group(1) if match else url

    def load_existing_job_urls(self) -> set:
        existing_urls = set()
        output_file = '../data/output_builtin_jobs.json'

        try:
            if os.path.exists(output_file):
                with open(output_file, 'r', encoding='utf-8') as f:
                    for line in f:
                        try:
                            job_entry = json.loads(line.strip())
                            existing_urls.add(job_entry.get('job_url'))
                        except json.JSONDecodeError:
                            continue
                print(f"✅ Loaded {len(existing_urls)} existing job URLs")

                # Print the first few existing URLs for verification
                print("📋 Sample of existing URLs:")
                for url in list(existing_urls)[:3]:
                    print(f"   - {url}")
            else:
                print("ℹ️ No existing output file found, starting fresh")
        except Exception as e:
            print(f"⚠️ Error loading existing jobs: {e}")

        return existing_urls

    def create_context(self, browser):
        context = browser.new_context(
            user_agent=random.choice(user_agents),
            viewport={'width': 1920, 'height': 1080},
            screen={'width': 1920, 'height': 1080},
            java_script_enabled=True,
            locale='en-US',
            timezone_id='America/Chicago'
        )
        return context

    def scroll_page(self, page):
        """Scroll the page to load all job listings."""
        try:
            # Initial wait for content
            page.wait_for_selector('h2.fw-extrabold a[data-id="job-card-title"]', timeout=30000)

            # Get initial job count
            initial_jobs = len(page.query_selector_all('h2.fw-extrabold a[data-id="job-card-title"]'))

            last_jobs_count = 0
            scroll_attempts = 0
            max_attempts = 2

            while scroll_attempts < max_attempts:
                # Scroll to bottom
                page.evaluate('window.scrollTo(0, document.body.scrollHeight)')
                time.sleep(2)  # Wait for content to load

                # Get current job count
                current_jobs = len(page.query_selector_all('h2.fw-extrabold a[data-id="job-card-title"]'))

                print(f"Found {current_jobs} jobs...")

                # If no new jobs loaded after scrolling, try a few more times then break
                if current_jobs == last_jobs_count:
                    scroll_attempts += 1
                else:
                    scroll_attempts = 0  # Reset counter if we found new jobs

                last_jobs_count = current_jobs

                # Additional random scroll up and down to trigger lazy loading
                if scroll_attempts > 5:
                    page.evaluate('window.scrollTo(0, document.body.scrollHeight * 0.8)')
                    time.sleep(1)
                    page.evaluate('window.scrollTo(0, document.body.scrollHeight)')
                    time.sleep(1)

            print(f"✅ Finished scrolling, found {last_jobs_count} total jobs")

        except Exception as e:
            print(f"❌ Error during scrolling: {e}")

    def extract_job_links(self, page) -> list:
        job_links = []
        try:
            # Wait for job cards and scroll the page
            self.scroll_page(page)

            # Extract job links using evaluate
            hrefs = page.evaluate("""
                () => Array.from(
                    document.querySelectorAll('h2.fw-extrabold a[data-id="job-card-title"]')
                ).map(a => a.getAttribute('href'))
            """)

            # Process the extracted URLs
            for i, href in enumerate(hrefs):
                if href:
                    full_url = urljoin(self.base_url, href)
                    job_links.append(full_url)
                    print(f"🔗 Job Link {i + 1}: {full_url}")

            print(f"✅ Extracted {len(job_links)} job links")

        except Exception as e:
            print(f"❌ Error extracting job links: {e}")
            try:
                os.makedirs('error_screenshots', exist_ok=True)
                page.screenshot(path='error_screenshots/link_extraction_error.png')
            except Exception as screenshot_error:
                print(f"Failed to take error screenshot: {screenshot_error}")

        return job_links

    def extract_salary_info(self, description: str) -> Optional[str]:
        description_lower = description.lower()
        salary_text = None

        salary_indicators = ['salary', 'compensation', 'pay range', 'salary range']
        for indicator in salary_indicators:
            if indicator in description_lower:
                sentences = description.split('.')
                for sentence in sentences:
                    if indicator in sentence.lower():
                        salary_text = sentence.strip()
                        break
                if salary_text:
                    break

        return salary_text

    def get_job_details(self, page, job_url):
        try:
            page.wait_for_selector('script[type="application/ld+json"]',
                                   state='attached',  # Don't require visibility
                                   timeout=30000)

            # Extract location first
            location_raw = None
            try:
                # Wait for the map icon
                page.wait_for_selector('i.fa-regular.fa-map-location-dot', state='attached', timeout=5000)

                # Get the parent div that contains both the icon and the location text
                location_element = page.evaluate('''
                    () => {
                        const icon = document.querySelector('i.fa-regular.fa-map-location-dot');
                        if (icon) {
                            // Navigate up to find the parent container and then find the text div
                            const container = icon.closest('.d-flex.align-items-start.gap-sm');
                            if (container) {
                                const textDiv = container.querySelector('.text-gray-03');
                                return textDiv ? textDiv.textContent.trim() : null;
                            }
                        }
                        return null;
                    }
                ''')

                if location_element:
                    # Remove "HQ:" prefix if present
                    location_raw = location_element.replace('HQ:', '').strip()
                    print(f"📍 Location found: {location_raw}")

            except Exception as e:
                print(f"Warning: Could not extract location: {e}")

            json_ld_data = page.evaluate('''
                () => {
                    const script = document.querySelector('script[type="application/ld+json"]');
                    return script ? JSON.parse(script.textContent) : null;
                }
            ''')

            if not json_ld_data:
                print("No JSON-LD data found")
                return None

            job_posting = None
            if '@graph' in json_ld_data:
                for item in json_ld_data['@graph']:
                    if item.get('@type') == 'JobPosting':
                        job_posting = item
                        break
            else:
                job_posting = json_ld_data if json_ld_data.get('@type') == 'JobPosting' else None

            if not job_posting:
                print("No JobPosting data found")
                return None

            description = job_posting.get('description', '')
            salary_text = self.extract_salary_info(description)

            # Add location to the job_posting if found
            if location_raw:
                if not job_posting.get('jobLocation'):
                    job_posting['jobLocation'] = {}
                if not job_posting['jobLocation'].get('address'):
                    job_posting['jobLocation']['address'] = {}
                job_posting['jobLocation']['address']['addressLocality'] = location_raw

            return {
                'json_ld': job_posting,
                'salary_text': salary_text,
            }

        except Exception as e:
            print(f"❌ Error getting job details for {job_url}: {e}")
            return None

    def process_job(self, browser, job_url):
        """Process individual job URLs using FlareSolverr."""
        if job_url in self.existing_urls:
            print(f"⏭️ Skipping existing job: {job_url}")
            return

        context = None
        try:
            # Get job details using FlareSolverr
            flaresolverr_content = self.send_flaresolverr_request(job_url)
            if not flaresolverr_content:
                self.logger.error(f"❌ Failed to retrieve content for job: {job_url}")
                return

            context = self.create_context(browser)
            page = context.new_page()
            stealth_sync(page)

            try:
                page.set_content(flaresolverr_content, timeout=60000)
            except Exception:
                page.goto('about:blank')
                time.sleep(2)
                page.set_content(flaresolverr_content, timeout=120000)

            page.wait_for_load_state('networkidle', timeout=30000)
            time.sleep(2)

            job_details = self.get_job_details(page, job_url)
            if job_details:
                job_data = {
                    "job_url": job_url,
                    "raw_content": json.dumps(job_details),
                    "source": self.job_source,
                    "job_category": self.job_category,
                    "processed": False,
                    "salary_text": job_details.get("salary_text"),
                }

                if self.db_manager and self.db_manager.save_raw_job(job_data):
                    self.jobs_processed += 1
                    self.logger.info(f"✅ Saved job {self.jobs_processed}: {job_url}")

        except Exception as e:
            print(f"❌ Error processing job {job_url}: {e}")
        finally:
            if context:
                context.close()

    def run(self):
        """Main scraping method using FlareSolverr."""
        with sync_playwright() as p:
            browser = None
            try:
                browser = p.chromium.launch(
                    headless=True,
                    args=["--start-maximized", "--enable-webgl", "--no-sandbox"]
                )

                for page_num in range(1, self.max_pages + 1):
                    context = None
                    try:
                        # Use FlareSolverr to get the page content
                        page_url = f"{self.user_input.url}&page={page_num}"
                        flaresolverr_content = self.send_flaresolverr_request(page_url)

                        if not flaresolverr_content:
                            self.logger.error(f"❌ Failed to retrieve content for {page_url}")
                            continue

                        context = self.create_context(browser)
                        page = context.new_page()
                        stealth_sync(page)

                        try:
                            # Set content with increased timeout
                            page.set_content(flaresolverr_content, timeout=60000)
                        except Exception as content_error:
                            self.logger.warning(
                                f"Initial content setting failed, trying alternative approach: {content_error}")
                            page.goto('about:blank')
                            time.sleep(2)
                            page.set_content(flaresolverr_content, timeout=120000)

                        page.wait_for_load_state('networkidle', timeout=30000)
                        time.sleep(random.uniform(1, 3))

                        job_links = self.extract_job_links(page)
                        page.wait_for_timeout(1000)

                        if not job_links:
                            print(f"No job links found on page {page_num}")
                            if page_num == 1:
                                print("❌ No jobs found on first page, stopping")
                                break
                            continue

                        duplicate_keys = find_builtinchicago_duplicates_batch(self.db_manager.Session(), job_links)

                        for job_url in job_links:
                            job_key = self.get_builtinchicago_job_id(job_url)
                            if job_key in duplicate_keys:
                                self.logger.info(f"⏭️ Skipping duplicate job: {job_url}")
                                continue

                            # Process non-duplicate jobs with FlareSolverr
                            self.process_job(browser, job_url)
                            time.sleep(random.uniform(1, 3))

                    except Exception as e:
                        print(f"❌ Error on page {page_num}: {e}")
                        try:
                            os.makedirs('error_screenshots', exist_ok=True)
                            page.screenshot(path=f'error_screenshots/error_page_{page_num}.png')
                        except Exception as screenshot_error:
                            print(f"Failed to take error screenshot: {screenshot_error}")
                    finally:
                        if context:
                            context.close()
                        time.sleep(random.uniform(3, 4))

            finally:
                if browser:
                    browser.close()

def main():
    url = "https://builtin.com/jobs?search=data+engineer&city=Chicago&state=IL&country=USA"
    user_input = UserInput(method="scrape_webpage", url=url)

    # Create scraper with skip_existing=False to process all URLs
    scraper = BuiltInChicagoScraper(user_input, skip_existing=False)
    scraper.run()

if __name__ == "__main__":
    main()
