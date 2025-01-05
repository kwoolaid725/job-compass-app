# app/schemas/job.py
from pydantic import BaseModel, HttpUrl, Field
from datetime import datetime
from typing import Optional, Literal
from decimal import Decimal

# Raw Job Posts schemas
class RawJobPostBase(BaseModel):
    job_url: HttpUrl
    raw_content: str
    source: Literal['indeed', 'linkedin', 'glassdoor', 'builtinchicago', 'others']
    processed: bool = False

class RawJobPostCreate(RawJobPostBase):
    pass

class RawJobPost(RawJobPostBase):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True

# Processed Jobs schemas
class ProcessedJobBase(BaseModel):
    job_url: HttpUrl
    title: str
    company: str
    description: str

    # Location fields
    location_raw: str  # Original location string from job posting
    latitude: Optional[Decimal] = Field(None, max_digits=9, decimal_places=6)
    longitude: Optional[Decimal] = Field(None, max_digits=9, decimal_places=6)

    # Salary fields
    salary_type: Optional[Literal['hourly', 'yearly', 'monthly', 'contract']] = None
    salary_min: Optional[Decimal] = Field(None, max_digits=10, decimal_places=2)
    salary_max: Optional[Decimal] = Field(None, max_digits=10, decimal_places=2)
    salary_currency: Optional[str] = Field(None, max_length=3)  # USD, EUR, etc.

    requirements: Optional[str] = None
    benefits: Optional[str] = None
    job_type: Optional[Literal['full-time', 'part-time', 'contract', 'temporary', 'internship']] = None
    experience_level: Optional[str] = None
    remote_status: Optional[Literal['remote', 'hybrid', 'on-site']] = None
class ProcessedJobCreate(ProcessedJobBase):
    pass

class ProcessedJob(ProcessedJobBase):
    id: int
    created_at: datetime
    updated_at: Optional[datetime] = None
    raw_job_post_id: int

    class Config:
        from_attributes = True