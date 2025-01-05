from app.database import SessionLocal
from app.crud.processed_job import process_unprocessed_jobs
from app.models.job import RawJobPost, JobSource
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy import or_


def get_db_status(db):
    """Get current database status for both Indeed and LinkedIn jobs"""
    # Get total counts
    total_indeed = db.query(RawJobPost).filter(
        RawJobPost.source == JobSource.INDEED
    ).count()

    total_linkedin = db.query(RawJobPost).filter(
        RawJobPost.source == JobSource.LINKEDIN
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

    # Get salary info counts
    indeed_with_salary = db.query(RawJobPost).filter(
        RawJobPost.source == JobSource.INDEED,
        or_(
            RawJobPost.salary_text.isnot(None),
            RawJobPost.salary_from_api.isnot(None)
        )
    ).count()

    linkedin_with_salary = db.query(RawJobPost).filter(
        RawJobPost.source == JobSource.LINKEDIN,
        or_(
            RawJobPost.salary_text.isnot(None),
            RawJobPost.salary_from_api.isnot(None)
        )
    ).count()

    return {
        "indeed": {
            "total": total_indeed,
            "unprocessed": unprocessed_indeed,
            "with_salary": indeed_with_salary
        },
        "linkedin": {
            "total": total_linkedin,
            "unprocessed": unprocessed_linkedin,
            "with_salary": linkedin_with_salary
        },
        "total": total_indeed + total_linkedin
    }


def process_jobs_by_source(db, source, batch_size):
    """Process jobs for a specific source"""
    unprocessed = db.query(RawJobPost).filter(
        RawJobPost.source == source,
        RawJobPost.processed == False
    ).count()

    if unprocessed == 0:
        return {"success": 0, "failed": 0, "errors": []}

    total_batches = (unprocessed + batch_size - 1) // batch_size
    total_success = 0
    total_failed = 0
    all_errors = []

    print(f"\nProcessing {unprocessed} {source.value} jobs in {total_batches} batches...")

    # Set source filter for other queries
    db.info['current_source'] = source

    for batch in range(total_batches):
        print(f"\nBatch {batch + 1}/{total_batches}")
        results = process_unprocessed_jobs(db, limit=batch_size)

        total_success += results['success']
        total_failed += results['failed']
        all_errors.extend(results['errors'])

    # Clear source filter
    db.info['current_source'] = None

    return {
        "success": total_success,
        "failed": total_failed,
        "errors": all_errors
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


def main():
    db = SessionLocal()
    try:
        print("\n=== Job Processing Script ===")
        print("Starting job processing...\n")

        try:
            # Get initial database status
            status = get_db_status(db)

            # Print initial status for each source
            print_source_summary(status, "indeed", "Indeed")
            print_source_summary(status, "linkedin", "LinkedIn")

            if status['indeed']['unprocessed'] == 0 and status['linkedin']['unprocessed'] == 0:
                print("\nNo jobs to process!")
                return

            BATCH_SIZE = 10
            results = {}

            # Process Indeed jobs
            if status['indeed']['unprocessed'] > 0:
                print("\nProcessing Indeed jobs...")
                results['indeed'] = process_jobs_by_source(db, JobSource.INDEED, BATCH_SIZE)

            # Process LinkedIn jobs
            if status['linkedin']['unprocessed'] > 0:
                print("\nProcessing LinkedIn jobs...")
                results['linkedin'] = process_jobs_by_source(db, JobSource.LINKEDIN, BATCH_SIZE)

            # Print processing summary
            print("\n=== Processing Summary ===")
            for source in ['indeed', 'linkedin']:
                if source in results:
                    print(f"\n{source.capitalize()} Results:")
                    print(f"Successfully processed: {results[source]['success']}")
                    print(f"Failed to process: {results[source]['failed']}")

                    if results[source]['errors']:
                        print(f"\n{source.capitalize()} Errors:")
                        for i, error in enumerate(results[source]['errors'], 1):
                            print(f"\nError {i}:")
                            print(f"URL: {error['job_url']}")
                            print(f"Error: {error['error']}")

            # Get and print final status
            final_status = get_db_status(db)
            print("\n=== Final Status ===")
            print_source_summary(final_status, "indeed", "Indeed")
            print_source_summary(final_status, "linkedin", "LinkedIn")

        except SQLAlchemyError as e:
            print(f"\nDatabase error: {str(e)}")
        except Exception as e:
            print(f"\nUnexpected error: {str(e)}")

    finally:
        print("\nClosing database connection...")
        db.close()
        print("Done!")


if __name__ == "__main__":
    main()