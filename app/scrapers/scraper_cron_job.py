import argparse
import os
from app.scrapers.indeed_scraper import IndeedScraper
from app.scrapers.linkedin_scraper import LinkedInScraper
from dataclasses import dataclass
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
import re
from urllib.parse import urlparse, parse_qs

# Database configuration
DB_CONFIG = {
    'dbname': os.environ.get('DATABASE_NAME'),
    'user': os.environ.get('DATABASE_USERNAME'),
    'password': os.environ.get('DATABASE_PASSWORD'),
    'host': os.environ.get('DATABASE_HOSTNAME'),
    'port': os.environ.get('DATABASE_PORT', 5432)
}


class DatabaseManager:
    def __init__(self):
        db_url = f"postgresql://{DB_CONFIG['user']}:{DB_CONFIG['password']}@{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['dbname']}"
        self.engine = create_engine(db_url)
        self.Session = sessionmaker(bind=self.engine)

    def extract_linkedin_job_id(self, url: str) -> str:
        """Extract the job ID from a LinkedIn job URL"""
        # Method 1: Using regex
        match = re.search(r'/view/(\d+)/?', url)
        if match:
            return match.group(1)
        return url

    def normalize_job_url(self, url: str, source: str) -> str:
        """Normalize job URLs to ensure consistent comparison"""
        if source == 'linkedin':
            return self.extract_linkedin_job_id(url)
        return url

    def get_existing_jobs(self, source: str, job_category: str) -> set:
        """Get all existing job URLs for a specific source and category"""
        with self.Session() as session:
            query = text("""
                SELECT job_url 
                FROM raw_job_posts 
                WHERE source = :source 
                AND job_category = :job_category
            """)

            result = session.execute(query, {
                "source": source,
                "job_category": job_category
            })

            # Normalize URLs based on source
            return {self.normalize_job_url(row[0], source) for row in result}

    def is_job_exists(self, job_url: str, source: str) -> bool:
        """Check if job exists using normalized URL"""
        normalized_url = self.normalize_job_url(job_url, source)
        with self.Session() as session:
            query = text("""
                SELECT 1 FROM raw_job_posts 
                WHERE job_url LIKE :job_pattern
            """)

            # For LinkedIn, search with LIKE pattern
            if source == 'linkedin':
                job_pattern = f"%{normalized_url}%"
            else:
                job_pattern = job_url

            result = session.execute(query, {"job_pattern": job_pattern}).first()
            return bool(result)

    def save_raw_job(self, job_data: dict) -> bool:
        """Save raw job data to raw_job_posts table"""
        try:
            with self.Session() as session:
                query = text("""
                    INSERT INTO raw_job_posts 
                    (job_url, raw_content, source, job_category, salary_text, processed)
                    VALUES 
                    (:job_url, :raw_content, :source, :job_category, :salary_text, :processed)
                    ON CONFLICT (job_url) 
                    DO UPDATE SET
                        raw_content = EXCLUDED.raw_content,
                        salary_text = EXCLUDED.salary_text,
                        processed = false
                """)

                session.execute(query, {
                    "job_url": job_data['job_url'],
                    "raw_content": job_data['raw_content'],
                    "source": job_data['source'],
                    "job_category": job_data['job_category'],
                    "salary_text": job_data.get('salary_text'),
                    "processed": False
                })

                session.commit()
                return True
        except Exception as e:
            print(f"Error saving raw job data: {e}")
            return False


@dataclass
class UserInput:
    method: str
    url: str
    email: str = None
    password: str = None


def main():
    parser = argparse.ArgumentParser(description='Job Scraper')
    parser.add_argument('--source', type=str, required=True,
                        choices=['indeed', 'linkedin'],
                        help='Source to scrape (indeed or linkedin)')
    parser.add_argument('--category', type=str, required=True,
                        choices=['python_developer', 'data_engineer', 'data_scientist'],
                        help='Job category')

    args = parser.parse_args()

    try:
        # Initialize database manager
        db_manager = DatabaseManager()

        # Get existing jobs from database
        existing_jobs = db_manager.get_existing_jobs(args.source, args.category)
        print(f"Found {len(existing_jobs)} existing jobs in database for {args.source} - {args.category}")

        if args.source == 'indeed':
            # Configure Indeed URLs based on category
            urls = {
                'python_developer': "https://www.indeed.com/jobs?q=python+developer&sort=date",
                'data_engineer': "https://www.indeed.com/jobs?q=data+engineer&sort=date",
                'data_scientist': "https://www.indeed.com/jobs?q=data+scientist&sort=date"
            }

            user_input = UserInput(
                method="scrape_webpage",
                url=urls[args.category]
            )
            scraper = IndeedScraper(user_input)
            # Override the scraper's existing_urls with database records
            scraper.existing_urls = existing_jobs
            scraper.run()

        elif args.source == 'linkedin':
            # Configure LinkedIn URLs based on category
            urls = {
                'python_developer': "https://www.linkedin.com/jobs/search/?keywords=python%20developer&f_TPR=r604800",
                'data_engineer': "https://www.linkedin.com/jobs/search/?keywords=data%20engineer&f_TPR=r604800",
                'data_scientist': "https://www.linkedin.com/jobs/search/?keywords=data%20scientist&f_TPR=r604800"
            }

            user_input = UserInput(
                method="scrape_webpage",
                url=urls[args.category]
            )
            scraper = LinkedInScraper(user_input)
            # Override the scraper's existing_urls with database records
            scraper.existing_urls = existing_jobs
            scraper.run()

    except Exception as e:
        print(f"Error running scraper: {e}")
        exit(1)


if __name__ == "__main__":
    main()