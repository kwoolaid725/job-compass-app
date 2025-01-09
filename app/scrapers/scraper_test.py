import argparse
import asyncio
import logging
import os
import random
import time
from dataclasses import dataclass
from typing import Optional
from playwright.async_api import async_playwright
from dotenv import load_dotenv

# Create logs directory if not exists
log_dir = "logs"
os.makedirs(log_dir, exist_ok=True)

# Configure logging
logging.basicConfig(
    filename=os.path.join(log_dir, 'scraper.log'),
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s',
)

logger = logging.getLogger("JobScraperLogger")
console_handler = logging.StreamHandler()
console_handler.setFormatter(logging.Formatter('%(asctime)s [%(levelname)s] %(message)s'))
logger.addHandler(console_handler)

load_dotenv()

USER_AGENTS = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Edge/120.0.0.0",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Safari/605.1.15",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0",
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
]
# Custom Exceptions
class RetryableError(Exception):
    """Custom exception for errors that should trigger a retry"""
    pass


class BrowserError(Exception):
    """Custom exception for browser-related errors"""
    pass


# Configuration Classes
@dataclass
class ScraperConfig:
    headless: bool = True
    max_retries: int = 3
    max_concurrent: int = 3
    requests_per_minute: int = 20
    max_pages: int = 10


@dataclass
class UserInput:
    method: str
    url: str
    category: Optional[str] = None
    email: str = os.getenv('LINKEDIN_EMAIL', '')
    password: str = os.getenv('LINKEDIN_PASSWORD', '')


# Core Components
class RateLimiter:
    def __init__(self, requests_per_minute: int):
        self.rate = requests_per_minute
        self.min_interval = 60.0 / requests_per_minute
        self.last_request = 0
        self.lock = asyncio.Lock()

    async def acquire(self):
        async with self.lock:
            now = time.time()
            time_since_last = now - self.last_request
            if time_since_last < self.min_interval:
                delay = self.min_interval - time_since_last
                await asyncio.sleep(delay)
            self.last_request = time.time()


class RequestQueue:
    def __init__(self, max_concurrent: int):
        self.queue = asyncio.Queue()
        self.max_concurrent = max_concurrent
        self.active_tasks = set()
        self.rate_limiter = RateLimiter(20)  # 20 requests per minute default

    async def add_request(self, url: str):
        await self.queue.put(url)

    async def process_queue(self, processor_func):
        while True:
            if len(self.active_tasks) >= self.max_concurrent:
                done, _ = await asyncio.wait(
                    self.active_tasks,
                    return_when=asyncio.FIRST_COMPLETED
                )
                self.active_tasks.difference_update(done)

            try:
                url = self.queue.get_nowait()
                await self.rate_limiter.acquire()
                task = asyncio.create_task(processor_func(url))
                self.active_tasks.add(task)
            except asyncio.QueueEmpty:
                if not self.active_tasks:
                    break
                await asyncio.wait(self.active_tasks)


class BrowserManager:
    def __init__(self, headless: bool = True):
        self.headless = headless
        self.playwright = None
        self.browser = None
        self.context = None
        self.page = None

    async def __aenter__(self):
        try:
            self.playwright = await async_playwright().start()
            self.browser = await self.playwright.chromium.launch(
                headless=self.headless,
                args=[
                    '--disable-gpu',
                    '--no-sandbox',
                    '--disable-setuid-sandbox',
                    '--disable-dev-shm-usage'
                ]
            )
            self.context = await self.browser.new_context(
                viewport={'width': 1920, 'height': 1080},
                user_agent=random.choice(USER_AGENTS)
            )
            self.page = await self.context.new_page()
            return self
        except Exception as e:
            logger.error(f"Failed to initialize browser: {e}")
            await self.cleanup()
            raise BrowserError(f"Browser initialization failed: {e}")

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        await self.cleanup()

    async def cleanup(self):
        try:
            if self.page:
                await self.page.close()
            if self.context:
                await self.context.close()
            if self.browser:
                await self.browser.close()
            if self.playwright:
                await self.playwright.stop()
        except Exception as e:
            logger.error(f"Error during browser cleanup: {e}")


class IndeedScraperImproved:
    def __init__(self, config: ScraperConfig, user_input: UserInput, db_manager=None):
        self.config = config
        self.user_input = user_input
        self.db_manager = db_manager
        self.request_queue = RequestQueue(config.max_concurrent)
        self.jobs_processed = 0

    async def handle_cloudflare(self, page):
        """Handle Cloudflare challenges"""
        try:
            # Wait for and handle Cloudflare challenge
            challenge_selectors = [
                "#challenge-running",
                "#challenge-form",
                "input[type='hidden'][name='cf_challenge_program']"
            ]

            for selector in challenge_selectors:
                try:
                    await page.wait_for_selector(selector, timeout=5000)
                    logger.info(f"Detected Cloudflare challenge: {selector}")
                    # Wait for challenge to complete
                    await page.wait_for_selector(selector, state="hidden", timeout=30000)
                except Exception:
                    continue

            await page.wait_for_load_state("networkidle", timeout=30000)
            return True
        except Exception as e:
            logger.error(f"Error handling Cloudflare: {e}")
            return False

    async def scrape_job_listing(self, url: str):
        """Scrape a single job listing with retries"""
        retries = 0
        while retries < self.config.max_retries:
            try:
                async with BrowserManager(self.config.headless) as browser:
                    await browser.page.goto(url)
                    if await self.handle_cloudflare(browser.page):
                        job_data = await self._extract_job_data(browser.page)
                        if job_data and self.validate_job_data(job_data):
                            await self.save_job_data(job_data)
                            return True
                    raise RetryableError("Failed to extract or validate job data")
            except Exception as e:
                logger.error(f"Error scraping {url} (attempt {retries + 1}): {e}")
                retries += 1
                if retries < self.config.max_retries:
                    delay = (2 ** retries) + random.uniform(0, 1)
                    await asyncio.sleep(delay)
        return False

    async def _extract_job_data(self, page):
        """Extract job data from the page"""
        try:
            # Wait for job title
            title_selector = "h1.jobsearch-JobInfoHeader-title"
            await page.wait_for_selector(title_selector)

            # Extract basic job information
            job_data = {
                'title': await page.text_content(title_selector),
                'company': await page.text_content(".jobsearch-InlineCompanyRating"),
                'location': await page.text_content(".jobsearch-JobInfoHeader-subtitle"),
                'description': await page.text_content("#jobDescriptionText"),
                'salary': await page.text_content(".jobsearch-JobMetadataHeader-item"),
                'url': page.url
            }

            return job_data
        except Exception as e:
            logger.error(f"Error extracting job data: {e}")
            return None

    def validate_job_data(self, data: dict) -> bool:
        """Validate extracted job data"""
        required_fields = ['title', 'company', 'description']
        return all(field in data and data[field] for field in required_fields)

    async def save_job_data(self, job_data: dict):
        """Save job data to database"""
        if self.db_manager:
            try:
                await self.db_manager.save_job(job_data)
                self.jobs_processed += 1
                logger.info(f"Saved job {self.jobs_processed}: {job_data['title']}")
            except Exception as e:
                logger.error(f"Error saving job data: {e}")

    async def run(self):
        """Main execution method"""
        try:
            logger.info(f"Starting scraper for URL: {self.user_input.url}")
            # Add initial job listing pages to queue
            for page_num in range(self.config.max_pages):
                url = f"{self.user_input.url}&start={page_num * 10}"
                await self.request_queue.add_request(url)

            # Process queue
            await self.request_queue.process_queue(self.scrape_job_listing)

            logger.info(f"Completed scraping. Processed {self.jobs_processed} jobs.")
        except Exception as e:
            logger.error(f"Error in main execution: {e}")
            raise


def parse_arguments():
    """Parse command line arguments"""
    parser = argparse.ArgumentParser(description='Enhanced Job Scraper')
    parser.add_argument('--category', type=str,
                        choices=['python_developer', 'data_engineer', 'data_scientist'],
                        help='Job category to scrape')
    parser.add_argument('--headless', action='store_true',
                        help='Run in headless mode')
    parser.add_argument('--max-pages', type=int, default=10,
                        help='Maximum number of pages to scrape')
    return parser.parse_args()


async def main():
    """Main entry point"""
    args = parse_arguments()

    # Define base URLs for different categories
    category_urls = {
        'python_developer': "https://www.indeed.com/jobs?q=python+developer&sort=date",
        'data_engineer': "https://www.indeed.com/jobs?q=data+engineer&sort=date",
        'data_scientist': "https://www.indeed.com/jobs?q=data+scientist&sort=date"
    }

    # Use default category if none specified
    category = args.category or 'python_developer'
    url = category_urls[category]

    # Create configurations
    config = ScraperConfig(
        headless=args.headless,
        max_pages=args.max_pages
    )

    user_input = UserInput(
        method="scrape_webpage",
        url=url,
        category=category
    )

    try:
        # Initialize and run scraper
        scraper = IndeedScraperImproved(config, user_input)
        await scraper.run()
    except Exception as e:
        logger.error(f"Scraper failed: {e}")
        raise


if __name__ == "__main__":
    asyncio.run(main())