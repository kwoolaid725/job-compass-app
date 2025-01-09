import argparse
import logging
import os
from dataclasses import dataclass
# from app.scrapers.indeed_scraper import IndeedScraper
from app.scrapers.linkedin_scraper import LinkedInScraper
from app.models.job import JobSource, JobCategory
from app.db.database_manager import DatabaseManager
from dotenv import load_dotenv

from app.scrapers._indeed_scraper import IndeedScraperEnhanced

# Create logs directory if not exists
log_dir = "logs"
os.makedirs(log_dir, exist_ok=True)

# Configure logging
logging.basicConfig(
    filename=os.path.join(log_dir, 'scraper.log'),
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s',
)

# Create logger instance
logger = logging.getLogger("JobScraperLogger")

# Add console output
console_handler = logging.StreamHandler()
console_handler.setFormatter(logging.Formatter('%(asctime)s [%(levelname)s] %(message)s'))
logger.addHandler(console_handler)

load_dotenv()


@dataclass
class UserInput:
    method: str
    url: str
    email: str = os.getenv('LINKEDIN_EMAIL')
    password: str = os.getenv('LINKEDIN_PASSWORD')

def parse_arguments():
    parser = argparse.ArgumentParser(description='Job Scraper Main Script')
    parser.add_argument('--test-indeed', action='store_true',
                        help='Run Indeed scraper test')
    parser.add_argument('--category', type=str,
                        choices=['python_developer', 'data_engineer', 'data_scientist'],
                        help='Job category to scrape')
    return parser.parse_args()

def test_indeed_scraper_enhanced():
    """
    Temporary test function for IndeedScraperEnhanced
    Allows manual testing and debugging of the enhanced scraper
    """
    # Configuration for testing
    test_urls = {
        'python_developer': "https://www.indeed.com/jobs?q=python+developer&sort=date",
        'data_engineer': "https://www.indeed.com/jobs?q=data+engineer&sort=date",
        'data_scientist': "https://www.indeed.com/jobs?q=data+scientist&sort=date"
    }

    # Choose a URL to test
    test_url = test_urls['python_developer']

    # Create DatabaseManager instance
    db_manager = DatabaseManager()

    # Create UserInput
    user_input = UserInput(
        method="scrape_webpage",
        url=test_url
    )

    # Create IndeedScraperEnhanced instance
    scraper = IndeedScraperEnhanced(
        user_input=user_input,
        db_manager=db_manager,
        job_source=JobSource.INDEED,
        job_category=JobCategory.PYTHON_DEVELOPER,
        max_pages=3,  # Limit to fewer pages for testing
        logger=logger
    )

    # Run the scraper
    try:
        logger.info("🚀 Starting Enhanced Indeed Scraper Test...")
        scraper.run()
        logger.info("✅ Enhanced Indeed Scraper Test Completed")
    except Exception as e:
        logger.error(f"❌ Enhanced Indeed Scraper Test Failed: {e}")
        raise


# def run_single_scraper(source: JobSource, category: JobCategory, max_pages: int):
#     """Run a single scraper for the given source and category."""
#     db_manager = DatabaseManager()
#
#     urls = {
#         'python_developer': {
#             'indeed': "https://www.indeed.com/jobs?q=python+developer&sort=date",
#             'linkedin': "https://www.linkedin.com/jobs/search/?keywords=python%20developer&f_TPR=r604800"
#         },
#         'data_engineer': {
#             'indeed': "https://www.indeed.com/jobs?q=data+engineer&sort=date",
#             'linkedin': "https://www.linkedin.com/jobs/search/?keywords=data+engineer&f_TPR=r604800"
#         },
#         'data_scientist': {
#             'indeed': "https://www.indeed.com/jobs?q=data+scientist&sort=date",
#             'linkedin': "https://www.linkedin.com/jobs/search/?keywords=data+scientist&f_TPR=r604800"
#         }
#     }
#
#     url = urls[category.name.lower()][source.name.lower()]
#     user_input = UserInput(method="scrape_webpage", url=url)
#
#     if source == JobSource.INDEED:
#         scraper = IndeedScraper(
#             user_input=user_input,
#             db_manager=db_manager,
#             job_source=source,
#             job_category=category,
#             max_pages=max_pages,
#             logger=logger
#         )
#     elif source == JobSource.LINKEDIN:
#         scraper = LinkedInScraper(
#             user_input=user_input,
#             db_manager=db_manager,
#             job_source=source,
#             job_category=category,
#             max_pages=max_pages,
#             logger=logger
#         )
#
#     logger.info(f"🚀 Starting to scrape {source.name} for {category.name} jobs...")
#     scraper.run()
#
#
# def run_all_combinations(max_pages: int):
#     """Run all source and category combinations."""
#     combinations = [
#         (JobSource.INDEED, JobCategory.PYTHON_DEVELOPER),
#         (JobSource.LINKEDIN, JobCategory.PYTHON_DEVELOPER),
#         (JobSource.INDEED, JobCategory.DATA_ENGINEER),
#         (JobSource.LINKEDIN, JobCategory.DATA_ENGINEER),
#         (JobSource.INDEED, JobCategory.DATA_SCIENTIST),
#         (JobSource.LINKEDIN, JobCategory.DATA_SCIENTIST),
#     ]
#
#     for source, category in combinations:
#         run_single_scraper(source, category, max_pages)


# def main():
#     parser = argparse.ArgumentParser(description="Job Scraper")
#     parser.add_argument("--source", type=str, choices=["indeed", "linkedin"],
#                         help="Source to scrape (indeed or linkedin)")
#     parser.add_argument("--category", type=str, choices=["python_developer", "data_engineer", "data_scientist"],
#                         help="Job category")
#     parser.add_argument("--max_pages", type=int, required=False, default=10,
#                         help="Number of pages to scrape (default: 10)")
#     parser.add_argument("--run_all", action="store_true",
#                         help="Run all combinations of sources and categories")
#
#     args = parser.parse_args()
#
#     try:
#         if args.run_all:
#             logger.info("🚀 Running all scraper combinations...")
#             run_all_combinations(args.max_pages)
#         else:
#             if not args.source or not args.category:
#                 parser.error("You must provide both --source and --category unless using --run_all.")
#
#             # Convert string to enums
#             source = JobSource[args.source.upper()]
#             category = JobCategory[args.category.upper()]
#             run_single_scraper(source, category, args.max_pages)
#
#     except Exception as e:
#         logger.error(f"❌ Error running scraper: {e}")
#         exit(1)

def main():
    # parser = argparse.ArgumentParser(description="Job Scraper")
    # parser.add_argument("--test-indeed", action="store_true",
    #                     help="Run test for Enhanced Indeed Scraper")
    #
    # args = parser.parse_args()

    args = parse_arguments()

    try:
        if args.test_indeed:
            # Run the test function for Enhanced Indeed Scraper
            test_indeed_scraper_enhanced()
            if args.category:
                print(f"Running Indeed scraper for {args.category} category")
                # Add your specific scraping logic based on category
            else:
                print("Running Indeed scraper with default category")


    except Exception as e:
        logger.error(f"❌ Error in main execution: {e}")
        exit(1)

if __name__ == "__main__":
    main()
