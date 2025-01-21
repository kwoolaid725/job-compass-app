from typing import Dict, Any, Optional, List
from datetime import datetime, timedelta
from zoneinfo import ZoneInfo
from decimal import Decimal
import json
import os

from app.models.job import (
    SalaryType,
    JobType,
    RemoteStatus,
)
import re


def process_job_data_indeed(raw_content: str) -> Dict[str, Any]:
    """Process Indeed job data into standardized format"""
    try:
        # Parse JSON content
        if isinstance(raw_content, str):
            data = json.loads(raw_content)
        else:
            data = raw_content

        # Navigate to job details within Indeed's nested structure
        job_data = None
        if isinstance(data, dict):
            host_result = data.get('host_query_execution_result', {})
            job_data = host_result.get('data', {}).get('jobData', {}).get('results', [{}])[0].get('job', {})

        if not job_data:
            raise ValueError("Could not find job data in raw content")

        processed_data = {}

        # Basic Fields
        processed_data["title"] = job_data.get("title", "")
        processed_data["company"] = job_data.get("sourceEmployerName", "")
        processed_data["job_url"] = job_data.get("url", "")

        description = job_data.get("description", {})
        if isinstance(description, dict):
            description_text = description.get('text', '') or description.get('html', '') or ''
        else:
            description_text = str(description) if description else ''

        processed_data['description'] = description_text

        # Date Processing
        if date_published := job_data.get("datePublished"):
            processed_data["date_posted"] = datetime.fromtimestamp(
                int(date_published) / 1000,
                tz=ZoneInfo("America/Chicago")
            )

        # Location Processing
        location = job_data.get("location", {})
        processed_data["location_raw"] = location.get("formatted", {}).get("long", "")
        if location.get("latitude"):
            processed_data["latitude"] = Decimal(str(location["latitude"]))
        if location.get("longitude"):
            processed_data["longitude"] = Decimal(str(location["longitude"]))

        # Job Type Processing
        job_type = _extract_job_type_indeed(job_data.get("attributes", []))
        if job_type:
            processed_data["job_type"] = job_type

        # Remote Status
        remote_status = _extract_remote_status_indeed(job_data)
        if remote_status:
            processed_data["remote_status"] = remote_status

        # Experience Level
        experience_level = _extract_experience_level_indeed(job_data.get("attributes", []))
        if experience_level:
            processed_data["experience_level"] = experience_level

        # Benefits
        benefits = _extract_benefits_indeed(job_data)
        if benefits:
            processed_data["benefits"] = benefits

        # Requirements 
        requirements = _extract_requirements_indeed(job_data.get("attributes", []))
        if requirements:
            processed_data["requirements"] = requirements

        return processed_data

    except Exception as e:
        raise ValueError(f"Failed to process Indeed job data: {str(e)}")


def _extract_job_type_indeed(attributes: List[Dict]) -> Optional[JobType]:
    """Extract job type from Indeed attributes"""
    job_types_map = {
        'Full-time': JobType.FULL_TIME,
        'Part-time': JobType.PART_TIME,
        'Contract': JobType.CONTRACT,
        'Temporary': JobType.TEMPORARY,
        'Internship': JobType.INTERNSHIP,
        'Freelance': JobType.CONTRACT
    }

    for attr in attributes:
        if isinstance(attr, dict) and attr.get('label') in job_types_map:
            return job_types_map[attr['label']]
    return None


def _extract_remote_status_indeed(job_data: Dict) -> Optional[RemoteStatus]:
    """Extract remote status from job data"""
    attributes = job_data.get('attributes', [])
    description = job_data.get('description', {}).get('text', '').lower()

    for attr in attributes:
        if isinstance(attr, dict):
            label = attr.get('label', '').lower()
            if 'remote' in label:
                return RemoteStatus.REMOTE
            elif 'hybrid' in label:
                return RemoteStatus.HYBRID
            elif 'in-person' in label or 'on-site' in label:
                return RemoteStatus.ONSITE

    # Fallback to description text
    if 'remote' in description and 'hybrid' in description:
        return RemoteStatus.HYBRID
    elif 'remote' in description:
        return RemoteStatus.REMOTE
    elif 'on-site' in description or 'onsite' in description:
        return RemoteStatus.ONSITE

    return None


def _extract_experience_level_indeed(attributes: List[Dict]) -> Optional[str]:
    """Extract experience level from Indeed attributes"""
    experience_keywords = [
        "Entry level", "Mid level", "Senior level", "Senior"
        "Junior", "Associate", "Principal", "Lead", "Staff"
    ]

    for attr in attributes:
        if isinstance(attr, dict) and any(
                keyword.lower() in attr.get('label', '').lower()
                for keyword in experience_keywords
        ):
            return attr['label']
    return None


def _extract_benefits_indeed(job_data: Dict) -> Optional[str]:
    """Extract benefits information"""
    benefits = job_data.get('benefits', [])
    if benefits and isinstance(benefits, list):
        benefit_labels = [b.get('label') for b in benefits if isinstance(b, dict) and b.get('label')]
        return json.dumps(benefit_labels) if benefit_labels else None
    return None


def _extract_requirements_indeed(attributes: List[Dict]) -> Optional[str]:
    """Extract requirements from Indeed attributes"""
    requirement_attrs = []
    for attr in attributes:
        if isinstance(attr, dict) and attr.get('label'):
            label = attr['label']
            if any(keyword in label.lower() for keyword in [
                'experience', 'skill', 'knowledge', 'proficiency',
                'qualification', 'certification', 'degree'
            ]):
                requirement_attrs.append(label)

    return json.dumps(requirement_attrs) if requirement_attrs else None