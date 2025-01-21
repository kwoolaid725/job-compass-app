import os
import asyncio
import pyppeteer
from pyppeteer import launch
from pyppeteer_stealth import stealth
from dataclasses import dataclass
import json
import logging
from urllib.parse import urljoin
import nest_asyncio


@dataclass
class UserInput:
    method: str
    url: str


class IndeedScraper:
    def __init__(self, user_input: UserInput, max_pages: int = 10):
        self.user_input = user_input
        self.max_pages = max_pages
        self.logger = logging.getLogger(__name__)

    async def launch_browser(self):
        """Launch browser with enhanced stealth measures"""
        browser = await launch({
            'headless': False,
            'args': [
                '--no-sandbox',
                '--disable-setuid-sandbox',
                '--disable-infobars',
                '--window-size=1920,1080',
                '--disable-blink-features=AutomationControlled',
                '--disable-blink-features',
                '--disable-features=IsolateOrigins,site-per-process',
                '--allow-running-insecure-content',
                '--disable-web-security',
                '--disable-features=IsolateOrigins',
                '--disable-site-isolation-trials',
                '--ignore-certificate-errors',
                '--ignore-certificate-errors-spki-list',
            ],
            'ignoreHTTPSErrors': True,
            'userDataDir': './tmp/puppeteer_profile'
        })

        page = await browser.newPage()

        # Apply stealth first
        await stealth(page)

        # Additional Evasions
        await page.evaluateOnNewDocument('''() => {
            // Pass webdriver check
            Object.defineProperty(navigator, 'webdriver', {
                get: () => undefined
            });

            // Pass chrome check
            window.chrome = {
                runtime: {}
            };

            // Pass permissions check
            const originalQuery = window.navigator.permissions.query;
            window.navigator.permissions.query = parameters => (
                parameters.name === 'notifications' ?
                    Promise.resolve({ state: Notification.permission }) :
                    originalQuery(parameters)
            );

            // Overwrite the `plugins` property to use a custom getter
            Object.defineProperty(navigator, 'plugins', {
                get: () => [1, 2, 3, 4, 5]
            });

            // Overwrite the `languages` property
            Object.defineProperty(navigator, 'languages', {
                get: () => ['en-US', 'en']
            });

            // Pass webGL vendor check
            const getParameter = WebGLRenderingContext.getParameter;
            WebGLRenderingContext.prototype.getParameter = function(parameter) {
                if (parameter === 37445) {
                    return 'Intel Inc.';
                }
                if (parameter === 37446) {
                    return 'Intel Iris OpenGL Engine';
                }
                return getParameter(parameter);
            };
        }''')

        # Set viewport and user agent
        await page.setViewport({
            'width': 1920,
            'height': 1080
        })

        return browser, page

    async def handle_verification(self, page):
        """Basic verification handler"""
        try:
            # Try direct button click first
            button = await page.waitForSelector("[data-action='verify']", {'timeout': 5000})
            if button:
                await button.click()
                await page.waitForNavigation({'waitUntil': 'networkidle0'})
                return True
        except Exception as e:
            print(f"Verification error: {e}")
        return False

    async def extract_job_links(self, page):
        """Extract job links from page"""
        try:
            await page.waitForSelector('a.jcs-JobTitle', {'timeout': 15000})
            job_links = await page.evaluate('''() => {
                const anchors = document.querySelectorAll('a.jcs-JobTitle');
                return Array.from(anchors, a => a.href);
            }''')
            return job_links
        except Exception as e:
            print(f"Error extracting job links: {e}")
            return []

    async def get_job_details(self, browser, job_url):
        """Get basic job details"""
        try:
            page = await browser.newPage()
            await stealth(page)
            await page.goto(job_url, {'waitUntil': 'networkidle0'})

            # Get window data
            window_data = await page.evaluate('() => window._initialData')

            # Get salary if exists
            salary_info = None
            try:
                salary_element = await page.waitForSelector('.salary-snippet-container', {'timeout': 2000})
                if salary_element:
                    salary_info = await page.evaluate('element => element.innerText', salary_element)
            except:
                pass

            await page.close()

            return {
                "hostQueryExecutionResult": window_data.get('hostQueryExecutionResult', {}),
                "salary_html": salary_info
            }

        except Exception as e:
            print(f"Error getting job details: {e}")
        return None

    async def run(self):
        """Main scraping loop"""
        browser = None
        try:
            browser, page = await self.launch_browser()

            for start in range(0, self.max_pages * 10, 10):
                page_url = f"{self.user_input.url}&start={start}"
                print(f"Navigating to page {start // 10 + 1}")

                await page.goto(page_url, {'waitUntil': 'networkidle0'})

                # Handle verification if needed
                await self.handle_verification(page)

                # Get job links
                job_links = await self.extract_job_links(page)
                if not job_links:
                    print("No job links found")
                    break

                # Process each job
                for job_url in job_links:
                    details = await self.get_job_details(browser, job_url)
                    if details:
                        await self.save_job(job_url, details)

                await asyncio.sleep(2)  # Basic delay between pages

        except Exception as e:
            print(f"Error in main loop: {e}")
        finally:
            if browser:
                await browser.close()

    async def save_job(self, job_url, details):
        """Save job to file"""
        output_file = '../data/output_python_developer.json'

        job_entry = {
            "job_url": job_url,
            "host_query_execution_result": details.get("hostQueryExecutionResult"),
            "salary_info": details.get("salary_html")
        }

        try:
            os.makedirs(os.path.dirname(output_file), exist_ok=True)
            with open(output_file, 'a', encoding='utf-8') as f:
                f.write(json.dumps(job_entry) + '\n')
        except Exception as e:
            print(f"Error saving job: {e}")


def main():
    nest_asyncio.apply()
    batch_input = UserInput(method="scrape_webpage", url="https://www.indeed.com/jobs?q=python+developer")
    scraper = IndeedScraper(batch_input)

    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    loop.run_until_complete(scraper.run())
    loop.close()


if __name__ == "__main__":
    main()