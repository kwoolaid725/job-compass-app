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
from typing import Dict, Any, Optional, List
from bs4 import BeautifulSoup
from geopy.geocoders import Nominatim
from geopy.exc import GeocoderTimedOut, GeocoderServiceError
from functools import lru_cache
from decimal import Decimal
import random

# Define Central timezone
CENTRAL_TZ = ZoneInfo("America/Chicago")

# Add this function to cache geocoding results and avoid repeated API calls
@lru_cache(maxsize=1000)
def _geocode_base_location(location_str: str) -> Optional[tuple[Decimal, Decimal]]:
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


def geocode_location(location_str: str) -> Optional[tuple[Decimal, Decimal]]:
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

# Modify the _extract_location_info_linkedin function
def _extract_location_info_linkedin(job_details: Dict[str, Any]) -> Dict[str, Any]:
    """Extract location information from LinkedIn format"""
    location_info = {
        "location_raw": None,
        "latitude": None,
        "longitude": None
    }

    # First try to get location from job_insights
    if job_insights := job_details.get("job_insight", []):
        for insight in job_insights:
            if isinstance(insight, str):
                # Extract location pattern: e.g., "San Jose, CA"
                parts = insight.split("·")
                for part in parts:
                    if "," in part and len(part.split(",")[-1].strip()) == 2:
                        location_info["location_raw"] = part.strip()
                        break
            if location_info["location_raw"]:
                break

    # If not found, try getting from details_modules
    if not location_info["location_raw"]:
        if details := job_details.get('details_modules', []):
            for detail in details:
                if isinstance(detail, str) and 'Pay range in' in detail:
                    location = detail.split('Pay range in ')[1].split(',')[0]
                    location_info["location_raw"] = location
                    break

    # If we found a location, try to geocode it
    if location_info["location_raw"]:
        coords = geocode_location(location_info["location_raw"])
        if coords:
            location_info["latitude"], location_info["longitude"] = coords
            # print(f"DEBUG: Geocoded {location_info['location_raw']} to lat: {location_info['latitude']}, lon: {location_info['longitude']}")

    return location_info



# Modify the process_job_data_linkedin function to include async
def process_job_data_linkedin(raw_content: str) -> Dict[str, Any]:
    """Process and extract all job information from LinkedIn raw content."""
    try:
        # print("\nDEBUG: Starting process_job_data_linkedin")

        # Parse raw content
        if isinstance(raw_content, str):
            raw_data = json.loads(raw_content)
            if 'raw_content' in raw_data:
                job_details = json.loads(raw_data['raw_content'])
            else:
                job_details = raw_data
        else:
            job_details = raw_content

        processed_data = {}

        # Basic job info
        processed_data.update(_extract_base_job_info_linkedin(job_details))

        # Extract location with coordinates
        location_info = _extract_location_info_linkedin(job_details)
        processed_data.update(location_info)

        # Extract posting date
        if date_posted := _extract_date_posted_linkedin(job_details):
            processed_data["date_posted"] = date_posted

        # Extract job type
        if job_type := _extract_job_type_linkedin(job_details):
            processed_data["job_type"] = job_type

        # Extract remote status
        if remote_status := _extract_remote_status_linkedin(job_details):
            processed_data["remote_status"] = remote_status

        # Extract experience level
        if experience_level := _extract_experience_level_linkedin(job_details):
            processed_data["experience_level"] = experience_level

        # Extract benefits
        if benefits := _extract_benefits_linkedin(job_details):
            processed_data["benefits"] = benefits

        # Extract salary information
        if salary_info := _extract_salary_info_linkedin(job_details):
            processed_data.update(salary_info)

        # print("DEBUG: Successfully processed job data")
        return processed_data

    except json.JSONDecodeError as e:
        print(f"DEBUG: JSON decode error: {str(e)}")
        raise ValueError(f"Failed to parse LinkedIn JSON data: {str(e)}")
    except Exception as e:
        print(f"DEBUG: Processing error: {str(e)}")
        raise ValueError(f"Failed to process LinkedIn job data: {str(e)}")



def _extract_job_details_linkedin(raw_content: str) -> dict:
    """Extract job details from LinkedIn format"""
    try:
        job_data = json.loads(raw_content) if isinstance(raw_content, str) else raw_content
        return job_data
    except Exception as e:
        raise ValueError(f"Failed to parse LinkedIn job details: {str(e)}")


def _extract_salary_info_linkedin(job_details: Dict[str, Any]) -> Dict[str, Any]:
    """Extract salary information from LinkedIn job details"""
    salary_info = {
        "salary_min": None,
        "salary_max": None,
        "salary_type": None
    }

    # Multiple sources to check for salary
    salary_sources = [
        job_details.get('job_insight', []),
        job_details.get('description', '')
    ]

    # Regex patterns to catch salary ranges with K notation and full numbers
    range_patterns = [
        r'\$(\d+)K\s*[-/]\s*\$?(\d+)K',  # Matches $85K-$92K or $85K/$92K
        r'\$(\d+),?(\d{3})\s*[-/]\s*\$?(\d+),?(\d{3})',  # Matches $85,000-$92,000
        r'salary of \$(\d+)k\s*-\s*\$?(\d+)k',  # Matches "salary of $85k-$92k"
        r'\$(\d+)k\s*-\s*\$?(\d+)k'  # Alternative k notation
    ]

    def parse_salary(text: str) -> Optional[Dict[str, int]]:
        """Parse salary from text, returning dict with min and max or None"""
        for pattern in range_patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                groups = match.groups()

                # K notation (2 groups)
                if len(groups) == 2:
                    try:
                        return {
                            "salary_min": int(groups[0]) * 1000,
                            "salary_max": int(groups[1]) * 1000
                        }
                    except ValueError:
                        continue

                # Full number notation (4 groups)
                elif len(groups) == 4:
                    try:
                        return {
                            "salary_min": int(f"{groups[0]}{groups[1]}"),
                            "salary_max": int(f"{groups[2]}{groups[3]}")
                        }
                    except ValueError:
                        continue

        return None

    for source in salary_sources:
        # Convert to string and lowercase for consistent processing
        if isinstance(source, list):
            source_text = ' '.join(str(s) for s in source).lower()
        else:
            source_text = str(source).lower()

        # Try to parse salary from the source
        parsed_salary = parse_salary(source_text)

        if parsed_salary:
            salary_info.update(parsed_salary)
            salary_info['salary_type'] = 'yearly'
            break

    return {k: v for k, v in salary_info.items() if v is not None}

def _extract_date_posted_linkedin(job_details: Dict[str, Any]) -> Optional[datetime]:
    """Extract posting date from LinkedIn job details"""
    if job_insights := job_details.get("job_insight", []):
        for insight in job_insights:
            if "ago" in insight.lower():
                try:
                    time_str = insight.lower().replace("reposted", "").strip()
                    time_parts = [part.strip() for part in time_str.split("·") if "ago" in part]
                    if time_parts:
                        time_str = time_parts[0]
                        current_time = datetime.now(CENTRAL_TZ)
                        if "hour" in time_str:
                            hours = int(time_str.split()[0])
                            return current_time - timedelta(hours=hours)
                        elif "day" in time_str:
                            days = int(time_str.split()[0])
                            return current_time - timedelta(days=days)
                        elif "week" in time_str:
                            weeks = int(time_str.split()[0])
                            return current_time - timedelta(weeks=weeks)
                        elif "month" in time_str:
                            months = int(time_str.split()[0])
                            return current_time - timedelta(days=months * 30)
                except Exception as e:
                    print(f"Warning: Error parsing date: {e}")
    return None


def _extract_job_type_linkedin(job_details: Dict[str, Any]) -> Optional[JobType]:
    """Extract job type from LinkedIn job details"""
    # Check job insights
    if job_insights := job_details.get("job_insight", []):
        for insight in job_insights:
            if "Full-time" in insight:
                return JobType.FULL_TIME
            elif "Part-time" in insight:
                return JobType.PART_TIME
            elif "Contract" in insight:
                return JobType.CONTRACT
            elif "Internship" in insight:
                return JobType.INTERNSHIP

    # Check description as fallback
    description = job_details.get('description', '').lower()
    if "full time" in description or "full-time" in description:
        return JobType.FULL_TIME
    elif "part time" in description or "part-time" in description:
        return JobType.PART_TIME
    elif "contract" in description or "contractor" in description:
        return JobType.CONTRACT
    elif "intern" in description or "internship" in description:
        return JobType.INTERNSHIP

    return None


def _extract_experience_level_linkedin(job_details: Dict[str, Any]) -> Optional[str]:
    """Extract experience level from LinkedIn job details"""
    # First check job insights
    if job_insights := job_details.get('job_insight', []):
        level_mapping = {
            'Entry level': 'Entry Level',
            'Associate': 'Associate',
            'Senior level': 'Senior Level',
            'Senior': 'Senior Level',
            'Mid': 'Mid Level',
            'Principal': ' Principal Level',
            'Executive': 'Executive Level',
            'Director': 'Director Level'
        }
        for insight in job_insights:
            for key, value in level_mapping.items():
                if key in insight:
                    return value

    # Check years of experience in description as fallback
    description = job_details.get('description', '').lower()
    experience_patterns = [
        (r'\b([0-9]+)\+?\s*(?:years?|yrs?)(?:\s+of)?\s+(?:experience|exp)\b', {
            range(0, 3): 'Entry Level',
            range(3, 5): 'Mid Level',
            range(5, 8): 'Senior Level',
            range(8, 100): 'Executive Level'
        })
    ]

    for pattern, level_ranges in experience_patterns:
        if match := re.search(pattern, description):
            years = int(match.group(1))
            for year_range, level in level_ranges.items():
                if years in year_range:
                    return level

    return None



def _extract_base_job_info_linkedin(raw_content: str) -> Dict[str, Any]:
    """Extract basic job information from LinkedIn format"""
    job_details = json.loads(raw_content) if isinstance(raw_content, str) else raw_content
    return {
        "title": job_details.get("title", ""),
        "company": job_details.get("company", ""),
        "description": job_details.get("description", ""),
        "job_url": job_details.get("job_url", "")
    }



def _extract_benefits_linkedin(job_details: Dict[str, Any]) -> Optional[str]:
    """Extract benefits information from LinkedIn format"""
    benefits = []

    # Check multiple sources for benefits
    sources_to_check = [
        job_details.get('segment_cards', []),
        job_details.get('details_modules', []),
        job_details.get('description', '')
    ]

    # Benefit markers to look for
    benefit_markers = [
        'Featured benefits',
        'Benefits',
        'Perks & Benefits',
        'Our Benefits'
    ]

    # Function to extract benefits from a section
    def _extract_benefits_from_section(section):
        if not isinstance(section, str):
            return []

        # Convert to lowercase for case-insensitive matching
        section_lower = section.lower()

        # Look for benefit markers
        for marker in benefit_markers:
            marker_lower = marker.lower()
            if marker_lower in section_lower:
                try:
                    # Split by the marker and take the part after it
                    benefits_section = section.split(marker)[-1]

                    # Try different splitting methods
                    potential_benefits = []
                    split_methods = [
                        benefits_section.split('\n\n')[0].split('\n'),  # Split by newlines
                        benefits_section.split(','),  # Split by comma
                    ]

                    for method in split_methods:
                        potential_benefits = [
                            b.strip() for b in method
                            if b.strip() and
                               b.strip().lower() not in marker_lower and
                               len(b.strip()) > 2  # Avoid very short strings
                        ]

                        if potential_benefits:
                            return potential_benefits
                except Exception as e:
                    print(f"Benefits extraction error: {e}")

        return []

    # Search through all sources
    for source in sources_to_check:
        if isinstance(source, list):
            for item in source:
                found_benefits = _extract_benefits_from_section(item)
                if found_benefits:
                    benefits.extend(found_benefits)
        else:
            found_benefits = _extract_benefits_from_section(source)
            if found_benefits:
                benefits.extend(found_benefits)

    # Remove duplicates while preserving order
    benefits = list(dict.fromkeys(benefits))

    # Print debug information
    # print("DEBUG: Extracted benefits:", benefits)

    return json.dumps(benefits) if benefits else None

#


def _extract_remote_status_linkedin(job_details: Dict[str, Any]) -> Optional[RemoteStatus]:
    """Extract remote status from LinkedIn job details"""
    # First check job insights as they're more reliable
    if job_insights := job_details.get('job_insight', []):
        for insight in job_insights:
            if " Remote" in insight or "Remote " in insight:
                return RemoteStatus.REMOTE
            elif "Hybrid" in insight:
                return RemoteStatus.HYBRID
            elif "On-site" in insight or "Onsite" in insight:
                return RemoteStatus.ONSITE

    # Check description as fallback
    description = job_details.get('description', '').lower()
    if "100% remote" in description or "fully remote" in description:
        return RemoteStatus.REMOTE
    elif "hybrid" in description:
        return RemoteStatus.HYBRID
    elif any(x in description for x in ['on-site', 'onsite', 'in office', 'in person']):
        return RemoteStatus.ONSITE

    return None
