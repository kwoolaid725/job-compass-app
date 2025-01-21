from sqlalchemy.orm import Session
from app.models.job import ProcessedJob, RawJobPost


def delete_all_processed_jobs(db: Session) -> int:
    """
    Delete all records from the processed_jobs table.
    Returns the number of rows deleted.
    """
    try:
        count = db.query(ProcessedJob).count()  # Get count before deletion
        db.query(ProcessedJob).delete()

        # Reset processed flag in raw_jobs
        db.query(RawJobPost).update({RawJobPost.processed: False})

        db.commit()
        return count
    except Exception as e:
        db.rollback()
        raise Exception(f"Error deleting processed jobs: {str(e)}")


def delete_processed_jobs_by_criteria(db: Session, **criteria) -> int:
    """
    Delete processed jobs matching the given criteria.
    Example: delete_processed_jobs_by_criteria(db, company="Example Corp")
    Returns the number of rows deleted.
    """
    try:
        query = db.query(ProcessedJob)
        for field, value in criteria.items():
            query = query.filter(getattr(ProcessedJob, field) == value)

        count = query.count()  # Get count before deletion

        # Get IDs of jobs to be deleted
        job_ids = [job.raw_job_post_id for job in query.all()]

        # Delete the processed jobs
        query.delete()

        # Reset processed flag for corresponding raw jobs
        if job_ids:
            db.query(RawJobPost) \
                .filter(RawJobPost.id.in_(job_ids)) \
                .update({RawJobPost.processed: False}, synchronize_session=False)

        db.commit()
        return count
    except Exception as e:
        db.rollback()
        raise Exception(f"Error deleting processed jobs: {str(e)}")


def reset_processing_status(db: Session) -> int:
    """
    Reset the processed flag to False for all raw jobs.
    Returns the number of rows updated.
    """
    try:
        count = db.query(RawJobPost) \
            .filter(RawJobPost.processed == True) \
            .update({RawJobPost.processed: False})
        db.commit()
        return count
    except Exception as e:
        db.rollback()
        raise Exception(f"Error resetting processing status: {str(e)}")