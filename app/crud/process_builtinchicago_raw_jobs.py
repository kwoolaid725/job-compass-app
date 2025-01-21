# app/crud/processed_job.py
from sqlalchemy.orm import Session
import json
from app.models.job import (
    ProcessedJob,
    RawJobPost,
    SalaryType,
    JobType,
    RemoteStatus,
    JobSource
)
from decimal import Decimal
from datetime import datetime, timedelta
from zoneinfo import ZoneInfo
import re
from typing import Dict, Any, Optional, List, Tuple
from bs4 import BeautifulSoup
from geopy.geocoders import Nominatim
from geopy.exc import GeocoderTimedOut, GeocoderServiceError
from decimal import Decimal
import random
from functools import lru_cache

# Define Central timezone
CENTRAL_TZ = ZoneInfo("America/Chicago")

@lru_cache(maxsize=1000)
def _geocode_base_location(location_str: str) -> Optional[Tuple[Decimal, Decimal]]:
    """Get the base coordinates for a location."""
    try:
        geolocator = Nominatim(user_agent="job_board_geocoder")
        location = geolocator.geocode(location_str, timeout=10)
        if location:
            return (Decimal(str(location.latitude)), Decimal(str(location.longitude)))
        return None
    except (GeocoderTimedOut, GeocoderServiceError) as e:
        print(f"Geocoding error for {location_str}: {str(e)}")
        return None

def geocode_location(location_str: str) -> Optional[Tuple[Decimal, Decimal]]:
    """Get coordinates with random offset for a location."""
    base_coords = _geocode_base_location(location_str)
    if base_coords:
        # Add random offset (roughly within 2km)
        lat_offset = random.uniform(-0.02, 0.02)
        lon_offset = random.uniform(-0.02, 0.02)

        final_lat = round(base_coords[0] + Decimal(str(lat_offset)), 7)
        final_lon = round(base_coords[1] + Decimal(str(lon_offset)), 7)

        return (final_lat, final_lon)
    return None



def _extract_base_job_info_builtinchicago(job_details: Dict[str, Any]) -> Dict[str, Any]:
    """Extract basic job information from BuiltInChicago format"""
    return {
        "title": job_details.get('title'),
        "company": job_details.get('hiringOrganization', {}).get('name'),
        "description": job_details.get('description'),
        "job_url": None  # Will be set from raw_data later
    }

def _extract_builtinchicago_job_details(raw_content: str) -> dict:
    """Extract job details from BuiltInChicago JSON-LD format"""
    try:
        # First parse the raw content
        if isinstance(raw_content, str):
            data = json.loads(raw_content)
        else:
            data = raw_content

        # If raw_content is already parsed, check for raw_content field
        if isinstance(data, dict) and 'raw_content' in data:
            inner_data = json.loads(data['raw_content'])
            if isinstance(inner_data, dict):
                data = inner_data
            elif isinstance(inner_data, list):
                # If it's a list, take the first item that looks like job data
                for item in inner_data:
                    if isinstance(item, dict) and ('json_ld' in item or '@type' in item):
                        data = item
                        break
                else:
                    raise ValueError("No valid job data found in list")

        # Now extract json_ld from data
        if isinstance(data, dict):
            if 'json_ld' in data:
                return data['json_ld']
            elif '@type' in data and data['@type'] == 'JobPosting':
                return data
            else:
                raise ValueError("Could not find JobPosting data")

        raise ValueError(f"Unexpected data structure: {type(data)}")

    except Exception as e:
        # print(f"DEBUG: Raw content preview: {str(raw_content)[:200]}")
        raise ValueError(f"Failed to parse BuiltInChicago job details: {str(e)}")


def _extract_location_info_builtinchicago(job_details: Dict[str, Any]) -> Dict[str, Any]:
    """Extract location information from Builtin Chicago JSON-LD format"""
    location_info = {
        "location_raw": None,
        "latitude": None,
        "longitude": None
    }

    try:
        # If job_details is a string, parse it first
        if isinstance(job_details, str):
            job_details = json.loads(job_details)

        # Check if 'json_ld' exists in the dictionary
        if 'json_ld' in job_details:
            job_details = job_details['json_ld']

        # First try to get the addressLocality from jobLocation
        job_location = job_details.get('jobLocation', {})
        address = job_location.get('address', {})
        location_str = address.get('addressLocality')

        # Check for remote status
        job_location_type = job_details.get('jobLocationType')
        is_remote = job_location_type == 'TELECOMMUTE'

        if location_str:
            # Set the raw location
            location_info['location_raw'] = location_str

            # Get coordinates using geocoding
            coords = geocode_location(location_str)
            if coords:
                location_info['latitude'] = str(coords[0])
                location_info['longitude'] = str(coords[1])

        # Handle remote jobs
        if is_remote:
            if not location_info['location_raw']:
                location_info['location_raw'] = 'Remote, USA'
            # For remote jobs, we might still want to keep the coordinates if we found them

    except Exception as e:
        print(f"Error extracting location: {e}")

    return location_info


def _extract_date_posted_builtinchicago(job_details: Dict[str, Any]) -> Optional[datetime]:
    """Extract posting date from BuiltInChicago format"""
    if date_posted := job_details.get('datePosted'):
        return datetime.fromisoformat(date_posted).replace(tzinfo=CENTRAL_TZ)
    return None


def _extract_job_type_builtinchicago(job_details: Dict[str, Any]) -> Optional[str]:
    """Extract job type from BuiltInChicago format"""
    employment_type = job_details.get('employmentType', '').lower()
    if not employment_type:
        return None

    if 'full' in employment_type:
        return 'full-time'
    elif 'part' in employment_type:
        return 'part-time'
    elif 'contract' in employment_type:
        return 'contract'
    return None


def _extract_salary_info_builtinchicago(job_details: Dict[str, Any]) -> dict:
    """Extract salary information from BuiltInChicago format"""
    salary_info = {
        'salary_min': None,
        'salary_max': None,
        'salary_type': None
    }

    if base_salary := job_details.get('baseSalary', {}):
        if value_info := base_salary.get('value', {}):
            min_value = value_info.get('minValue')
            max_value = value_info.get('maxValue')
            unit = value_info.get('unitText', '').lower()

            # Only set values if they're non-zero
            if min_value and min_value > 0:
                salary_info['salary_min'] = int(min_value)
            if max_value and max_value > 0:
                salary_info['salary_max'] = int(max_value)

            # Only set type if we have valid salary values
            if salary_info['salary_min'] or salary_info['salary_max']:
                if 'year' in unit:
                    salary_info['salary_type'] = 'yearly'
                elif 'month' in unit:
                    salary_info['salary_type'] = 'monthly'
                elif 'hour' in unit:
                    salary_info['salary_type'] = 'hourly'

    # Only return fields that have non-None values
    return {k: v for k, v in salary_info.items() if v is not None}

def _extract_remote_status_builtinchicago(job_details: Dict[str, Any]) -> Optional[str]:
    """Extract remote status from BuiltInChicago format"""
    job_location_type = job_details.get('jobLocationType', '').lower()
    description = job_details.get('description', '').lower()

    if 'telecommute' in job_location_type or 'remote' in job_location_type:
        return 'remote'

    # Check description as fallback
    if 'hybrid' in description:
        return 'hybrid'
    elif 'on-site' in description or 'onsite' in description:
        return 'on-site'
    elif 'remote' in description or '100% remote' in description:
        return 'remote'

    return None


def process_job_data_builtinchicago(raw_content: str) -> Dict[str, Any]:
    """Process and extract all job information from BuiltIn raw content"""
    try:
        raw_data = json.loads(raw_content) if isinstance(raw_content, str) else raw_content
        job_details = _extract_builtinchicago_job_details(raw_content)

        # Get basic info
        processed_data = _extract_base_job_info_builtinchicago(job_details)
        processed_data['job_url'] = raw_data.get('job_url')

        # Get location info
        location_info = _extract_location_info_builtinchicago(job_details)
        processed_data.update(location_info)

        # Get date posted
        if date_posted := _extract_date_posted_builtinchicago(job_details):
            processed_data['date_posted'] = date_posted

        # Get job type
        if job_type := _extract_job_type_builtinchicago(job_details):
            processed_data['job_type'] = job_type

        # Get remote status
        if remote_status := _extract_remote_status_builtinchicago(job_details):
            processed_data['remote_status'] = remote_status

        # Get salary info
        salary_info = _extract_salary_info_builtinchicago(job_details)
        if salary_info:
            processed_data.update(salary_info)

        return processed_data

    except Exception as e:
        print(f"Error processing BuiltIn job data: {e}")
        raise ValueError(f"Failed to process BuiltIn job data: {str(e)}")