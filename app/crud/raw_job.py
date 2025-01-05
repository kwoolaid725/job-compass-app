# app/crud/raw_job.py
from sqlalchemy.orm import Session
import json
from app.models.job import RawJobPost, JobSource, JobCategory
from app.schemas.job import RawJobPostCreate
from urllib.parse import urlparse
from typing import Dict, Any


def extract_salary_from_api(job_data: Dict[str, Any]) -> str:
    """Extract salary information from Indeed's API response"""
    salary_info = {}
    try:
        # Extract compensation data
        if compensation := job_data.get("compensation"):
            salary_info["compensation"] = compensation

        # Extract salary from attributes
        if attributes := job_data.get("attributes"):
            salary_attrs = [attr for attr in attributes
                            if "salary" in attr.get("label", "").lower()]
            if salary_attrs:
                salary_info["salary_attributes"] = salary_attrs

        return json.dumps(salary_info)
    except Exception as e:
        print(f"Error extracting salary from API: {str(e)}")
        return "{}"


def parse_indeed_job(json_data: dict, job_category: str) -> dict:
    try:
        # Extract job data from the API response
        job_data = json_data["host_query_execution_result"]["data"]["jobData"]["results"][0]["job"]
        job_url = json_data.get("job_url")
        raw_content = json.dumps(job_data)

        # Determine source from URL
        parsed_url = urlparse(job_url)
        source = JobSource.INDEED if "indeed.com" in parsed_url.netloc else "unknown"

        # Try to match the job category to the enum
        try:
            category = JobCategory[job_category]
        except KeyError:
            category = JobCategory.OTHERS
            print(f"Warning: Unknown job category '{job_category}', defaulting to OTHERS")

        return {
            "job_url": job_url,
            "raw_content": raw_content,
            "source": source,
            "processed": False,
            "salary_text": json_data.get("salary_info"),
            "salary_from_api": extract_salary_from_api(job_data),
            "job_category": category
        }
    except Exception as e:
        print(f"Error parsing job data: {str(e)}")
        return None

def parse_linkedin_job(raw_data: Dict[str, Any], job_category: str) -> dict:
    """Parse LinkedIn job data into RawJobPost format"""
    try:
        # Ensure we have the required fields
        if not raw_data.get("job_url") or not raw_data.get("raw_content"):
            raise ValueError("Missing required fields in job data")

        # Extract salary text from job insights
        salary_text = None
        try:
            job_data = json.loads(raw_data["raw_content"])
            if job_insights := job_data.get('job_insight', []):
                for insight in job_insights:
                    if isinstance(insight, str) and '$' in insight:
                        salary_text = insight.split('  ')[0]
                        break
        except json.JSONDecodeError:
            print("Warning: Could not parse raw_content as JSON")

        # Try to match the job category to the enum
        try:
            category = JobCategory[job_category]
        except KeyError:
            category = JobCategory.OTHERS
            print(f"Warning: Unknown job category '{job_category}', defaulting to OTHERS")

        return {
            "job_url": raw_data["job_url"],
            "raw_content": raw_data["raw_content"],
            "source": JobSource.LINKEDIN,
            "processed": False,
            "salary_text": salary_text,
            "salary_from_api": "",
            "job_category": category
        }
    except Exception as e:
        print(f"Error parsing LinkedIn job data: {str(e)}")
        return None


def create_raw_job(db: Session, job_data: dict):
    try:
        existing_job = get_raw_job_by_url(db, job_data['job_url'])
        if existing_job:
            return None

        db_job = RawJobPost(**job_data)
        db.add(db_job)
        db.commit()
        db.refresh(db_job)
        return db_job
    except Exception as e:
        db.rollback()
        raise e


def get_raw_job(db: Session, job_id: int):
    return db.query(RawJobPost).filter(RawJobPost.id == job_id).first()


def get_raw_job_by_url(db: Session, job_url: str):
    return db.query(RawJobPost).filter(RawJobPost.job_url == job_url).first()


def get_raw_jobs(db: Session, skip: int = 0, limit: int = 100):
    return db.query(RawJobPost).offset(skip).limit(limit).all()


def get_unprocessed_jobs(db: Session, skip: int = 0, limit: int = 100):
    return db.query(RawJobPost).filter(RawJobPost.processed == False).offset(skip).limit(limit).all()


def mark_as_processed(db: Session, job_id: int):
    job = get_raw_job(db, job_id)
    if job:
        job.processed = True
        db.commit()
        return job
    return None