import os
import random
from urllib.parse import urljoin
from playwright.sync_api import sync_playwright
from playwright_stealth import stealth_sync
from dataclasses import dataclass
import json
import time
from typing import Optional, List
from app.models.job import JobSource, JobCategory
from app.crud.job_queries import find_linkedin_duplicates_batch
from dotenv import load_dotenv
import re
import logging

load_dotenv()

@dataclass
class UserInput:
    method: str
    url: str
    email: str = os.getenv('LINKEDIN_EMAIL')
    password: str = os.getenv('LINKEDIN_PASSWORD')


class LinkedInScraper:
    def __init__(self, user_input: UserInput, max_pages: int = 10,
                 existing_urls: Optional[set] = None,
                 job_source: Optional[JobSource] = None,
                 job_category: Optional[JobCategory] = None,
                 db_manager=None,
                 logger=None):
        if not user_input.email or not user_input.password:
            raise ValueError("LinkedIn credentials not found in environment variables.")

        self.user_input = user_input
        self.job_source = job_source  # Should be JobSource enum
        self.job_category = job_category  # Should be JobCategory enum
        self.max_pages = max_pages
        self.existing_urls = existing_urls if existing_urls else set()
        self.db_manager = db_manager
        self.jobs_processed = 0  # Add this line to track the number of processed jobs
        self.logger = logger or logging.getLogger(__name__)



    def extract_linkedin_job_id(self, url: str) -> Optional[str]:
        """Extract LinkedIn job ID from job URL."""
        match = re.search(r'/view/(\d+)', url)
        return match.group(1) if match else None

    def run(self):
        """Run scraper for a given number of pages."""
        with sync_playwright() as p:
            browser = p.chromium.launch(headless=True)
            context = browser.new_context(viewport={'width': 1920, 'height': 1080})
            page = context.new_page()

            # Login to LinkedIn
            if not self.login_to_linkedin(page):
                self.logger.error("❌ Failed to login, stopping scraper")
                return

            for start in range(0, self.max_pages * 25, 25):
            # for start in range(400, self.max_pages * 25, 25):
                page_url = f"{self.user_input.url}&start={start}"
                self.logger.info(f"🔍 Processing page: {start // 25 + 1}")

                try:
                    page.goto(page_url, timeout=45000)
                    page.wait_for_timeout(random.uniform(3000, 5000))
                    self.scroll_with_mouse_wheel(page)
                    job_links = self.extract_job_links(page)

                    if not job_links:
                        self.logger.error("No more jobs found, stopping")
                        break

                    # Perform batch duplicate check
                    duplicate_job_ids = find_linkedin_duplicates_batch(self.db_manager.Session(), job_links)

                    for job_url in job_links:
                        job_id = self.extract_linkedin_job_id(job_url)
                        if job_id in duplicate_job_ids:
                            self.logger.info(f"⏭️ Skipping duplicate job: {job_url}")
                            continue

                        self.process_job(page, job_url)
                        # job_data = self.get_job_details(page, job_url)
                        # if job_data:
                        #     self.save_to_file(job_data)
                        #     self.existing_urls.add(job_url)
                        #     time.sleep(random.uniform(1, 3))

                except Exception as e:
                    self.logger.error(f"❌ Error processing page {start}: {e}")
                    time.sleep(random.uniform(10, 15))
                    continue

                time.sleep(random.uniform(3, 6))

            browser.close()

    def process_job(self, page, job_url):
        """Process individual job URLs."""
        try:
            # Get job details from the LinkedIn job page
            details = self.get_job_details(page, job_url)

            if details:
                job_data = {
                    'job_url': job_url,
                    'raw_content': json.dumps(details),
                    'source': self.job_source if isinstance(self.job_source, str) else self.job_source.name.upper(),
                    'job_category': self.job_category if isinstance(self.job_category,
                                                                    str) else self.job_category.name.upper(),
                    'salary_text': details.get('salary_text'),
                    'processed': False
                }

                # Save job data to the database
                if self.db_manager and self.db_manager.save_raw_job(job_data):
                    self.jobs_processed += 1
                    self.logger.info(f"✅ Saved job {self.jobs_processed}: {job_url}")
                else:
                    self.logger.error(f"⚠️ Faƒiled to save job: {job_url}")

        except Exception as e:
            self.logger.error(f"❌ Error processing job {job_url}: {e}")

    def load_existing_job_urls(self) -> set:
        """Load already scraped job URLs from the output file."""
        existing_urls = set()
        output_file = '../data/output_python_developer_linkedin.json'

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

    def login_to_linkedin(self, page):
        """Handle LinkedIn login."""
        try:
            print("🔑 Attempting to login to LinkedIn...")
            page.goto("https://www.linkedin.com/login")
            page.wait_for_selector("#username", timeout=10000)

            # Enter credentials
            page.fill("#username", self.user_input.email)
            page.fill("#password", self.user_input.password)

            # Click login button
            page.click("button[type='submit']")

            # Wait for navigation and check for success
            try:
                # Check for successful login OR verification page
                success = False
                for _ in range(60):  # 60 seconds total
                    if page.query_selector(".feed-identity-module"):
                        print("✅ Successfully logged in to LinkedIn")
                        success = True
                        break
                    time.sleep(1)
                return success
            except Exception as e:
                print(f"⚠️ Login verification timeout: {e}")
                return False

        except Exception as e:
            print(f"❌ Login error: {e}")
            return False

    def scroll_with_mouse_wheel(self, page):
        """
        Scroll the left section by injecting a custom 'debug cursor' (a small red circle)
        and then performing mouse wheel events at a specified coordinate.
        This way, you can visually confirm the mouse position and scrolling.
        """
        try:
            # Inject a debug pointer (a small red circle) to see where the mouse is
            debug_script = """
            () => {
                // Check if we've already injected the debug cursor
                if (!document.getElementById('debug-pointer')) {
                    const cursor = document.createElement('div');
                    cursor.id = 'debug-pointer';
                    // Basic styling: red circle, on top of everything
                    cursor.style.position = 'fixed';
                    cursor.style.width = '15px';
                    cursor.style.height = '15px';
                    cursor.style.backgroundColor = 'red';
                    cursor.style.border = '2px solid white';
                    cursor.style.borderRadius = '50%';
                    cursor.style.zIndex = '999999';
                    cursor.style.pointerEvents = 'none';
                    document.body.appendChild(cursor);

                    // Move the circle in response to mousemove
                    document.addEventListener('mousemove', (e) => {
                        const debugPointer = document.getElementById('debug-pointer');
                        if (debugPointer) {
                            debugPointer.style.left = (e.pageX - 7) + 'px';
                            debugPointer.style.top = (e.pageY - 7) + 'px';
                        }
                    });
                }
            }
            """
            # Evaluate the debug script in the page
            page.evaluate(debug_script)

            # Move mouse to the left side at some reasonable coordinate
            # Adjust x, y as needed depending on your viewport and LinkedIn layout
            x_coord = 600
            y_coord = 400
            page.mouse.move(x_coord, y_coord)

            # Perform mouse wheel scrolling multiple times
            scroll_steps = 5
            for _ in range(scroll_steps):
                page.mouse.wheel(0, 1000)  # (deltaX=0, deltaY=500)
                # Wait briefly to allow LinkedIn to load additional jobs
                # page.wait_for_timeout(500)

            print("✅ Completed mouse-wheel scrolling on the left section (debug cursor injected)")

        except Exception as e:
            print(f"❌ Error in mouse-wheel scrolling: {e}")

    def extract_job_links(self, page):
        """
        Enhanced job link extraction using mouse-wheel scrolling on the left section
        before extracting links.
        """
        # Scroll the left section with the mouse wheel
        self.scroll_with_mouse_wheel(page)

        job_links = []
        try:
            # Wait for job cards with extended timeout
            page.wait_for_selector("a.job-card-container__link", timeout=30000)

            # Extract links using multiple strategies
            strategies = [
                # Primary selector
                lambda: page.evaluate("""
                    () => Array.from(
                        document.querySelectorAll('a.job-card-container__link'),
                        a => a.getAttribute('href')
                    )
                """),

                # Alternative selector
                lambda: page.evaluate("""
                    () => Array.from(
                        document.querySelectorAll('div[data-job-id] a.job-card-container__link'),
                        a => a.getAttribute('href')
                    )
                """)
            ]

            # Try each strategy
            for strategy in strategies:
                try:
                    hrefs = strategy()
                    job_links = [f"https://www.linkedin.com{href}" for href in hrefs if href and '/jobs/view/' in href]

                    # If we found links, break the loop
                    if job_links:
                        break
                except Exception as inner_e:
                    print(f"⚠️ Link extraction strategy failed: {inner_e}")

            # Log the number of job links found
            print(f"✅ Extracted {len(job_links)} job links")

            return job_links

        except Exception as e:
            print(f"❌ Error extracting job links: {e}")
            return []

    def get_job_details(self, page, job_url):
        """Extract details from individual job posting."""
        try:
            page.goto(job_url, timeout=30000)
            page.wait_for_selector(".job-view-layout", timeout=15000)

            # Basic info
            title_elem = page.query_selector(".job-details-jobs-unified-top-card__job-title")
            company_elem = page.query_selector(".job-details-jobs-unified-top-card__company-name")
            location_elem = page.query_selector(".job-details-jobs-unified-top-card__bullet")
            description_elem = page.query_selector("#job-details")

            # Get job insights from both selectors
            job_insights = []

            # First selector - highlighted insights
            highlighted_insights = page.query_selector_all(
                ".job-details-jobs-unified-top-card__job-insight.job-details-jobs-unified-top-card__job-insight--highlight"
            )
            job_insights.extend([insight.inner_text() for insight in highlighted_insights if insight])

            # Second selector - primary description container
            primary_desc = page.query_selector(
                ".job-details-jobs-unified-top-card__primary-description-container"
            )
            if primary_desc:
                job_insights.append(primary_desc.inner_text())

            # Add pills extraction
            pills = page.query_selector_all(".job-details-preferences-and-skills__pill")
            print("pills", pills)
            for pill in pills:
                span = pill.query_selector(".ui-label")
                if span:
                    text = span.inner_text().strip()
                    if text and not text.startswith('0 of') and 'skills match' not in text:
                        job_insights.append(text)

            # Additional sections
            segment_cards = page.query_selector_all(
                ".artdeco-card.job-details-segment-attribute-card-job-details, .artdeco-card.job-details-module")
            details_modules = page.query_selector_all(".artdeco-card.job-details-module")
            skills_items = page.query_selector_all(".job-details-how-you-match__skills-item-wrapper")

            segment_content = [card.inner_text() for card in segment_cards if card]
            module_content = [module.inner_text() for module in details_modules if module]
            skills_content = [skill.inner_text() for skill in skills_items if skill]

            job_details = {
                "title": title_elem.inner_text() if title_elem else None,
                "company": company_elem.inner_text() if company_elem else None,
                "location_raw": location_elem.inner_text() if location_elem else None,
                "description": description_elem.inner_text() if description_elem else None,
                "job_insight": job_insights,  # Now includes both insights and pills
                "segment_cards": segment_content,
                "details_modules": module_content,
                "skills": skills_content,
            }

            return {
                "job_url": job_url,
                "raw_content": json.dumps(job_details),
                "source": "linkedin",
                "job_category": "PYTHON_DEVELOPER",
                "processed": False,
                "salary_text": None
            }

        except Exception as e:
            print(f"❌ Error getting job details: {e}")
            return None

    def save_to_file(self, job_data):
        """Save job data to file."""
        output_file = f'../data/output_python_developer_linkedin.json'
        try:
            with open(output_file, 'a', encoding='utf-8') as f:
                json.dump(job_data, f, ensure_ascii=False)
                f.write('\n')
            return True
        except Exception as e:
            print(f"❌ Error saving data: {e}")
            return False





def main():
    user_input = UserInput(
        method="scrape_webpage",
        url="https://www.linkedin.com/jobs/search/?keywords=python%20developer&origin=JOBS_HOME_SEARCH_BUTTON&refresh=true"
    )

    scraper = LinkedInScraper(user_input)
    scraper.run()


if __name__ == "__main__":
    main()
