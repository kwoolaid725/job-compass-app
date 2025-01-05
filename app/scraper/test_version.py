import os
import random
import datetime
from urllib.parse import urljoin
from playwright.sync_api import sync_playwright, TimeoutError
from playwright_stealth import stealth_sync
from dataclasses import dataclass
import json

@dataclass
class UserInput:
    method: str
    url: str


class RunScrapers:
    def __init__(self, user_input: UserInput):
        self.user_input = user_input
        self.max_retries = 3
        self.session_cookies = None

    def configure_page(self, page):
        """Configure page with enhanced stealth measures."""
        stealth_sync(page)

        page.add_init_script("""
            const getParameter = WebGLRenderingContext.prototype.getParameter;
            WebGLRenderingContext.prototype.getParameter = function(parameter) {
                if (parameter === 37445) {
                    return 'Intel Open Source Technology Center';
                }
                if (parameter === 37446) {
                    return 'Mesa DRI Intel(R) HD Graphics (Skylake GT2)';
                }
                return getParameter.apply(this, arguments);
            };

            Object.defineProperties(navigator, {
                hardwareConcurrency: {value: 8},
                deviceMemory: {value: 8},
                webdriver: {value: false},
                languages: {value: ['en-US', 'en']},
                platform: {value: 'MacIntel'}
            });

            Object.defineProperties(screen, {
                width: {value: 1920},
                height: {value: 1080},
                colorDepth: {value: 24}
            });
        """)

        if self.session_cookies:
            page.context.add_cookies(self.session_cookies)

    def simulate_human_behavior(self, page):
        page.evaluate("""
            () => {
                const scrolls = Math.floor(Math.random() * 3) + 2;
                for(let i = 0; i < scrolls; i++) {
                    window.scrollTo({
                        top: Math.random() * document.body.scrollHeight,
                        behavior: 'smooth'
                    });
                }
            }
        """)

    def handle_page_load(self, page, url):
        for attempt in range(self.max_retries):
            try:
                response = page.goto(
                    url,
                    wait_until='networkidle',
                    timeout=30000
                )

                if page.title() == 'Just a moment, please...':
                    print("Detected Cloudflare challenge, waiting...")
                    page.wait_for_timeout(10000)

                if response.status == 200:
                    self.session_cookies = page.context.cookies()

                return response

            except TimeoutError:
                if attempt < self.max_retries - 1:
                    print(f"Timeout on attempt {attempt + 1}, retrying...")
                    page.wait_for_timeout(random.uniform(2000, 5000))
                else:
                    raise

    def run(self):
        with sync_playwright() as p:
            for start in range(0, 501, 10):
                try:
                    browser = p.chromium.launch(
                        headless=False,
                        args=[
                            "--disable-blink-features=AutomationControlled",
                            "--disable-features=IsolateOrigins,site-per-process",
                            "--no-sandbox",
                            "--window-size=1920,1080",
                            "--disable-gpu"
                        ]
                    )

                    context = browser.new_context(
                        viewport={'width': 1920, 'height': 1080},
                        user_agent=self.get_random_user_agent(),
                        java_script_enabled=True,
                        locale='en-US',
                        timezone_id='America/New_York',
                        geolocation={'latitude': 40.7128, 'longitude': -74.0060},
                        permissions=['geolocation'],
                        color_scheme='light'
                    )

                    page = context.new_page()
                    self.configure_page(page)

                    page.wait_for_timeout(random.uniform(2000, 5000))

                    page_url = f"{self.user_input.url}&start={start}"
                    print(f"\U0001F310 Navigating to {page_url}")

                    self.handle_page_load(page, page_url)
                    self.simulate_human_behavior(page)

                except Exception as e:
                    print(f"❌ Error during scraping: {e}")
                    continue
                finally:
                    if 'browser' in locals():
                        browser.close()

    def extract_job_links(self, page):
        job_links = []
        try:
            page.wait_for_selector('a.jcs-JobTitle.css-1baag51.eu4oa1w0', timeout=15000)
            anchors = page.query_selector_all('a.jcs-JobTitle.css-1baag51.eu4oa1w0')

            for i, anchor in enumerate(anchors):
                href = anchor.get_attribute('href')
                if href:
                    full_url = urljoin('https://www.indeed.com', href)
                    job_links.append(full_url)
                    print(f"\U0001F517 Job Link {i + 1}: {full_url}")

            print(f"✅ Extracted {len(job_links)} job links")
        except Exception as e:
            print(f"❌ Error extracting job links: {e}")

        return job_links

    def get_job_details(self, page):
        try:
            page.wait_for_load_state('networkidle', timeout=15000)
            self.simulate_human_behavior(page)
            page.wait_for_function("() => window._initialData && window._initialData.hostQueryExecutionResult", timeout=10000)
            window_data = page.evaluate("() => window._initialData")
            return {
                "hostQueryExecutionResult": window_data.get('hostQueryExecutionResult', {})
            }
        except Exception as e:
            print(f"❌ Failed to get job details: {e}")
            return None

    def save_to_file(self, job_url, host_query_execution_result):
        output_file = '../data/output.json'
        job_entry = {
            "job_url": job_url,
            "host_query_execution_result": host_query_execution_result,
            "timestamp": datetime.datetime.now().isoformat()
        }
        try:
            with open(output_file, 'a', encoding='utf-8') as f:
                json.dump(job_entry, f, ensure_ascii=False)
                f.write('\n')
            print(f"✅ Saved data for {job_url}")
        except Exception as e:
            print(f"❌ Failed to save data: {e}")

    @staticmethod
    def get_random_user_agent():
        return random.choice([
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0",
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Safari/605.1.15"
        ])


if __name__ == "__main__":
    user_input = UserInput(method="scrape_webpage", url="https://www.indeed.com/jobs?q=data+scientist")
    scraper = RunScrapers(user_input)
    scraper.run()
