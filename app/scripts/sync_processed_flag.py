from app.database import SessionLocal
from app.crud.db_management import sync_processed_flag, reset_processing_status


from app.models.job import ProcessedJob, RawJobPost

def compare_processed_counts():
    """Compare number of rows in processed_job vs rows with processed=True in raw_job."""
    db = SessionLocal()
    try:
        print("\n=== Checking Processed Job Counts ===")

        # Count rows in ProcessedJob
        processed_job_count = db.query(ProcessedJob).count()
        print(f"Number of rows in ProcessedJob: {processed_job_count}")

        # Count rows in RawJobPost where processed=True
        raw_job_processed_count = db.query(RawJobPost).filter(RawJobPost.processed == True).count()
        print(f"Number of rows with processed=True in RawJobPost: {raw_job_processed_count}")

        # Compare the two counts
        if processed_job_count == raw_job_processed_count:
            print("\n✅ Processed counts match!")
        else:
            print("\n⚠️ Processed counts do NOT match!")
            print(f"Difference: {abs(processed_job_count - raw_job_processed_count)} rows")

    except Exception as e:
        print(f"\nError during comparison: {str(e)}")
    finally:
        db.close()
        print("\nDatabase session closed.")


def main():
    """Run the sync_processed_flag function."""
    db = SessionLocal()  # Initialize a new database session
    try:
        print("\nStarting to sync processed flag...")
        sync_processed_flag(db)
        print("\nSync completed successfully.")
    except Exception as e:
        print(f"Error during sync: {str(e)}")
    finally:
        db.close()
        print("Database session closed.")

    # try:
    #     print("\nResetting All Processing Status")
    #     reset_processing_status(db)
    #     print("\nReset successfully.")
    # except Exception as e:
    #     print(f"Error during sync: {str(e)}")
    # finally:
    #     db.close()
    #     print("Database session closed.")


if __name__ == "__main__":
    main()

    # compare_processed_counts()
