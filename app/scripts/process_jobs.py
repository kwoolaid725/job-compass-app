from app.database import SessionLocal
from typing import Dict, Any, Optional, List
from app.crud.process_indeed_raw_jobs import process_job_data_indeed
from app.crud.process_linkedin_raw_jobs import process_job_data_linkedin
from app.crud.process_builtinchicago_raw_jobs import process_job_data_builtinchicago
from app.models.job import RawJobPost, JobSource, ProcessedJob, SalaryType
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy import or_
import json
import asyncio
from openai import AsyncOpenAI
from dotenv import load_dotenv
from pathlib import Path
import os
from selectolax.parser import HTMLParser

PROJECT_ROOT = Path(__file__).parent.parent

# Load .env file from the project root
load_dotenv(dotenv_path=PROJECT_ROOT / '.env')


async_client = AsyncOpenAI(api_key=os.getenv("OPENAI_API_KEY"))


async def extract_salary_info_openai(job_description: str, salary_text: str, max_retries: int = 3) -> Optional[Dict]:
    """
    Extract salary information from a job description using OpenAI's API.

    Args:
        job_description (str): The text of the job description.
        salary_text (str): Additional salary text to analyze.

    Returns:
        Dict: A dictionary containing salary_type (SalaryType), salary_min, salary_max, and salary_currency.
              Returns None if extraction fails.
    """
    prompt = f"""
    Extract the salary information from the following job description. Pay close attention to salary ranges. 
    Provide the details in JSON format with the following fields: salary_type, salary_min, salary_max, and salary_currency.
    The salary_type must be exactly one of: "Hourly", "Yearly", "Monthly", or "Contract".

    Important Guidelines:
    - If a salary range is present (e.g., $125,000-$139,400), use both the minimum and maximum values.
    - If only a single salary is mentioned, use the same value for both min and max.
    - Look for keywords like "salary range", "$X-$Y", "between $X and $Y"
    - Ignore currency symbols and commas when parsing numbers

    Example 1:
    Job Description: "We offer a competitive salary range between $90,000 and $120,000 per year."
    Extracted Salary Information:
    {{
      "salary_type": "Yearly",
      "salary_min": 90000,
      "salary_max": 120000,
      "salary_currency": "USD"
    }}

    Example 2:
    Job Description: "Annual salary of $100,000"
    Extracted Salary Information:
    {{
      "salary_type": "Yearly",
      "salary_min": 100000,
      "salary_max": 100000,
      "salary_currency": "USD"
    }}

    Job Description:
    {job_description}

    Salary Text:
    {salary_text}

    If no salary information is found, return null.
    """

    # Base delay between requests to prevent rate limiting
    BASE_DELAY = 0.2  # 200ms base delay

    # Add base delay before making request
    await asyncio.sleep(BASE_DELAY)

    retry_count = 0
    while retry_count < max_retries:
        try:
            response = await async_client.chat.completions.create(
                model="gpt-4o-mini",
                messages=[
                    {"role": "system",
                     "content": "You are a precise assistant for extracting salary information. Always prioritize detecting full salary ranges. Use exact salary_type values: 'Hourly', 'Yearly', 'Monthly', or 'Contract'."},
                    {"role": "user", "content": prompt}
                ],
                temperature=0,
                max_tokens=200,
                response_format={"type": "json_object"}
            )

            # Extract and parse the response
            reply = response.choices[0].message.content.strip()
            salary_info = json.loads(reply)

            # Early return if no salary info found
            if not salary_info or not isinstance(salary_info, dict):
                return None

            # Check if all required fields are present
            required_fields = {'salary_type', 'salary_min', 'salary_max', 'salary_currency'}
            if not all(field in salary_info for field in required_fields):
                return None

            # Convert salary type string to enum member
            try:
                salary_type_str = salary_info['salary_type']
                if not salary_type_str:  # Check if empty string
                    return None
                salary_info['salary_type'] = SalaryType[salary_type_str.upper()]
            except (KeyError, AttributeError):
                print(f"Invalid salary type: {salary_info.get('salary_type')}")
                return None

            return salary_info

        except Exception as e:
            if 'rate_limit_exceeded' in str(e):
                retry_count += 1
                # Exponential backoff: wait longer after each retry
                wait_time = (2 ** retry_count) * 0.2  # 0.4s, 0.8s, 1.6s
                print(f"Rate limit hit, waiting {wait_time}s before retry {retry_count}/{max_retries}")
                await asyncio.sleep(wait_time)
            else:
                print(f"Error during extraction: {e}")
                return None

async def process_raw_job_async(db, raw_job: RawJobPost) -> Optional[ProcessedJob]:
    try:
        # Skip already processed jobs
        if raw_job.processed:
            print(f"Job with raw_job_post_id {raw_job.id} already processed. Skipping.")
            return None

        # Process job data based on the source
        if raw_job.source == JobSource.INDEED:
            processed_data = process_job_data_indeed(raw_job.raw_content)
            # Only add OpenAI salary extraction if no salary was extracted by Indeed method
            if not any(processed_data.get(key) for key in ['salary_min', 'salary_max', 'salary_type']):
                salary_info = await extract_salary_info_openai(
                    processed_data.get('description', ''),
                    raw_job.salary_text if hasattr(raw_job, 'salary_text') else ''
                )
                if salary_info:
                    processed_data.update(salary_info)

        elif raw_job.source == JobSource.LINKEDIN:
            processed_data = process_job_data_linkedin(raw_job.raw_content)
            processed_data["job_url"] = raw_job.job_url

            # Only add OpenAI salary extraction if no salary was extracted by LinkedIn method
            if not any(processed_data.get(key) for key in ['salary_min', 'salary_max', 'salary_type']):
                salary_info = await extract_salary_info_openai(
                    processed_data.get('description', ''),
                    raw_job.salary_text if hasattr(raw_job, 'salary_text') else ''
                )
                if salary_info:
                    processed_data.update(salary_info)

        elif raw_job.source == JobSource.BUILTINCHICAGO:
            processed_data = process_job_data_builtinchicago(raw_job.raw_content)
            processed_data["job_url"] = raw_job.job_url

            # Only add OpenAI salary extraction if no salary was extracted by LinkedIn method
            if not any(processed_data.get(key) for key in ['salary_min', 'salary_max', 'salary_type']):
                salary_info = await extract_salary_info_openai(
                    processed_data.get('description', ''),
                    raw_job.salary_text if hasattr(raw_job, 'salary_text') else ''
                )
                if salary_info:
                    processed_data.update(salary_info)

        # Add the raw_job_post_id to the processed data
        processed_data["raw_job_post_id"] = raw_job.id

        # Create and insert a new ProcessedJob
        db_job = ProcessedJob(**processed_data)
        db.add(db_job)
        db.commit()
        db.refresh(db_job)

        # Mark the raw job as processed
        raw_job.processed = True
        db.commit()

        return db_job
    except Exception as e:
        db.rollback()
        print(f"Error processing job {raw_job.job_url}: {str(e)}")
        raise


async def process_jobs_batch(db, jobs: List[RawJobPost], batch_size: int = 10):
    """Process a batch of jobs concurrently"""
    tasks = []
    for i in range(0, len(jobs), batch_size):
        batch = jobs[i:i + batch_size]
        batch_tasks = [process_raw_job_async(db, job) for job in batch]
        tasks.extend(batch_tasks)

    return await asyncio.gather(*tasks)


def get_db_status(db):
    """Get current database status for both Indeed and LinkedIn jobs"""
    # Get total counts
    total_indeed = db.query(RawJobPost).filter(
        RawJobPost.source == JobSource.INDEED
    ).count()

    total_linkedin = db.query(RawJobPost).filter(
        RawJobPost.source == JobSource.LINKEDIN
    ).count()

    total_builtinchicago = db.query(RawJobPost).filter(
        RawJobPost.source == JobSource.BUILTINCHICAGO
    ).count()

    # Get unprocessed counts
    unprocessed_indeed = db.query(RawJobPost).filter(
        RawJobPost.source == JobSource.INDEED,
        RawJobPost.processed == False
    ).count()

    unprocessed_linkedin = db.query(RawJobPost).filter(
        RawJobPost.source == JobSource.LINKEDIN,
        RawJobPost.processed == False
    ).count()

    unprocessed_builtinchicago = db.query(RawJobPost).filter(
        RawJobPost.source == JobSource.BUILTINCHICAGO,
        RawJobPost.processed == False
    ).count()

    #
    return {
        "indeed": {
            "total": total_indeed,
            "unprocessed": unprocessed_indeed,
        },
        "linkedin": {
            "total": total_linkedin,
            "unprocessed": unprocessed_linkedin,
        },
        "builtinchicago": {
            "total": total_builtinchicago,
            "unprocessed": unprocessed_builtinchicago,
        },
        "total": total_indeed + total_linkedin + total_builtinchicago
    }


def print_source_summary(status, source_key, source_name):
    """Print summary for a specific source"""
    source_data = status[source_key]
    if source_data["total"] > 0:
        print(f"\n=== {source_name} Status ===")
        print(f"- Total jobs: {source_data['total']}")
        print(f"- Unprocessed jobs: {source_data['unprocessed']}")
        salary_percentage = (source_data['with_salary'] / source_data['total'] * 100) if source_data['total'] > 0 else 0
        print(f"- Jobs with salary info: {source_data['with_salary']} ({salary_percentage:.1f}%)")


async def update_missing_salary_info(db, batch_size: int = 10):
    """
    Update salary information for processed jobs that have no salary data.
    Uses OpenAI API to extract salary information from job descriptions.

    Args:
        db: Database session
        batch_size (int): Number of jobs to process concurrently
    """
    try:
        # Query for processed jobs with no salary information
        jobs_without_salary = db.query(ProcessedJob).filter(
            or_(
                ProcessedJob.salary_min.is_(None),
                ProcessedJob.salary_max.is_(None),
                ProcessedJob.salary_type.is_(None)
            )
        ).all()

        total_jobs = len(jobs_without_salary)
        print(f"\n🔍 Found {total_jobs} processed jobs without salary information")

        successful_updates = 0
        failed_updates = 0

        # Process in batches
        for i in range(0, total_jobs, batch_size):
            batch = jobs_without_salary[i:i + batch_size]
            print(f"\n📊 Processing Batch {i // batch_size + 1}/{(total_jobs + batch_size - 1) // batch_size}")
            print(f"   Batch Size: {len(batch)}")

            # Process each job in the batch concurrently
            tasks = []
            for i, job in enumerate(batch):
                if i > 0:
                    await asyncio.sleep(0.5)
                async def process_single_job(job):
                    try:
                        # Extract salary info from job description
                        salary_info = await extract_salary_info_openai(
                            job.description or '',
                            ''  # No additional salary text for processed jobs
                        )

                        if salary_info:
                            # Update the job with new salary information
                            job.salary_type = salary_info['salary_type']
                            job.salary_min = salary_info['salary_min']
                            job.salary_max = salary_info['salary_max']
                            job.salary_currency = salary_info['salary_currency']
                            return True
                        return False
                    except Exception as e:
                        print(f"Error processing job {job.id}: {str(e)}")
                        return False

                tasks.append(process_single_job(job))

            # Wait for all jobs in batch to complete
            results = await asyncio.gather(*tasks)

            # Update batch statistics
            batch_successful = sum(1 for r in results if r)
            batch_failed = sum(1 for r in results if not r)

            successful_updates += batch_successful
            failed_updates += batch_failed

            # Commit changes for the batch
            try:
                db.commit()
                print(f"   ✅ Successfully updated: {batch_successful}")
                if batch_failed > 0:
                    print(f"   ❌ Failed updates: {batch_failed}")
            except SQLAlchemyError as e:
                db.rollback()
                print(f"   ❌ Database error: {str(e)}")
                failed_updates += len(batch)

            # Print progress
            print(f"\n🔄 Overall Progress:")
            print(f"   Total Jobs: {total_jobs}")
            print(f"   Updated: {successful_updates}")
            print(f"   Remaining: {total_jobs - successful_updates - failed_updates}")

        # Print final status
        print("\n🏁 Final Update Status:")
        print(f"Total Jobs Processed: {total_jobs}")
        print(f"Successfully Updated: {successful_updates}")
        print(f"Failed Updates: {failed_updates}")

    except Exception as e:
        print(f"❌ Critical Error: {str(e)}")
        raise
    finally:
        db.commit()


async def main_async():
    db = SessionLocal()
    try:
        # Process both Indeed and LinkedIn jobs
        for source in [JobSource.INDEED, JobSource.LINKEDIN, JobSource.BUILTINCHICAGO]:
            # Get unprocessed jobs for current source
            unprocessed_jobs = db.query(RawJobPost).filter(
                RawJobPost.source == source,
                RawJobPost.processed == False
            ).all()

            total_jobs = len(unprocessed_jobs)
            print(f"\n🔍 Initial Job Scan: Found {total_jobs} unprocessed {source.value} jobs")

            if total_jobs == 0:
                print(f"No unprocessed {source.value} jobs to process.")
                continue

            # Initialize counters
            successful_jobs = 0
            failed_jobs = 0

            # Process in batches of 10 concurrently
            for i in range(0, total_jobs, 10):
                batch = unprocessed_jobs[i:i + 10]

                # Print current batch status
                print(f"\n📊 Processing {source.value} Batch {i // 10 + 1}/{(total_jobs + 9) // 10}")
                print(f"   Batch Size: {len(batch)}")

                # Process batch
                try:
                    results = await process_jobs_batch(db, batch, batch_size=10)

                    # Count successful and failed jobs in this batch
                    batch_successful = len([r for r in results if r is not None])
                    batch_failed = len([r for r in results if r is None])

                    successful_jobs += batch_successful
                    failed_jobs += batch_failed

                    # Live status update
                    print(f"   ✅ Successful: {batch_successful}")
                    if batch_failed > 0:
                        print(f"   ❌ Failed: {batch_failed}")

                    # Interim status
                    print(f"\n🔄 Overall Progress for {source.value}:")
                    print(f"   Total Jobs: {total_jobs}")
                    print(f"   Processed: {successful_jobs}")
                    print(f"   Remaining: {total_jobs - successful_jobs}")

                except Exception as e:
                    print(f"❗ Error processing batch: {e}")
                    failed_jobs += len(batch)

            # Print final status for current source
            print(f"\n🏁 Final Processing Status for {source.value}:")
            print(f"Total Jobs: {total_jobs}")
            print(f"Successfully Processed: {successful_jobs}")
            print(f"Failed Jobs: {failed_jobs}")

        # Get and print overall database status
        status = get_db_status(db)
        print("\n📋 Overall Database Status:")
        print(f"Indeed Jobs:")
        print(f"  - Total: {status['indeed']['total']}")
        print(f"  - Unprocessed: {status['indeed']['unprocessed']}")
        print(f"LinkedIn Jobs:")
        print(f"  - Total: {status['linkedin']['total']}")
        print(f"  - Unprocessed: {status['linkedin']['unprocessed']}")
        print(f"BuiltInChicago Jobs:")
        print(f"  - Total: {status['builtinchicago']['total']}")
        print(f"  - Unprocessed: {status['builtinchicago']['unprocessed']}")

    except Exception as e:
        print(f"❌ Critical Error: {e}")
    finally:
        db.close()

# async def main_salary_update():
#     db = SessionLocal()
#     try:
#         await update_missing_salary_info(db)
#     finally:
#         db.close()

if __name__ == "__main__":
    asyncio.run(main_async())
    # asyncio.run(main_salary_update())



# def inspect_builtinchicago_jobs(db):
#     """Inspect unprocessed BuiltInChicago jobs"""
#     unprocessed = db.query(RawJobPost).filter(
#         RawJobPost.source == JobSource.BUILTINCHICAGO,
#         RawJobPost.processed == False
#     ).limit(3).all()  # Look at first 3 jobs
#
#     print(f"\n=== Unprocessed BuiltInChicago Jobs ===")
#     if not unprocessed:
#         print("No unprocessed jobs found")
#         return
#
#     for job in unprocessed:
#         print(f"\nJob URL: {job.job_url}")
#         print(f"Created at: {job.created_at}")
#
#         # Print raw content for debugging
#         if not job.raw_content:
#             print("Issue: Missing raw_content")
#             continue
#
#         try:
#             content = json.loads(job.raw_content)
#             print("\nContent Keys:", list(content.keys()))
#
#             # Check key components needed for processing
#             if 'json_ld' in content:
#                 json_ld = content['json_ld']
#                 print("\nJSON-LD Fields:", list(json_ld.keys()) if json_ld else "Empty JSON-LD")
#                 print(f"Title: {json_ld.get('title', 'Missing')}")
#                 print(f"Company: {json_ld.get('hiringOrganization', {}).get('name', 'Missing')}")
#                 print(f"Description Length: {len(json_ld.get('description', ''))}")
#             else:
#                 print("Issue: Missing json_ld in content")
#
#             if 'salary_text' in content:
#                 print(f"Salary Text: {content['salary_text']}")
#             else:
#                 print("Issue: Missing salary_text")
#
#         except json.JSONDecodeError:
#             print("Issue: Invalid JSON in raw_content")
#             print("Raw content preview:", job.raw_content[:200])
#         except Exception as e:
#             print(f"Issue: Error analyzing content: {str(e)}")
