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
from undetected_playwright import Malenia
import httpx

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
                 flaresolverr_url: str = 'http://localhost:8191/v1',
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
        self.logger = logger or logging.getLogger(__name__)
        self.flaresolverr_url = flaresolverr_url

    def get_indeed_job_key(self, url: str) -> str:
        """Extract job key from an Indeed URL."""
        import re
        match = re.search(r'clk\?jk=([^&]+)', url)
        return match.group(1) if match else None

    def send_flaresolverr_request(self, url: str):
        """Send a GET request with FlareSolverr using httpx"""
        # Basic header content type header
        r_headers = {"Content-Type": "application/json"}
        # Request payload
        payload = {
            "cmd": "request.get",
            "url": url,
            "maxTimeout": 60000
        }

        try:
            # Send the POST request using httpx
            with httpx.Client(timeout=60.0) as client:
                response = client.post(url=self.flaresolverr_url, headers=r_headers, json=payload)

                # Check if request was successful
                response.raise_for_status()

                # Parse the JSON response
                response_data = response.json()

                # Check if solution exists in the response
                if response_data.get('solution', {}).get('response'):
                    return response_data['solution']['response']

                self.logger.error(f"FlareSolverr failed to bypass URL: {url}")
                return None

        except httpx.RequestError as e:
            self.logger.error(f"Error sending request to FlareSolverr: {e}")
            return None
        except json.JSONDecodeError as e:
            self.logger.error(f"Error parsing FlareSolverr response: {e}")
            return None

    def run(self):
        """Modified run method to use FlareSolverr"""
        with sync_playwright() as p:
            for start in range(40, self.max_pages * 10, 10):
                # Use FlareSolverr to get the page content
                page_url = f"{self.user_input.url}&start={start}"
                flaresolverr_content = self.send_flaresolverr_request(page_url)

                if not flaresolverr_content:
                    self.logger.error(f"❌ Failed to retrieve content for {page_url}")
                    continue

                browser, page = self.launch_stealth_browser(p)

                try:
                    # Instead of page.goto(), set the content directly
                    page.set_content(flaresolverr_content)
                    time.sleep(random.uniform(1, 3))

                    # Rest of the existing processing logic remains the same
                    job_links = self.extract_job_links(page)

                    if not job_links:
                        self.logger.error("❌ No job links found")
                        browser.close()
                        break

                    # Process job links as before
                    for job_url in job_links:
                        self.process_job(job_url, browser)

                except Exception as e:
                    self.logger.error(f"❌ Error on page {start}: {e}")
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

    def generate_bezier_curve(self, points, steps):
        """Generate a smooth bezier curve path for mouse movement"""
        n = len(points) - 1
        result = []
        for t in range(steps):
            t = t / (steps - 1)
            x = y = 0
            for i, point in enumerate(points):
                coefficient = math.comb(n, i) * (1 - t) ** (n - i) * t ** i
                x += coefficient * point[0]
                y += coefficient * point[1]
            result.append((x, y))
        return result

    def move_mouse_smoothly(self, page, end_x, end_y):
        """Move mouse in a human-like curved path"""
        # Start from a random position
        start_x = random.randint(0, page.viewport_size()['width'])
        start_y = random.randint(0, page.viewport_size()['height'])

        # Generate control points for the curve
        control_points = [
            (start_x, start_y),
            (start_x + (end_x - start_x) * 0.4, start_y + (end_y - start_y) * 0.2),
            (start_x + (end_x - start_x) * 0.6, start_y + (end_y - start_y) * 0.8),
            (end_x, end_y)
        ]

        # Generate path points
        path = self.generate_bezier_curve(control_points, steps=50)

        # Move the mouse along the path
        for x, y in path:
            page.mouse.move(x, y)
            time.sleep(random.uniform(0.001, 0.002))  # Subtle speed variations

    def handle_verification(self, page):
        """Handle 'Verify Human' button with screenshots at each step"""
        try:
            os.makedirs('screenshots', exist_ok=True)
            page.screenshot(path='screenshots/1_initial_page.png')
            print("📸 Captured initial page state")

            # First try to find the iframe
            iframe_selector = 'iframe[title*="challenge"]'
            try:
                iframe = page.wait_for_selector(iframe_selector, timeout=5000)
                if iframe:
                    frame = iframe.content_frame()
                    if frame:
                        print("Found challenge iframe")
                        # Try clicking in the iframe
                        checkbox = frame.wait_for_selector('input[type="checkbox"]', timeout=5000)
                        if checkbox:
                            box = checkbox.bounding_box()
                            if box:
                                # Move to and click checkbox
                                self.move_mouse_smoothly(frame,
                                                         box['x'] + box['width'] / 2,
                                                         box['y'] + box['height'] / 2)
                                checkbox.click()
                                time.sleep(3)
                                return True
            except Exception as e:
                print(f"No iframe found, trying direct selectors: {e}")

            # Try regular selectors if iframe approach fails
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
                        print(f"🔍 Found verification button with selector: {selector}")
                        box = verify_button.bounding_box()
                        if box:
                            # Move mouse smoothly to button
                            self.move_mouse_smoothly(page,
                                                     box['x'] + box['width'] / 2,
                                                     box['y'] + box['height'] / 2)

                            # Additional random movements near button
                            for _ in range(random.randint(2, 4)):
                                offset_x = random.uniform(-20, 20)
                                offset_y = random.uniform(-20, 20)
                                page.mouse.move(
                                    box['x'] + box['width'] / 2 + offset_x,
                                    box['y'] + box['height'] / 2 + offset_y
                                )
                                time.sleep(random.uniform(0.1, 0.3))

                            # Final click
                            verify_button.click(delay=random.uniform(50, 150))
                            time.sleep(random.uniform(2, 4))
                            page.wait_for_load_state('networkidle', timeout=10000)
                            return True
                except Exception as e:
                    print(f"⚠️ Error with selector {selector}: {e}")

            return False

        except Exception as e:
            print(f"❌ Error in verification handling: {e}")
            page.screenshot(path='screenshots/error_state.png')
            return False

    def launch_stealth_browser(self, playwright):
        """Launch a stealth browser using Malenia's stealth techniques"""
        browser = playwright.chromium.launch(
            headless=False,
            args=[
                "--start-maximized",
                "--enable-webgl",
                "--window-size=1920,1080",
                "--no-sandbox",
            ],

        )

        context = browser.new_context(
            user_agent=random.choice(user_agents),
            viewport={'width': 1920, 'height': 1080},
            screen={'width': 1920, 'height': 1080},
            java_script_enabled=True,
            locale='en-US',
            timezone_id='America/Chicago'
        )

        Malenia.apply_stealth(context)
        page = context.new_page()


        return browser, page

    def extract_job_links(self, page):
        """Extract all job URLs from the main listing page."""
        job_links = []
        try:
            # page.wait_for_selector('a.jcs-JobTitle.css-1baag51.eu4oa1w0', timeout=15000)
            page.wait_for_selector('a.jcs-JobTitle.css-1baag51.eu4oa1w0', timeout=15000000)
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
        try:
            context = browser.new_context(
                user_agent=random.choice(user_agents),
                viewport={'width': 1920, 'height': 1080},
                screen={'width': 1920, 'height': 1080}
            )
            Malenia.apply_stealth(context)  # Use Malenia instead of stealth_sync
            page = context.new_page()
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
