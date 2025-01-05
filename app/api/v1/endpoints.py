#app/api/v1/endpoints.py
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.job import ProcessedJob, JobStatus, RawJobPost
from app.schemas.job import ProcessedJobCreate, RawJobPostCreate, RawJobPost
from typing import Optional, List
from sqlalchemy import desc, or_, Date, case, func
from datetime import datetime, date
router = APIRouter(prefix="/jobs", tags=["jobs"])

@router.post("/raw/")
def create_raw_job(job: RawJobPostCreate, db: Session = Depends(get_db)):
    db_job = RawJobPost(**job.dict())
    db.add(db_job)
    db.commit()
    db.refresh(db_job)
    return db_job

@router.get("/raw/")
def read_raw_jobs(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    jobs = db.query(RawJobPost).offset(skip).limit(limit).all()
    return jobs


@router.get("/processed/")
def read_processed_jobs(
    skip: int = 0,
    limit: int = 100,
    status: List[str] = Query(None),  # Changed this line
    sort_by: Optional[str] = "date_posted",
    sort_desc: bool = True,
    db: Session = Depends(get_db)
):
    # Remove the join or make it a left join
    query = db.query(ProcessedJob)

    if status:
        query = query.filter(ProcessedJob.status.in_(status))

    sort_column = getattr(ProcessedJob, sort_by, ProcessedJob.date_posted)
    query = query.order_by(desc(sort_column) if sort_desc else sort_column)

    jobs = query.offset(skip).limit(limit).all()

    serializable_jobs = []
    for job in jobs:
        job_dict = {
            "id": job.id,
            "job_url": str(job.job_url),
            "job_source": job.raw_job_post.source if job.raw_job_post else None,
            "title": job.title,
            "company": job.company,
            "description": job.description,
            "location_raw": job.location_raw,
            "latitude": float(job.latitude) if job.latitude else None,
            "longitude": float(job.longitude) if job.longitude else None,
            "salary_type": job.salary_type.value if job.salary_type else None,
            "salary_min": float(job.salary_min) if job.salary_min else None,
            "salary_max": float(job.salary_max) if job.salary_max else None,
            "salary_currency": job.salary_currency,
            "requirements": job.requirements,
            "benefits": job.benefits,
            "job_type": job.job_type.value if job.job_type else None,
            "experience_level": job.experience_level,
            "remote_status": job.remote_status.value if job.remote_status else None,
            "status": job.status.value if job.status else "new",
            "date_posted": job.date_posted.isoformat() if job.date_posted else None,
            "created_at": job.created_at.isoformat() if job.created_at else None,
            "updated_at": job.updated_at.isoformat() if job.updated_at else None,
        }
        serializable_jobs.append(job_dict)

    return serializable_jobs


# Optionally, add an endpoint to get a single processed job
@router.get("/processed/{job_id}")
def read_processed_job(job_id: int, db: Session = Depends(get_db)):
    job = db.query(ProcessedJob).filter(ProcessedJob.id == job_id).first()
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    return {
        "id": job.id,
        "job_url": str(job.job_url),
        "title": job.title,
        "company": job.company,
        "description": job.description,
        "location_raw": job.location_raw,
        "latitude": float(job.latitude) if job.latitude else None,
        "longitude": float(job.longitude) if job.longitude else None,
        "salary_type": job.salary_type,
        "salary_min": float(job.salary_min) if job.salary_min else None,
        "salary_max": float(job.salary_max) if job.salary_max else None,
        "salary_currency": job.salary_currency,
        "requirements": job.requirements,
        "benefits": job.benefits,
        "job_type": job.job_type,
        "experience_level": job.experience_level,
        "remote_status": job.remote_status,
        "created_at": job.created_at.isoformat() if job.created_at else None,
        "updated_at": job.updated_at.isoformat() if job.updated_at else None,
        "raw_job_post_id": job.raw_job_post_id
    }


@router.put("/processed/{job_id}/status")
def update_job_status(job_id: int, status_update: dict, db: Session = Depends(get_db)):
    # Simple debug prints
    print("=== DEBUG ===")
    print(f"Job ID: {job_id}")
    print(f"Status Update: {status_update}")

    job = db.query(ProcessedJob).filter(ProcessedJob.id == job_id).first()
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    # Convert the incoming status to the correct enum format
    try:
        new_status = JobStatus[status_update["status"].upper()]  # This will match the enum
        job.status = new_status
        db.commit()
        db.refresh(job)
        return {
            "id": job.id,
            "status": job.status.value,
            "message": "Status updated successfully"
        }
    except KeyError:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid status. Must be one of: {[s.name for s in JobStatus]}"
        )


@router.get("/analytics")
def get_job_analytics(db: Session = Depends(get_db)):
    """Get analytics for processed jobs"""
    from sqlalchemy import func

    # Salary analytics
    salary_stats = db.query(
        func.avg(ProcessedJob.salary_min).label('avg_min'),
        func.avg(ProcessedJob.salary_max).label('avg_max'),
        ProcessedJob.experience_level
    ).group_by(ProcessedJob.experience_level).all()

    salary_distribution = [
        {
            'experience_level': stat.experience_level,
            'avg_min': float(stat.avg_min) if stat.avg_min else 0,
            'avg_max': float(stat.avg_max) if stat.avg_max else 0
        }
        for stat in salary_stats
    ]

    # Job type distribution
    job_types = db.query(
        ProcessedJob.job_type,
        func.count(ProcessedJob.id).label('count')
    ).group_by(ProcessedJob.job_type).all()

    job_type_dist = [
        {
            'job_type': str(jt.job_type.value) if jt.job_type else 'Unknown',
            'count': jt.count
        }
        for jt in job_types
    ]

    # Remote status distribution
    remote_stats = db.query(
        ProcessedJob.remote_status,
        func.count(ProcessedJob.id).label('count')
    ).group_by(ProcessedJob.remote_status).all()

    remote_dist = [
        {
            'remote_status': str(rs.remote_status.value) if rs.remote_status else 'Unknown',
            'count': rs.count
        }
        for rs in remote_stats
    ]

    return {
        'salary_distribution': salary_distribution,
        'job_type_distribution': job_type_dist,
        'remote_distribution': remote_dist
    }


@router.get("/status-analytics")
def get_status_analytics(db: Session = Depends(get_db)):
    from sqlalchemy import func

    status_by_date = db.query(
        func.date(ProcessedJob.updated_at).label('date'),
        func.max(ProcessedJob.updated_at).label('updated_at'),  # Latest update for the day
        func.count(case((ProcessedJob.status == JobStatus.NEW, 1))).label('new'),
        func.count(case((ProcessedJob.status == JobStatus.APPLIED, 1))).label('applied'),
        func.count(case((ProcessedJob.status == JobStatus.PHONE_SCREEN, 1))).label('phone_screen'),
        func.count(case((ProcessedJob.status == JobStatus.TECHNICAL, 1))).label('technical'),
        func.count(case((ProcessedJob.status == JobStatus.ONSITE, 1))).label('onsite'),
        func.count(case((ProcessedJob.status == JobStatus.OFFER, 1))).label('offer'),
        func.count(case((ProcessedJob.status == JobStatus.REJECTED, 1))).label('rejected')
    ).filter(
        ProcessedJob.updated_at.isnot(None)
    ).group_by(
        func.date(ProcessedJob.updated_at)
    ).order_by(
        func.date(ProcessedJob.updated_at)
    ).all()



    # Current status distribution
    current_status = db.query(
        ProcessedJob.status,
        func.count(ProcessedJob.id).label('count')
    ).group_by(ProcessedJob.status).all()

    current_stats = [
        {
            'status': str(stat.status.value),
            'count': stat.count
        }
        for stat in current_status if stat.status
    ]

    # Daily status counts
    today = date.today()

    timeline_data = [
        {
            'date': stat.date.strftime("%Y-%m-%d") if stat.date else None,
            'updated_at': stat.updated_at.isoformat() if stat.updated_at else None,
            'new': int(stat.new),
            'applied': int(stat.applied),
            'phone_screen': int(stat.phone_screen),
            'technical': int(stat.technical),
            'onsite': int(stat.onsite),
            'offer': int(stat.offer),
            'rejected': int(stat.rejected)
        }
        for stat in status_by_date
    ]

    return {
        'current_status': current_stats,
        'status_by_date': timeline_data
    }


@router.get("/status-analytics/day/{date}")
def get_day_status_details(date: str, db: Session = Depends(get_db)):
    try:
        target_date = datetime.strptime(date, "%Y-%m-%d").date()

        # Get all jobs updated on this date with their previous status
        jobs = db.query(
            ProcessedJob.id,
            ProcessedJob.title,
            ProcessedJob.company,
            ProcessedJob.status,
            ProcessedJob.updated_at,
            ProcessedJob.job_url,
            ProcessedJob.experience_level,
            ProcessedJob.location_raw
        ).filter(
            func.date(ProcessedJob.updated_at) == target_date
        ).order_by(ProcessedJob.updated_at).all()

        return [{
            "id": job.id,
            "title": job.title,
            "company": job.company,
            "status": job.status.value if job.status else None,
            "updated_at": job.updated_at.isoformat() if job.updated_at else None,
            "url": str(job.job_url) if job.job_url else None,
            "experience_level": job.experience_level,
            "location": job.location_raw
        } for job in jobs]

    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid date format")