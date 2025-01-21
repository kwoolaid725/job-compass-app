import re
from sqlalchemy import text
from app.database import SessionLocal
from app.models.job import JobSource, JobCategory


class DatabaseManager:
    def __init__(self):
        """Initialize DatabaseManager with a session factory."""
        self.Session = SessionLocal

    def extract_linkedin_job_id(self, url: str) -> str:
        """Extract the job ID from a LinkedIn job URL."""
        match = re.search(r'/view/(\d+)/?', url)
        return match.group(1) if match else url

    def normalize_job_url(self, url: str, source: str) -> str:
        """Normalize job URLs to ensure consistent comparison."""
        if source == JobSource.LINKEDIN.value:
            return self.extract_linkedin_job_id(url)
        return url

    def get_existing_jobs(self, source: JobSource, job_category: JobCategory) -> set:
        """Get all existing job URLs for a specific source and category."""
        with self.Session() as session:
            query = text("""
                SELECT job_url 
                FROM raw_job_posts 
                WHERE source = :source 
                AND job_category = :job_category
            """)

            result = session.execute(query, {
                "source": source.name,
                "job_category": job_category.name
            })

            return {self.normalize_job_url(row[0], source.value) for row in result}

    def save_raw_job(self, job_data: dict) -> bool:
        """Save a raw job post to the database."""
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
                    # Convert enums or strings to uppercase values
                    "source": job_data['source'].value.upper() if isinstance(job_data['source'], JobSource) else
                    job_data['source'].upper(),
                    "job_category": job_data['job_category'].value.upper() if isinstance(job_data['job_category'],
                                                                                         JobCategory) else job_data[
                        'job_category'].upper(),
                    "salary_text": job_data.get('salary_text'),
                    "processed": False
                })

                session.commit()
                return True
        except Exception as e:
            print(f"❌ Error saving raw job data: {e}")
            return False

