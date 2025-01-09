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
import math
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


class IndeedScraperEnhanced:
    def __init__(self, user_input: UserInput,
                 flaresolverr_url: Optional[str] = None,
                 max_pages: int = 10,
                 existing_urls: Optional[set] = None,
                 job_source: Optional[JobSource] = None,
                 job_category: Optional[JobCategory] = None,
                 db_manager=None,
                 logger=None):
        # Retrieve FlareSolverr URL from environment or use provided/default value
        self.flaresolverr_url = flaresolverr_url or os.environ.get(
            'FLARESOLVERR_URL',
            'http://flaresolverr:8191/v1'  # Use service name in Docker network
        )

        # Rest of the initialization remains the same
        self.user_input = user_input
        self.max_pages = max_pages
        self.job_source = job_source
        self.job_category = job_category
        self.jobs_processed = 0
        self.db_manager = db_manager
        self.logger = logger or logging.getLogger(__name__)

    def is_cloudflare_blocked(self, response):
        """
        Detect Cloudflare blocking attempts

        Args:
            response: httpx response object

        Returns:
            bool: True if Cloudflare blocking is detected, False otherwise
        """
        # Check response headers
        headers = response.headers
        body_text = response.text.lower()

        cloudflare_indicators = [
            # Header-based checks
            'cf-ray' in headers,
            headers.get('server', '').lower() == 'cloudflare',
            any('__cfuid' in cookie for cookie in headers.get('set-cookie', '')),

            # Body text checks
            'attention required!' in body_text,
            'cloudflare ray id:' in body_text,
            'ddos protection by cloudflare' in body_text,
            'challenge-platform/h/g/challenge-platform' in body_text,
            'cloudflare error 500s box' in body_text,
            'just a moment...' in body_text,
            'challenge is required' in body_text
        ]

        # If any indicator is True, log details
        if any(cloudflare_indicators):
            self.logger.warning("🚫 Cloudflare blocking detected!")

            # Detailed logging
            if 'cf-ray' in headers:
                self.logger.warning(f"CF-Ray Header: {headers.get('cf-ray')}")

            if headers.get('server', '').lower() == 'cloudflare':
                self.logger.warning("Cloudflare server header detected")

            # Screenshot mechanism (if possible in this context)
            try:
                os.makedirs('cloudflare_blocks', exist_ok=True)
                timestamp = time.strftime("%Y%m%d_%H%M%S")
                block_file = f'cloudflare_blocks/cloudflare_block_{timestamp}.txt'
                with open(block_file, 'w', encoding='utf-8') as f:
                    f.write("Cloudflare Block Detected\n\n")
                    f.write("Headers:\n")
                    f.write(json.dumps(dict(headers), indent=2))
                    f.write("\n\nBody:\n")
                    f.write(body_text[:2000])  # Limit body to first 2000 characters
            except Exception as e:
                self.logger.error(f"Error logging Cloudflare block: {e}")

            return True

        return False

    def send_flaresolverr_request(self, url: str, max_retries: int = 3):
        """Send a GET request with FlareSolverr using httpx with extensive error handling"""
        r_headers = {"Content-Type": "application/json"}
        payload = {
            "cmd": "request.get",
            "url": url,
            "maxTimeout": 180000,  # 3 minutes
            "returnOnlySolution": False,
            "sessions": True
        }

        for attempt in range(max_retries):
            try:
                # Extensive logging
                self.logger.info(f"FlareSolverr URL: {self.flaresolverr_url}")
                self.logger.info(f"Payload: {json.dumps(payload)}")

                # Try multiple connection methods based on the configured URL
                connection_methods = [
                    self.flaresolverr_url,
                    'http://localhost:8191/v1',
                    'http://127.0.0.1:8191/v1',
                    'http://flaresolverr:8191/v1'
                ]

                last_error = None
                for connection_url in connection_methods:
                    try:
                        # Use explicit timeout parameters
                        with httpx.Client(
                                timeout=httpx.Timeout(
                                    connect=30.0,  # Connection timeout
                                    read=180.0,  # Read timeout
                                    write=30.0,  # Write timeout
                                    pool=60.0  # Pool timeout
                                )
                        ) as client:
                            response = client.post(
                                url=connection_url,
                                headers=r_headers,
                                json=payload,
                                follow_redirects=True
                            )

                            # Log connection details
                            self.logger.info(f"Using connection URL: {connection_url}")
                            self.logger.info(f"Response status: {response.status_code}")

                            response.raise_for_status()

                            response_data = response.json()

                            # Validate response
                            if response_data.get('solution', {}).get('response'):
                                return response_data['solution']['response']

                            self.logger.warning(f"Invalid response from {connection_url}: {response_data}")

                    except Exception as conn_error:
                        self.logger.error(f"Error with {connection_url}: {conn_error}")
                        last_error = conn_error

                # If all connection methods fail
                if last_error:
                    raise last_error

            except Exception as e:
                self.logger.error(f"FlareSolverr request error (attempt {attempt + 1}): {e}")
                time.sleep(30 * (attempt + 1))

        self.logger.error("All FlareSolverr attempts failed")
        return None

    def launch_stealth_browser(self, playwright, headless=True):
        """Launch a stealth browser with enhanced Chromium stealth settings."""
        browser = playwright.chromium.launch(
            headless=headless,
            args=[
                "--disable-blink-features=AutomationControlled",
                "--no-sandbox",
                "--disable-setuid-sandbox",
                "--disable-dev-shm-usage",
                "--disable-accelerated-2d-canvas",
                "--no-first-run",
                "--disable-gpu",
                "--window-size=1920,1080"
            ]
        )

        context = browser.new_context(
            user_agent=random.choice(user_agents),
            viewport={'width': 1920, 'height': 1080},
            java_script_enabled=True,
            permissions=["clipboard-read"],
            has_touch=False,
            is_mobile=False,
            color_scheme='light',
            locale='en-US',
            timezone_id='America/Chicago'
        )
        page = context.new_page()
        stealth_sync(page)
        return browser, page

    def generate_bezier_curve(self, start_x, start_y, end_x, end_y, control_points=2):
        """Generate points along a bezier curve for natural mouse movement."""
        points = [(start_x, start_y)]

        # Generate random control points
        for _ in range(control_points):
            points.append((
                start_x + random.uniform(0, end_x - start_x),
                start_y + random.uniform(0, end_y - start_y)
            ))
        points.append((end_x, end_y))

        return points

    def move_mouse_naturally(self, page, end_x, end_y):
        """Move mouse in a natural curve to target coordinates."""
        current_x = random.randint(100, 800)  # Random start position
        current_y = random.randint(100, 600)

        points = self.generate_bezier_curve(current_x, current_y, end_x, end_y)
        steps = random.randint(25, 40)

        for i in range(steps):
            t = i / steps
            x = y = 0
            n = len(points) - 1

            for j, point in enumerate(points):
                coefficient = math.comb(n, j) * (1 - t) ** (n - j) * t ** j
                x += coefficient * point[0]
                y += coefficient * point[1]

            page.mouse.move(x, y)
            time.sleep(random.uniform(0.008, 0.015))  # Subtle speed variations

    def handle_verification(self, page):
        """Handle 'Verify Human' button with screenshots at each step"""
        try:
            # Create screenshots directory if it doesn't exist
            os.makedirs('screenshots', exist_ok=True)

            # Take initial page screenshot
            page.screenshot(path='screenshots/1_initial_page.png')
            print("📸 Captured initial page state")

            # List of verification selectors
            verify_selectors = [
                "button[value='Verify you are human']",
                "input[value='Verify you are human']",
                "#challenge-button",
                "[data-action='verify']"
            ]

            for selector in verify_selectors:
                try:
                    # Wait briefly for the selector
                    verify_button = page.wait_for_selector(selector, timeout=5000)
                    if verify_button:
                        print(f"🔍 Found verification button with selector: {selector}")

                        # Take screenshot before any interaction
                        page.screenshot(path='screenshots/2_found_button.png')
                        print("📸 Captured verification button state")

                        # Get button position
                        box = verify_button.bounding_box()
                        if box:
                            # Mark the button location with a red dot
                            page.evaluate("""(x, y) => {
                                const dot = document.createElement('div');
                                dot.style.position = 'absolute';
                                dot.style.left = (x - 5) + 'px';
                                dot.style.top = (y - 5) + 'px';
                                dot.style.width = '10px';
                                dot.style.height = '10px';
                                dot.style.backgroundColor = 'red';
                                dot.style.borderRadius = '50%';
                                dot.style.zIndex = '10000';
                                document.body.appendChild(dot);
                            }""", box['x'] + box['width'] / 2, box['y'] + box['height'] / 2)

                            # Take screenshot with the red dot
                            page.screenshot(path='screenshots/3_marked_button.png')
                            print("📸 Captured marked verification button")

                            # Move mouse to button naturally
                            page.mouse.move(
                                box['x'] + box['width'] / 2 + random.uniform(-10, 10),
                                box['y'] + box['height'] / 2 + random.uniform(-10, 10),
                                steps=random.randint(10, 20)
                            )

                            time.sleep(random.uniform(0.5, 1.0))

                            # Click the button
                            verify_button.click()
                            print("🖱️ Clicked verification button")

                            time.sleep(random.uniform(2, 4))

                            # Take screenshot after clicking
                            page.screenshot(path='screenshots/4_after_click.png')
                            print("📸 Captured post-click state")

                            # Wait for page to load after verification
                            page.wait_for_load_state('networkidle', timeout=10000)
                            return True
                except Exception as e:
                    print(f"⚠️ Error with selector {selector}: {e}")
                    continue

            # Take screenshot if no button found
            page.screenshot(path='screenshots/no_button_found.png')
            print("📸 Captured page state (no button found)")
            return False

        except Exception as e:
            print(f"❌ Error in verification handling: {e}")
            # Take error state screenshot
            page.screenshot(path='screenshots/error_state.png')
            print("📸 Captured error state")
            return False

    def run(self):
        with sync_playwright() as p:
            os.makedirs('screenshots', exist_ok=True)
            for start in range(0, self.max_pages * 10, 10):
                browser, page = self.launch_stealth_browser(p, headless=False)
                page_url = f"{self.user_input.url}&start={start}"
                self.logger.info(f"🌐 Navigating to page {start // 10 + 1}")

                try:
                    # Try FlareSolverr first with extended timeout
                    flaresolverr_content = self.send_flaresolverr_request(page_url)

                    if not flaresolverr_content:
                        self.logger.warning("FlareSolverr failed, falling back to direct navigation")
                        page.goto(page_url, timeout=60000)
                    else:
                        page.set_content(flaresolverr_content)
                    # Set the content from FlareSolverr instead of navigating

                    page.wait_for_load_state('networkidle', timeout=10000)

                    # Take initial screenshot
                    page.screenshot(path='screenshots/1_initial_page.png')
                    self.logger.info("📸 Initial page screenshot captured")

                    # Handle verification if needed
                    time.sleep(2)
                    verification_result = self.handle_verification(page)
                    if verification_result:
                        self.logger.info("✅ Verification challenge handled")
                        page.screenshot(path='screenshots/5_post_verification.png')
                    else:
                        self.logger.info("ℹ️ No verification needed or verification failed")

                    # Extract job links
                    job_links = self.extract_job_links(page)

                    if not job_links:
                        self.logger.error("❌ No job links found")
                        page.screenshot(path='screenshots/indeed_no_links.png')
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
                    self.logger.error(f"❌ Error on page {start}: {e}")
                    page.screenshot(path='screenshots/error_state.png')
                finally:
                    browser.close()
                    time.sleep(random.uniform(2, 5))

    def get_indeed_job_key(self, url: str) -> str:
        """Extract job key from an Indeed URL."""
        import re
        match = re.search(r'clk\?jk=([^&]+)', url)
        return match.group(1) if match else None

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
        """Handle Cloudflare verification with immediate visual marker and retry logic"""
        try:
            self.logger.info(f"Current working directory: {os.getcwd()}")
            os.makedirs('screenshots', exist_ok=True)

            for attempt in range(3):  # Try 3 refresh attempts
                self.logger.info(f"Refresh attempt {attempt + 1} of 3")

                # Take initial screenshot for this attempt
                screenshot_path1 = os.path.join(os.getcwd(), 'screenshots',
                                                f'1_before_verification_attempt_{attempt + 1}.png')
                page.screenshot(path=screenshot_path1)
                self.logger.info(f"Screenshot 1 saved for attempt {attempt + 1}")

                # Add red dot marker
                page_viewport = page.viewport_size
                self.logger.info(f"Viewport size: {page_viewport}")
                estimated_x = (page_viewport['width'] / 2) - 122
                estimated_y = (page_viewport['height'] * 0.17)
                self.logger.info(f"Estimated coordinates: x={estimated_x}, y={estimated_y}")

                # Add red dot
                js_code = """({ x, y }) => {
                    const dot = document.createElement('div');
                    dot.style.position = 'fixed';
                    dot.style.left = (x - 5) + 'px';
                    dot.style.top = (y - 5) + 'px';
                    dot.style.width = '10px';
                    dot.style.height = '10px';
                    dot.style.backgroundColor = 'red';
                    dot.style.borderRadius = '50%';
                    dot.style.zIndex = '2147483647';
                    document.body.appendChild(dot);
                }"""
                page.evaluate(js_code, {'x': estimated_x, 'y': estimated_y})

                # Take screenshot with marker
                screenshot_path2 = os.path.join(os.getcwd(), 'screenshots',
                                                f'2_estimated_location_attempt_{attempt + 1}.png')
                page.screenshot(path=screenshot_path2)
                self.logger.info(f"Screenshot 2 saved for attempt {attempt + 1}")

                # Multiple clicks per refresh attempt
                num_clicks = random.randint(3, 5)
                for click_num in range(num_clicks):
                    self.logger.info(f"Click {click_num + 1} of {num_clicks} in attempt {attempt + 1}")

                    # Move mouse naturally to the target
                    self.move_mouse_naturally(page, estimated_x, estimated_y)
                    time.sleep(random.uniform(0.5, 1.0))

                    # Click with force and delay
                    page.mouse.click(estimated_x, estimated_y, delay=random.uniform(50, 150))
                    self.logger.info(f"Clicked at x={estimated_x}, y={estimated_y}")
                    time.sleep(3)  # Longer wait between clicks

                    # Take screenshot after each click
                    screenshot_path3 = os.path.join(os.getcwd(), 'screenshots',
                                                    f'3_after_click_{click_num + 1}_attempt_{attempt + 1}.png')
                    page.screenshot(path=screenshot_path3)
                    self.logger.info(f"Screenshot saved after click {click_num + 1}")

                # Longer wait after all clicks
                time.sleep(10)  # Wait longer to see if verification worked

                # Take final screenshot for this attempt
                page.screenshot(path=f'screenshots/4_post_wait_attempt_{attempt + 1}.png')

                if attempt < 2:  # Don't refresh on the last attempt
                    self.logger.info(f"Refreshing page for attempt {attempt + 2}")
                    page.reload()
                    time.sleep(5)  # Longer wait after refresh

            self.logger.info("Completed all 3 attempts")
            return False

        except Exception as e:
            print(f"Verification error: {e}")
            page.screenshot(path='screenshots/error_state.png')
            return False

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
    batch_scraper = IndeedScraperEnhanced(batch_input)
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
