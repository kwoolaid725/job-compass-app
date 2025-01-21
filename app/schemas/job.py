# app/schemas/job.py

from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, Field

# Import your enums from the models
from app.models.job import (
    JobSource,
    JobCategory,
    JobStatus,
    SalaryType,
    JobType,
    RemoteStatus
)

# -------------------------------
# Skill Schemas
# -------------------------------

class SkillRead(BaseModel):
    """Schema for reading Skill data."""
    id: int
    name: str

    class Config:
        orm_mode = True

class SkillCreate(BaseModel):
    """Schema for creating a new Skill."""
    name: str

    class Config:
        orm_mode = True

# -------------------------------
# RawJobPost Schemas
# -------------------------------

class RawJobPostBase(BaseModel):
    """Fields that are shared in create & read contexts."""
    job_url: str
    raw_content: str
    source: JobSource
    job_category: Optional[JobCategory] = None
    salary_text: Optional[str] = None
    salary_from_api: Optional[str] = None
    processed: Optional[bool] = None

class RawJobPostCreate(RawJobPostBase):
    """Schema used when creating a new RawJobPost."""
    pass

class RawJobPostUpdate(BaseModel):
    """Schema used when updating an existing RawJobPost."""
    job_url: Optional[str] = None
    raw_content: Optional[str] = None
    source: Optional[JobSource] = None
    job_category: Optional[JobCategory] = None
    salary_text: Optional[str] = None
    salary_from_api: Optional[str] = None
    processed: Optional[bool] = None

class RawJobPostRead(RawJobPostBase):
    """Schema returned when reading a RawJobPost (includes id & timestamps)."""
    id: int
    created_at: datetime

    class Config:
        orm_mode = True

# -------------------------------
# ProcessedJob Schemas
# -------------------------------

class ProcessedJobBase(BaseModel):
    """Fields common to create & read for ProcessedJob."""
    job_url: str
    title: str
    company: str
    description: Optional[str] = None
    date_posted: Optional[datetime] = None

    location_raw: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None

    salary_type: Optional[SalaryType] = None
    salary_min: Optional[float] = None
    salary_max: Optional[float] = None
    salary_currency: Optional[str] = None

    requirements: Optional[str] = None
    benefits: Optional[str] = None
    job_type: Optional[JobType] = None
    experience_level: Optional[str] = None
    remote_status: Optional[RemoteStatus] = None

    # If you want a default:
    # status: Optional[JobStatus] = JobStatus.NEW
    #
    # or, if you prefer no default (so it's explicit):
    status: Optional[JobStatus] = None

class ProcessedJobCreate(ProcessedJobBase):
    """Used when creating a new ProcessedJob via POST."""
    raw_job_post_id: Optional[int] = None
    skills: Optional[List[str]] = Field(default_factory=list, description="List of skill names associated with the job.")

class ProcessedJobUpdate(BaseModel):
    """Used when updating an existing ProcessedJob."""
    title: Optional[str] = None
    company: Optional[str] = None
    description: Optional[str] = None
    date_posted: Optional[datetime] = None

    location_raw: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None

    salary_type: Optional[SalaryType] = None
    salary_min: Optional[float] = None
    salary_max: Optional[float] = None
    salary_currency: Optional[str] = None

    requirements: Optional[str] = None
    benefits: Optional[str] = None
    job_type: Optional[JobType] = None
    experience_level: Optional[str] = None
    remote_status: Optional[RemoteStatus] = None

    status: Optional[JobStatus] = None
    skills: Optional[List[str]] = Field(default_factory=list, description="List of skill names associated with the job.")

class ProcessedJobRead(BaseModel):
    """Returned when reading a ProcessedJob (includes id & timestamps)."""
    id: int
    raw_job_post_id: Optional[int] = None
    job_url: str
    title: str
    company: str
    description: Optional[str] = None
    date_posted: Optional[datetime] = None

    location_raw: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None

    salary_type: Optional[SalaryType] = None
    salary_min: Optional[float] = None
    salary_max: Optional[float] = None
    salary_currency: Optional[str] = None

    requirements: Optional[str] = None
    benefits: Optional[str] = None
    job_type: Optional[JobType] = None
    experience_level: Optional[str] = None
    remote_status: Optional[RemoteStatus] = None

    status: JobStatus
    created_at: datetime
    updated_at: Optional[datetime] = None

    raw_job_post: Optional[RawJobPostRead] = None
    skills: List[SkillRead] = Field(
        default_factory=list,
        description="List of skills associated with the job."
    )

    class Config:
        orm_mode = True

# -------------------------------
# Utility Schemas
# -------------------------------

class CountResponse(BaseModel):
    """Generic response for counting results."""
    total: int

class JobStatusUpdate(BaseModel):
    """Schema for updating just the 'status' field."""
    status: JobStatus
