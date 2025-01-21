# app/models/job.py

from enum import Enum
from sqlalchemy import (
    Table, Column, Integer, String, DateTime, Boolean, ForeignKey,
    Numeric, Enum as SQLAlchemyEnum
)
from sqlalchemy.orm import relationship
from sqlalchemy.sql import expression
from sqlalchemy.ext.compiler import compiles
from app.database import Base

# -------------------------------
# Custom Functions and Enums
# -------------------------------

# Custom function for Central timezone
class ChicagoTime(expression.FunctionElement):
    type = DateTime()
    inherit_cache = True

@compiles(ChicagoTime, 'postgresql')
def pg_chicago_time(element, compiler, **kw):
    # Using timezone() function which is more reliable in PostgreSQL
    return "timezone('America/Chicago', CURRENT_TIMESTAMP)"

# Define enums
class JobSource(str, Enum):
    INDEED = "indeed"
    LINKEDIN = "linkedin"
    GLASSDOOR = "glassdoor"
    BUILTINCHICAGO = "builtinchicago"
    OTHERS = "others"

class JobCategory(str, Enum):
    DATA_ENGINEER = "data_engineer"
    DATA_SCIENTIST = "data_scientist"
    PYTHON_DEVELOPER = "python_developer"
    SOFTWARE_ENGINEER = "software_engineer"
    MACHINE_LEARNING_ENGINEER = "machine_learning_engineer"
    DATA_ANALYST = "data_analyst"
    BUSINESS_INTELLIGENCE = "business_intelligence"
    DATABASE_ADMINISTRATOR = "database_administrator"
    DEVOPS_ENGINEER = "devops_engineer"
    OTHERS = "others"

class JobStatus(str, Enum):
    NEW = "new"
    APPLIED = "applied"
    SKIPPED = "skipped"
    PHONE_SCREEN = "phone_screen"
    TECHNICAL = "technical"
    ONSITE = "onsite"
    OFFER = "offer"
    REJECTED = "rejected"

class SalaryType(str, Enum):
    HOURLY = "hourly"
    YEARLY = "yearly"
    MONTHLY = "monthly"
    DAILY = "daily"
    WEEKLY = "weekly"
    CONTRACT = "contract"

class JobType(str, Enum):
    FULL_TIME = "full-time"
    PART_TIME = "part-time"
    CONTRACT = "contract"
    TEMPORARY = "temporary"
    INTERNSHIP = "internship"

class RemoteStatus(str, Enum):
    REMOTE = "remote"
    HYBRID = "hybrid"
    ONSITE = "on-site"

# -------------------------------
# Association Table
# -------------------------------

# Association Table for Many-to-Many Relationship between ProcessedJob and Skill
processed_job_skills = Table(
    'processed_job_skills',
    Base.metadata,
    Column('processed_job_id', Integer, ForeignKey('processed_jobs.id'), primary_key=True),
    Column('skill_id', Integer, ForeignKey('skills.id'), primary_key=True)
)

# -------------------------------
# Skill Model
# -------------------------------

class Skill(Base):
    __tablename__ = 'skills'

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, nullable=False, index=True)

    # Relationship back to ProcessedJob
    processed_jobs = relationship(
        "ProcessedJob",
        secondary=processed_job_skills,
        back_populates="skills"
    )

# -------------------------------
# RawJobPost Model
# -------------------------------

class RawJobPost(Base):
    __tablename__ = "raw_job_posts"

    id = Column(Integer, primary_key=True, index=True)
    job_url = Column(String, unique=True, nullable=False)
    raw_content = Column(String, nullable=False)
    source = Column(SQLAlchemyEnum(JobSource), nullable=False, index=True)
    job_category = Column(SQLAlchemyEnum(JobCategory), nullable=True, index=True)
    created_at = Column(DateTime(timezone=True), server_default=ChicagoTime())
    processed = Column(Boolean, default=False)
    salary_text = Column(String, nullable=True)
    salary_from_api = Column(String, nullable=True)  # New column

    # Relationship
    processed_job = relationship("ProcessedJob", back_populates="raw_job_post", uselist=False)

# -------------------------------
# ProcessedJob Model
# -------------------------------

class ProcessedJob(Base):
    __tablename__ = "processed_jobs"

    id = Column(Integer, primary_key=True, index=True)
    raw_job_post_id = Column(Integer, ForeignKey('raw_job_posts.id'), unique=True)
    job_url = Column(String, nullable=False)
    title = Column(String, nullable=False)
    company = Column(String, nullable=False)
    description = Column(String, nullable=False)

    # Additional Fields
    date_posted = Column(DateTime(timezone=True), nullable=True, index=True)
    location_raw = Column(String)
    latitude = Column(Numeric(9, 6), nullable=True)
    longitude = Column(Numeric(9, 6), nullable=True)
    salary_type = Column(SQLAlchemyEnum(SalaryType), nullable=True)
    salary_min = Column(Numeric(10, 2), nullable=True)
    salary_max = Column(Numeric(10, 2), nullable=True)
    salary_currency = Column(String(3), nullable=True)  # USD, EUR, etc.
    requirements = Column(String, nullable=True)
    benefits = Column(String, nullable=True)
    job_type = Column(SQLAlchemyEnum(JobType), nullable=True)
    experience_level = Column(String, nullable=True)
    remote_status = Column(SQLAlchemyEnum(RemoteStatus), nullable=True, index=True)
    status = Column(SQLAlchemyEnum(JobStatus), default=JobStatus.NEW, nullable=False, index=True)

    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=ChicagoTime())
    updated_at = Column(DateTime(timezone=True), onupdate=ChicagoTime())

    # Relationships
    raw_job_post = relationship("RawJobPost", back_populates="processed_job")
    skills = relationship(
        "Skill",
        secondary=processed_job_skills,
        back_populates="processed_jobs",
        cascade="all, delete"
    )
