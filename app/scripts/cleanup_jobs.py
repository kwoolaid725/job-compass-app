from app.database import SessionLocal
from app.crud.db_management import delete_all_processed_jobs, delete_processed_jobs_by_criteria, reset_processing_status


def main():
    db = SessionLocal()
    try:
        print("\n=== Database Cleanup Script ===")

        # Delete all processed jobs
        deleted_count = delete_all_processed_jobs(db)
        print(f"\nDeleted {deleted_count} processed jobs")

        # Reset processing status
        reset_count = reset_processing_status(db)
        print(f"Reset processing status for {reset_count} raw jobs")

        print("\nCleanup completed successfully!")

    except Exception as e:
        print(f"\nError during cleanup: {str(e)}")
    finally:
        print("\nClosing database connection...")
        db.close()
        print("Done!")


if __name__ == "__main__":
    main()