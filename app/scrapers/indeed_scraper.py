import os
import random
from urllib.parse import urljoin
from playwright.sync_api import sync_playwright
from playwright_stealth import stealth_sync
from dataclasses import dataclass
import json
import time
from app.models.job import JobSource, JobCategory
from typing import Optional
from sqlalchemy.sql import text
import re
from app.crud.job_queries import find_indeed_duplicates_batch
import logging

# Enhanced User-Agents list
user_agents = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Edge/120.0.0.0",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Safari/605.1.15",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0",
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
]


@dataclass
class UserInput:
    method: str
    url: str


class IndeedScraper:
    def __init__(self, user_input: UserInput, max_pages: int = 10,
                 existing_urls: Optional[set] = None,
                 job_source: Optional[JobSource] = None,
                 job_category: Optional[JobCategory] = None,
                 db_manager=None,
                 logger=None):
        self.user_input = user_input
        self.max_pages = max_pages  # Max number of pages to scrape
        self.job_source = job_source
        self.job_category = job_category
        self.jobs_processed = 0
        self.db_manager = db_manager  # Database manager for DB access
        self.existing_urls = existing_urls if existing_urls is not None else self.load_existing_job_urls()
        self.logger = logger or logging.getLogger(__name__)  # Default to global logger if none passed

    def get_indeed_job_key(self, url: str) -> str:
        """Extract job key from an Indeed URL."""
        import re
        match = re.search(r'clk\?jk=([^&]+)', url)
        return match.group(1) if match else None


    def run(self):
        """Run the scraper and iterate over pages based on max_pages."""
        with sync_playwright() as p:
            for start in range(0, self.max_pages * 10, 10):
                browser, page = self.launch_stealth_browser(p)
                page_url = f"{self.user_input.url}&start={start}"
                self.logger.info(f"🌐 Navigating to page {start // 10 + 1}")

                try:
                    page.goto(page_url, timeout=60000)
                    time.sleep(random.uniform(1, 3))

                    if self.handle_verification(page):
                        print("✅ Verification completed")

                    job_links = self.extract_job_links(page)

                    if not job_links:
                        self.logger.error("❌ No job links found")
                        browser.close()
                        break

                    # Get duplicates for the current batch of job links
                    duplicate_keys = find_indeed_duplicates_batch(self.db_manager.Session(), job_links)

                    for job_url in job_links:
                        job_key = self.get_indeed_job_key(job_url)
                        if job_key in duplicate_keys:
                            self.logger.info(f"⏭️ Skipping duplicate job: {job_url}")
                            continue

                        # Process non-duplicate jobs
                        self.process_job(job_url, browser)

                except Exception as e:
                    self.logger.info(f"❌ Error on page {start}: {e}")
                finally:
                    browser.close()
                    time.sleep(random.uniform(2, 5))


    def load_existing_job_urls(self) -> set:
        """Load already scraped job URLs from the output file."""
        existing_urls = set()
        output_file = '../data/output_python_developer.json'

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
            else:
                print("ℹ️ No existing output file found, starting fresh")
        except Exception as e:
            print(f"⚠️ Error loading existing jobs: {e}")

        return existing_urls

    def clear_browser_data(self, context):
        """Clear browser cookies and cache."""
        context.clear_cookies()
        context.clear_permissions()
        time.sleep(random.uniform(1, 3))

    def simulate_human_behavior(self, page):
        """Simulate human-like behavior on the page."""
        # Random scrolling - Fixed with both x and y deltas
        page.mouse.wheel(
            delta_x=0,  # No horizontal scrolling
            delta_y=random.randint(300, 700)  # Vertical scroll amount
        )
        time.sleep(random.uniform(1, 2))

        # Random mouse movements
        for _ in range(random.randint(2, 4)):
            page.mouse.move(
                random.randint(100, 800),
                random.randint(100, 600)
            )
            time.sleep(random.uniform(0.5, 1.5))

    def handle_verification(self, page):
        """Handle 'Verify Human' button if it appears"""
        try:
            # Wait for verification button using multiple possible selectors
            verify_selectors = [
                "button[value='Verify you are human']",
                "input[value='Verify you are human']",
                "#challenge-button",
                "[data-action='verify']"
            ]

            for selector in verify_selectors:
                try:
                    verify_button = page.wait_for_selector(selector, timeout=5000)
                    if verify_button:
                        print("🤖 Found verification button, clicking...")
                        verify_button.click()
                        time.sleep(random.uniform(2, 4))
                        # Wait for page to load after verification
                        page.wait_for_load_state('networkidle', timeout=10000)
                        return True
                except:
                    continue

            return False
        except Exception as e:
            print(f"❌ Error handling verification: {e}")
            return False



    def launch_stealth_browser(self, playwright):
        """Launch a stealth browser with enhanced stealth settings."""
        browser = playwright.chromium.launch(
            headless=False,
            args=[
                "--start-maximized",
                "--enable-webgl",
                "--disable-blink-features=AutomationControlled",
                "--disable-blink-features",
                "--disable-infobars",
                "--window-size=1920,1080",
                "--no-sandbox",
                "--disable-web-security",
                "--disable-features=IsolateOrigins,site-per-process"
            ]
        )

        context = browser.new_context(
            user_agent=random.choice(user_agents),
            java_script_enabled=True,
            permissions=["clipboard-read"],
            viewport={'width': 1920, 'height': 1080},
            screen={'width': 1920, 'height': 1080},
            has_touch=False,
            is_mobile=False,
            color_scheme='light',
            locale='en-US',
            timezone_id='America/Chicago'
        )
        page = context.new_page()
        stealth_sync(page)
        return browser, page

    def extract_job_links(self, page):
        """Extract all job URLs from the main listing page."""
        job_links = []
        try:
            page.wait_for_selector('a.jcs-JobTitle.css-1baag51.eu4oa1w0', timeout=15000)
            self.simulate_human_behavior(page)  # Add random behavior before extraction
            anchors = page.query_selector_all('a.jcs-JobTitle.css-1baag51.eu4oa1w0')
            for i, anchor in enumerate(anchors):
                href = anchor.get_attribute('href')
                if href:
                    full_url = urljoin('https://www.indeed.com', href)
                    job_links.append(full_url)
                    self.logger.info(f"\U0001F517 Job Link {i + 1}: {full_url}")
                if i % 5 == 0:  # Add small delays during extraction
                    time.sleep(random.uniform(0.5, 1))
        except Exception as e:
            print(f"❌ Error extracting job links: {e}")
        self.logger.info(f"✅ Extracted {len(job_links)} job links")
        return job_links

    def process_batch(self, batch, browser):
        """Process a batch of job links with random delays."""
        for job_url in batch:
            if job_url in self.existing_urls:
                print(f"⏭️ Skipping already scraped job: {job_url}")
                continue

            time.sleep(random.uniform(1, 3))

            retries = 3
            while retries > 0:
                try:
                    print(f"\U0001F517 Processing job URL: {job_url} (Retries left: {retries})")
                    success = self.process_job_link(browser, job_url)
                    if success:
                        print(f"✅ Extracted job details from {job_url}")
                        self.existing_urls.add(job_url)
                        time.sleep(random.uniform(2, 5))
                        break
                    else:
                        print(f"⚠️ Failed to extract job details from {job_url}")
                except Exception as e:
                    print(f"❌ Error extracting job details from {job_url}: {e}")
                retries -= 1
                time.sleep(random.uniform(2, 5))
                if retries == 0:
                    print(f"❌ Gave up on job URL after 3 retries: {job_url}")

    def get_job_details(self, browser, job_url):
        """Extract job details with enhanced anti-blocking measures."""
        try:
            context = browser.new_context(
                user_agent=random.choice(user_agents),  # New user agent for each job
                viewport={'width': 1920, 'height': 1080},
                screen={'width': 1920, 'height': 1080}
            )
            page = context.new_page()
            stealth_sync(page)
            page.goto(job_url, timeout=30000)
            self.simulate_human_behavior(page)
            page.wait_for_load_state('networkidle', timeout=15000)
            time.sleep(random.uniform(2, 4))

            window_data = page.evaluate("() => window._initialData")

            salary_info = None
            try:
                salary_selectors = [
                    '.js-match-insights-provider-4pmm6z.e1wnkr790',
                    '[data-testid="salaryInfo"]',
                    '.salary-snippet-container',
                    '.salaryText',
                    '.jobsearch-JobMetadataHeader-item'
                ]

                for selector in salary_selectors:
                    try:
                        salary_element = page.wait_for_selector(selector, timeout=2000)
                        if salary_element:
                            salary_info = salary_element.inner_text()
                            print(f"\U0001F4B0 Found salary information using selector {selector}: {salary_info}")
                            break
                    except:
                        continue

            except Exception as e:
                print(f"⚠️ No salary information found in HTML: {e}")

            context.close()

            if window_data:
                return {
                    "hostQueryExecutionResult": window_data.get('hostQueryExecutionResult', {}),
                    "salary_html": salary_info
                }
        except Exception as e:
            print(f"❌ Failed to get job details from {job_url}: {e}")
        return None

    def save_to_file(self, job_url, host_query_execution_result):
        """Save the extracted fields from the job and hostQueryExecutionResult."""
        output_file = '../data/output_python_developer.json'

        job_entry = {
            "job_url": job_url,
            "host_query_execution_result": host_query_execution_result.get("hostQueryExecutionResult"),
            "salary_info": host_query_execution_result.get("salary_html")
        }

        try:
            with open(output_file, 'a', encoding='utf-8') as f:
                line = json.dumps(job_entry, ensure_ascii=False)
                f.write(line + "\n")
        except Exception as e:
            print(f"\u274C Failed to save data to output.json: {e}")

    def process_job_link(self, browser, job_url):
        """Process a single job link and extract job details."""
        try:
            details = self.get_job_details(browser, job_url)
            if details:
                if details.get('hostQueryExecutionResult') or details.get('salary_html'):
                    self.save_to_file(job_url, details)
                    return True
            return False
        except Exception as e:
            print(f"❌ Error processing job URL: {job_url} - {e}")
            return False

    def process_job(self, job_url, browser):
        """Process individual job URLs."""
        try:
            details = self.get_job_details(browser, job_url)
            if details and (details.get('hostQueryExecutionResult') or details.get('salary_html')):
                job_data = {
                    'job_url': job_url,
                    'raw_content': json.dumps({
                        'host_query_execution_result': details.get('hostQueryExecutionResult', {})
                    }),
                    'source': self.job_source,
                    'job_category': self.job_category,
                    'salary_text': details.get('salary_html')
                }

                if self.db_manager and self.db_manager.save_raw_job(job_data):
                    self.jobs_processed += 1
                    self.logger.info(f"✅ Saved job {self.jobs_processed}: {job_url}")

        except Exception as e:
            self.logger.error(f"❌ Error processing job {job_url}: {e}")


def main():
    """Example usage of both modes"""
    # Batch mode (original)
    batch_input = UserInput(method="scrape_webpage", url="https://www.indeed.com/jobs?q=python+developer")
    batch_scraper = IndeedScraper(batch_input)
    batch_scraper.run()

    # # Cron mode (new)
    # db_manager = DatabaseManager()
    # cron_input = UserInput(method="scrape_webpage", url="https://www.indeed.com/jobs?q=python+developer&sort=date")
    # cron_scraper = IndeedScraper(
    #     user_input=cron_input,
    #     db_manager=db_manager,
    #     job_source=JobSource.INDEED,
    #     job_category=JobCategory.PYTHON_DEVELOPER
    # )
    # cron_scraper.run_cron()

if __name__ == "__main__":
    main()
