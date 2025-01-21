# app/api/v2/endpoints.py

from typing import List, Optional
from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import desc, or_, and_, func, case, literal
from sqlalchemy.exc import IntegrityError

# Import your SQLAlchemy models
from app.models.job import (
    ProcessedJob,
    RawJobPost,
    JobStatus,
    JobCategory,
    Skill,
    JobSource
)

# Import Pydantic schemas
from app.schemas.job import (
    RawJobPostCreate,
    RawJobPostRead,
    ProcessedJobCreate,
    ProcessedJobUpdate,
    ProcessedJobRead,
    CountResponse,
    JobStatusUpdate,
    SkillRead,
    SkillCreate
)

from app.database import get_db

router = APIRouter(prefix="/jobs", tags=["jobs"])


@router.get("/categories")  # This will result in /jobs/categories
def get_job_categories():
    """Get all job categories."""
    return {"categories": [category.value for category in JobCategory]}


# -------------------------------------------------
# RAW JOB ENDPOINTS
# -------------------------------------------------
@router.post("/raw/", response_model=RawJobPostRead, status_code=status.HTTP_201_CREATED)
def create_raw_job(job: RawJobPostCreate, db: Session = Depends(get_db)):
    """Create a new RawJobPost entry."""
    db_job = RawJobPost(**job.dict())
    db.add(db_job)
    db.commit()
    db.refresh(db_job)
    return db_job  # Pydantic (RawJobPostRead) will serialize this.


@router.get("/raw/", response_model=List[RawJobPostRead])
def read_raw_jobs(
        skip: int = 0,
        limit: int = Query(100, le=1000),
        db: Session = Depends(get_db)
):
    """Return a list of RawJobPosts."""
    jobs = db.query(RawJobPost).offset(skip).limit(limit).all()
    return jobs


# -------------------------------------------------
# PROCESSED JOB COUNT
# -------------------------------------------------
@router.get("/processed/count", response_model=CountResponse)
def get_processed_jobs_count(
        status: List[str] = Query(None),
        categories: List[str] = Query(None),
        skills: List[str] = Query(None),  # Added parameter
        search_query: Optional[str] = None,
        job_source: List[str] = Query(None),
        db: Session = Depends(get_db)
):
    query = db.query(func.count(ProcessedJob.id))
    query = query.join(ProcessedJob.raw_job_post)  # Always join with raw_job_post

    if status:
        query = query.filter(ProcessedJob.status.in_(status))

    if categories:
        query = query.filter(RawJobPost.job_category.in_(categories))

    if job_source:
        query = query.filter(RawJobPost.source.in_(job_source))

    if search_query:
        search_terms = search_query.split()
        search_filters = []
        for term in search_terms:
            search_filters.append(
                or_(
                    ProcessedJob.description.ilike(f"%{term}%"),
                    ProcessedJob.requirements.ilike(f"%{term}%"),
                    ProcessedJob.title.ilike(f"%{term}%")
                )
            )
        if search_filters:
            query = query.filter(and_(*search_filters))

    if skills:
        skill_filters = [ProcessedJob.skills.any(Skill.name.ilike(skill)) for skill in skills]
        query = query.filter(or_(*skill_filters))

    total_count = query.scalar()
    return {"total": total_count}


# -------------------------------------------------
# PROCESSED JOBS LIST
# -------------------------------------------------
@router.get("/processed/", response_model=List[ProcessedJobRead])
def read_processed_jobs(
        skip: int = 0,
        limit: int = Query(100, le=1000),
        status: Optional[List[JobStatus]] = Query(None),
        categories: Optional[List[JobCategory]] = Query(None),
        skills: Optional[List[str]] = Query(None),
        search_query: Optional[str] = None,
        job_source: Optional[List[JobSource]] = Query(None),
        sort_by: Optional[str] = "date_posted",
        sort_desc: bool = True,
        db: Session = Depends(get_db)
):
    query = db.query(ProcessedJob).join(RawJobPost, ProcessedJob.raw_job_post_id == RawJobPost.id).options(
        joinedload(ProcessedJob.skills),
        joinedload(ProcessedJob.raw_job_post)
    )

    # Apply filters
    if status:
        query = query.filter(ProcessedJob.status.in_(status))
    if categories:
        query = query.filter(RawJobPost.job_category.in_(categories))
    if job_source:
        query = query.filter(RawJobPost.source.in_(job_source))
    if skills:
        for skill_name in skills:
            query = query.filter(ProcessedJob.skills.any(Skill.name.ilike(skill_name)))
    if search_query:
        search_terms = search_query.split()
        search_filters = [
            ProcessedJob.title.ilike(f"%{term}%") |
            ProcessedJob.description.ilike(f"%{term}%") |
            ProcessedJob.requirements.ilike(f"%{term}%")
            for term in search_terms
        ]
        query = query.filter(and_(*search_filters))

    # Enhanced sorting with index awareness and null handling
    if sort_by in ["date_posted", "status", "remote_status", "updated_at"]:
        # Handle date fields with null values
        if sort_by in ["date_posted", "updated_at"]:
            sort_column = getattr(ProcessedJob, sort_by)
            if sort_desc:
                query = query.order_by(sort_column.desc().nulls_last())
            else:
                query = query.order_by(sort_column.asc().nulls_last())
        else:
            # Handle non-date indexed columns
            sort_column = getattr(ProcessedJob, sort_by)
            if sort_desc:
                query = query.order_by(sort_column.desc())
            else:
                query = query.order_by(sort_column.asc())
    else:
        # Fallback to date_posted for non-indexed columns
        if sort_desc:
            query = query.order_by(ProcessedJob.date_posted.desc().nulls_last())
        else:
            query = query.order_by(ProcessedJob.date_posted.asc().nulls_last())

    # Apply pagination
    jobs = query.offset(skip).limit(limit).all()

    return jobs

@router.get("/processed/all/", response_model=List[ProcessedJobRead])
def read_all_processed_jobs(
        categories: List[str] = Query(..., description="Job categories to filter."),
        status: Optional[List[JobStatus]] = Query(None, description="Filter by job status."),
        skills: Optional[List[str]] = Query(None, description="Filter by skills."),
        job_source: Optional[List[JobSource]] = Query(None, description="Filter by job source."),
        search_query: Optional[str] = Query(None, description="Search query for job title, description, or requirements."),
        db: Session = Depends(get_db)
):
    """
    Retrieve all processed jobs for specific categories without pagination.
    """
    try:
        query = db.query(ProcessedJob).join(RawJobPost, ProcessedJob.raw_job_post_id == RawJobPost.id).options(
            joinedload(ProcessedJob.skills),
            joinedload(ProcessedJob.raw_job_post)
        )

        # Apply filters
        if status:
            query = query.filter(ProcessedJob.status.in_(status))
        if categories:
            query = query.filter(RawJobPost.job_category.in_(categories))
        if job_source:
            query = query.filter(RawJobPost.source.in_(job_source))
        if skills:
            for skill_name in skills:
                query = query.filter(ProcessedJob.skills.any(Skill.name.ilike(skill_name)))
        if search_query:
            search_terms = search_query.split()
            search_filters = [
                ProcessedJob.title.ilike(f"%{term}%") |
                ProcessedJob.description.ilike(f"%{term}%") |
                ProcessedJob.requirements.ilike(f"%{term}%")
                for term in search_terms
            ]
            query = query.filter(and_(*search_filters))

        # Execute the query
        jobs = query.all()

        return jobs

    except Exception as e:
        raise HTTPException(status_code=500, detail="Internal Server Error.")

# -------------------------------------------------
# GET A SINGLE PROCESSED JOB
# -------------------------------------------------
@router.get("/processed/{job_id}", response_model=ProcessedJobRead)
def get_processed_job(job_id: int, db: Session = Depends(get_db)):
    """Retrieve a single ProcessedJob by ID."""
    job = db.query(ProcessedJob).options(
        joinedload(ProcessedJob.skills),
        joinedload(ProcessedJob.raw_job_post)
    ).filter(ProcessedJob.id == job_id).first()
    if not job:
        raise HTTPException(status_code=404, detail="Job not found.")
    return job


# -------------------------------------------------
# UPDATE A PROCESSED JOB
# -------------------------------------------------
@router.put("/processed/{job_id}", response_model=ProcessedJobRead)
def update_processed_job(job_id: int, job_update: ProcessedJobUpdate, db: Session = Depends(get_db)):
    """Update an existing ProcessedJob."""
    job = db.query(ProcessedJob).options(
        joinedload(ProcessedJob.skills)
    ).filter(ProcessedJob.id == job_id).first()
    if not job:
        raise HTTPException(status_code=404, detail="Job not found.")

    # Update fields except 'skills'
    update_data = job_update.dict(exclude_unset=True)
    skills_update = update_data.pop("skills", None)

    for field, value in update_data.items():
        setattr(job, field, value)

    # Handle skills if provided
    if skills_update is not None:
        # Normalize skill names to title case
        normalized_skills = {skill_name.title() for skill_name in skills_update}

        # Fetch existing skills from the database
        existing_skills = db.query(Skill).filter(Skill.name.in_(normalized_skills)).all()
        existing_skill_names = {skill.name for skill in existing_skills}

        # Determine which skills need to be created
        new_skill_names = normalized_skills - existing_skill_names
        new_skills = [Skill(name=name) for name in new_skill_names]

        # Add new skills to the session
        if new_skills:
            db.bulk_save_objects(new_skills)
            try:
                db.commit()
            except IntegrityError:
                db.rollback()
                raise HTTPException(status_code=500, detail="Error creating new skills.")

        # Refresh the list of existing skills after commit
        all_skills = db.query(Skill).filter(Skill.name.in_(normalized_skills)).all()

        # Associate all relevant skills with the job
        job.skills = all_skills

    db.commit()
    db.refresh(job)
    return job


# -------------------------------------------------
# UPDATE JOB STATUS
# -------------------------------------------------
@router.put("/processed/{job_id}/status", response_model=ProcessedJobRead)
def update_job_status(
        job_id: int,
        status_update: JobStatusUpdate,  # Using the new Pydantic schema
        db: Session = Depends(get_db)
):
    """
    Update the status of a job using a Pydantic schema.
    Request body format: { "status": "applied" }
    """
    job = db.query(ProcessedJob).filter(ProcessedJob.id == job_id).first()
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    job.status = status_update.status
    db.commit()
    db.refresh(job)
    return job


# -------------------------------------------------
# ANALYTICS
# -------------------------------------------------
@router.get("/analytics")
def get_job_analytics(db: Session = Depends(get_db)):
    """Get analytics for processed jobs: salary distribution, job types, remote statuses."""
    # Salary analytics
    salary_stats = (
        db.query(
            func.avg(ProcessedJob.salary_min).label("avg_min"),
            func.avg(ProcessedJob.salary_max).label("avg_max"),
            ProcessedJob.experience_level
        )
        .group_by(ProcessedJob.experience_level)
        .all()
    )

    salary_distribution = [
        {
            "experience_level": stat.experience_level,
            "avg_min": float(stat.avg_min) if stat.avg_min else 0,
            "avg_max": float(stat.avg_max) if stat.avg_max else 0
        }
        for stat in salary_stats
    ]

    # Job type distribution
    job_types = (
        db.query(
            ProcessedJob.job_type,
            func.count(ProcessedJob.id).label("count")
        )
        .group_by(ProcessedJob.job_type)
        .all()
    )
    job_type_dist = [
        {
            "job_type": jt.job_type.value if jt.job_type else "Unknown",
            "count": jt.count
        }
        for jt in job_types
    ]

    # Remote status distribution
    remote_stats = (
        db.query(
            ProcessedJob.remote_status,
            func.count(ProcessedJob.id).label("count")
        )
        .group_by(ProcessedJob.remote_status)
        .all()
    )
    remote_dist = [
        {
            "remote_status": rs.remote_status.value if rs.remote_status else "Unknown",
            "count": rs.count
        }
        for rs in remote_stats
    ]

    return {
        "salary_distribution": salary_distribution,
        "job_type_distribution": job_type_dist,
        "remote_distribution": remote_dist
    }


@router.get("/status-analytics")
def get_status_analytics(db: Session = Depends(get_db)):
    """Returns distribution of statuses by date + current status totals."""
    # Query for jobs created on each date (NEW status)
    new_jobs_by_date = (
        db.query(
            func.date(ProcessedJob.created_at).label("date"),
            func.max(ProcessedJob.created_at).label("event_time"),  # Use max time for the day
            literal("NEW").label("status"),
            func.count(ProcessedJob.id).label("count")
        )
        .filter(ProcessedJob.created_at.isnot(None))
        .group_by(func.date(ProcessedJob.created_at))
    )

    # Query for status changes by date (all other statuses)
    status_changes = (
        db.query(
            func.date(ProcessedJob.updated_at).label("date"),
            func.max(ProcessedJob.updated_at).label("event_time"),  # Use max time for the day
            ProcessedJob.status.label("status"),
            func.count(ProcessedJob.id).label("count")
        )
        .filter(ProcessedJob.updated_at.isnot(None))
        .filter(ProcessedJob.status != JobStatus.NEW)  # Exclude NEW status as it's handled by created_at
        .group_by(func.date(ProcessedJob.updated_at), ProcessedJob.status)
    )

    # Combine both queries
    combined_query = new_jobs_by_date.union_all(status_changes).order_by("event_time")
    status_events = combined_query.all()

    # Get current status totals
    current_status = (
        db.query(
            ProcessedJob.status,
            func.count(ProcessedJob.id).label("count")
        )
        .group_by(ProcessedJob.status)
        .all()
    )

    current_stats = [
        {"status": stat.status.value if stat.status else "NEW", "count": stat.count}
        for stat in current_status if stat.status
    ]

    # Convert status events to timeline data
    timeline_data = []
    for event in status_events:
        if event.event_time:
            entry = {
                "date": event.date.strftime("%Y-%m-%d"),
                "event_time": event.event_time.isoformat(),
                "status": event.status.value if isinstance(event.status, JobStatus) else event.status,
                "count": int(event.count)
            }
            timeline_data.append(entry)

    return {
        "current_status": current_stats,
        "status_events": timeline_data
    }


@router.get("/status-analytics/day/{date}", response_model=List[ProcessedJobRead])
def get_day_status_details(date: str, status: Optional[str] = None, db: Session = Depends(get_db)):
    """Returns a list of jobs updated on a specific day, optionally filtered by status."""
    try:
        target_date = datetime.strptime(date, "%Y-%m-%d").date()
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid date format. Use YYYY-MM-DD.")

    query = (
        db.query(ProcessedJob)
        .options(
            joinedload(ProcessedJob.skills),
            joinedload(ProcessedJob.raw_job_post)
        )
    )

    if status == "NEW":
        # For NEW status, look at created_at
        query = query.filter(func.date(ProcessedJob.created_at) == target_date)
    else:
        # For other statuses, look at updated_at and specific status
        query = query.filter(func.date(ProcessedJob.updated_at) == target_date)
        if status:
            query = query.filter(ProcessedJob.status == status)

    jobs = query.order_by(
        case(
            (status == "NEW", ProcessedJob.created_at),
            else_=ProcessedJob.updated_at
        )
    ).all()

    return jobs


@router.get("/sources")
def get_job_sources(db: Session = Depends(get_db)):
    """Get all unique job sources."""
    sources_query = db.query(RawJobPost.source).distinct().all()
    sources = [row[0] for row in sources_query if row[0] is not None]
    return {"sources": sorted(sources)}


# -------------------------------
# Skill Endpoints
# -------------------------------

@router.post("/skills/", response_model=SkillRead, status_code=status.HTTP_201_CREATED)
def create_skill(skill: SkillCreate, db: Session = Depends(get_db)):
    """Create a new skill."""
    existing_skill = db.query(Skill).filter(Skill.name.ilike(skill.name)).first()
    if existing_skill:
        raise HTTPException(status_code=400, detail="Skill already exists.")
    db_skill = Skill(name=skill.name.title())
    db.add(db_skill)
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(status_code=500, detail="Error creating the skill.")
    db.refresh(db_skill)
    return db_skill


@router.get("/skills/", response_model=List[SkillRead])
def get_all_skills(db: Session = Depends(get_db)):
    """Retrieve all skills."""
    skills = db.query(Skill).order_by(Skill.name).all()
    return skills


@router.get("/skills/{skill_id}", response_model=SkillRead)
def get_skill(skill_id: int, db: Session = Depends(get_db)):
    """Retrieve a single skill by ID."""
    skill = db.query(Skill).filter(Skill.id == skill_id).first()
    if not skill:
        raise HTTPException(status_code=404, detail="Skill not found.")
    return skill


@router.put("/skills/{skill_id}", response_model=SkillRead)
def update_skill(skill_id: int, skill_update: SkillCreate, db: Session = Depends(get_db)):
    """Update an existing skill."""
    skill = db.query(Skill).filter(Skill.id == skill_id).first()
    if not skill:
        raise HTTPException(status_code=404, detail="Skill not found.")
    # Check if the new name already exists
    existing_skill = db.query(Skill).filter(Skill.name.ilike(skill_update.name)).first()
    if existing_skill and existing_skill.id != skill_id:
        raise HTTPException(status_code=400, detail="Another skill with this name already exists.")
    skill.name = skill_update.name.title()
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(status_code=500, detail="Error updating the skill.")
    db.refresh(skill)
    return skill


@router.delete("/skills/{skill_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_skill(skill_id: int, db: Session = Depends(get_db)):
    """Delete a skill."""
    skill = db.query(Skill).filter(Skill.id == skill_id).first()
    if not skill:
        raise HTTPException(status_code=404, detail="Skill not found.")
    db.delete(skill)
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(status_code=500, detail="Error deleting the skill.")
    return

