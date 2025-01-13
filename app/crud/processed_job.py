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

# Define Central timezone
CENTRAL_TZ = ZoneInfo("America/Chicago")

def extract_salary_info(raw_job: RawJobPost) -> dict:
    """Extract salary information from RawJobPost's salary_text column"""
    salary_info = {
        'salary_type': None,
        'salary_min': None,
        'salary_max': None,
        'salary_currency': 'USD'
    }

    if not raw_job.salary_text:
        return salary_info

    # Pattern for "$X - $Y a year" format
    pattern = r'\$(\d{1,3}(?:,\d{3})*)\s*-\s*\$(\d{1,3}(?:,\d{3})*)\s*(?:a\s*)?year'
    match = re.search(pattern, raw_job.salary_text, re.IGNORECASE)

    if match:
        salary_info['salary_type'] = SalaryType.YEARLY
        salary_info['salary_min'] = Decimal(match.group(1).replace(',', ''))
        salary_info['salary_max'] = Decimal(match.group(2).replace(',', ''))

    return salary_info


def extract_job_details(raw_content: str) -> dict:
    """Extract job details from Indeed's format"""
    try:
        data = json.loads(raw_content) if isinstance(raw_content, str) else raw_content

        # If it's Indeed's API format
        if isinstance(data, dict) and '__typename' in data and data.get('__typename') == 'Job':
            return data  # Return as is since it's already in the correct format

        # If it's the API format with host_query_execution_result
        if isinstance(data, dict) and 'host_query_execution_result' in data:
            job_data = data['host_query_execution_result']['data']['jobData']['results'][0]['job']
            job_data['job_url'] = data.get('job_url')
            return job_data

        # If it's the simpler format with just basic fields
        if isinstance(data, dict) and 'title' in data:
            # Handle description that could be string or dict
            description = data.get('description', '')
            if isinstance(description, dict):
                description_text = description.get('text', '') or description.get('html', '') or ''
            else:
                description_text = str(description) if description else ''

            # Try to extract company from description if needed
            company = data.get('company', '') or data.get('sourceEmployerName', '')
            if not company and description_text:
                first_line = description_text.split('\n')[0].strip()
                if first_line:
                    company = first_line

            return {
                'title': data.get('title', ''),
                'description': {'text': description_text},
                'sourceEmployerName': company or '',
                'job_url': data.get('job_url', ''),
                'attributes': [{'label': 'Full-time'}] if description_text and 'full' in description_text.lower() else [],
                'benefits': [],
                'location': {},
                'datePublished': data.get('datePublished'),
            }

        # If nothing else matches, create a minimal valid structure
        return {
            'title': data.get('title', '') if isinstance(data, dict) else '',
            'description': {'text': 'No description available'},
            'sourceEmployerName': '',
            'job_url': '',
            'attributes': [],
            'benefits': [],
            'location': {},
        }

    except json.JSONDecodeError as e:
        print(f"JSON decode error: {str(e)}")
        raise ValueError(f"Failed to parse job details: Invalid JSON")
    except Exception as e:
        print(f"Unexpected error in extract_job_details: {str(e)}")
        print(f"Raw content preview: {str(raw_content)[:200]}")
        raise ValueError(f"Failed to parse job details: {str(e)}")

def extract_base_job_info(job_details: Dict[str, Any]) -> Dict[str, Any]:
    """Extract basic job information"""
    description = ""
    if desc_data := job_details.get("description", {}):
        # Get text directly without any transformation
        description = desc_data.get("text", "") or desc_data.get("html", "") or "No description available"

    return {
        "title": job_details.get("title", ""),
        "company": job_details.get("sourceEmployerName", ""),
        "description": description,  # Store raw text directly
        "job_url": job_details.get("job_url") or job_details.get("url", "")
    }

def extract_location_info(location: Dict[str, Any]) -> Dict[str, Any]:
    """Extract location information"""
    if not location:
        return {"location_raw": ""}

    return {
        "location_raw": location.get("formatted", {}).get("long", ""),
        "latitude": Decimal(str(location["latitude"])) if location.get("latitude") else None,
        "longitude": Decimal(str(location["longitude"])) if location.get("longitude") else None
    }


def extract_job_type(attributes: List[Dict[str, Any]]) -> Optional[JobType]:
    """Extract job type from attributes"""
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


def extract_remote_status(job_details: Dict[str, Any]) -> Optional[RemoteStatus]:
    """Extract remote status from job details"""
    attributes = job_details.get('attributes', [])
    description = job_details.get('description', {}).get('text', '').lower()

    for attr in attributes:
        if isinstance(attr, dict):
            label = attr.get('label', '').lower()
            if 'remote' in label:
                return RemoteStatus.REMOTE
            elif 'hybrid' in label:
                return RemoteStatus.HYBRID
            elif 'in-person' in label or 'on-site' in label or 'onsite' in label:
                return RemoteStatus.ONSITE

    if 'remote' in description and 'hybrid' in description:
        return RemoteStatus.HYBRID
    elif 'remote' in description:
        return RemoteStatus.REMOTE
    elif 'on-site' in description or 'onsite' in description or 'in person' in description:
        return RemoteStatus.ONSITE

    return None


def extract_benefits(job_details: Dict[str, Any]) -> Optional[str]:
    """Extract benefits information"""
    benefits = job_details.get('benefits', [])
    if benefits and isinstance(benefits, list):
        benefit_labels = [b.get('label') for b in benefits if isinstance(b, dict) and b.get('label')]
        return json.dumps(benefit_labels) if benefit_labels else None
    return None


# LinkedIn specific functions
def extract_job_details_linkedin(raw_content: str) -> dict:
    """Extract job details from LinkedIn format"""
    try:
        job_data = json.loads(raw_content) if isinstance(raw_content, str) else raw_content
        return job_data
    except Exception as e:
        raise ValueError(f"Failed to parse LinkedIn job details: {str(e)}")


def extract_base_job_info_linkedin(raw_content: str) -> Dict[str, Any]:
    """Extract basic job information from LinkedIn format"""
    job_details = json.loads(raw_content) if isinstance(raw_content, str) else raw_content
    return {
        "title": job_details.get("title", ""),
        "company": job_details.get("company", ""),
        "description": job_details.get("description", ""),
        "job_url": job_details.get("job_url", "")
    }


def extract_location_info_linkedin(raw_content: str) -> Dict[str, Any]:
    """Extract location information from LinkedIn format"""
    job_details = json.loads(raw_content) if isinstance(raw_content, str) else raw_content
    location_info = {
        "location_raw": None,
        "latitude": None,
        "longitude": None
    }

    if details := job_details.get('details_modules', []):
        for detail in details:
            if isinstance(detail, str) and 'Pay range in' in detail:
                location = detail.split('Pay range in ')[1].split(',')[0]
                location_info['location_raw'] = location
                break

    return location_info


def extract_benefits_linkedin(job_details: Dict[str, Any]) -> Optional[str]:
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
    def extract_benefits_from_section(section):
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
                found_benefits = extract_benefits_from_section(item)
                if found_benefits:
                    benefits.extend(found_benefits)
        else:
            found_benefits = extract_benefits_from_section(source)
            if found_benefits:
                benefits.extend(found_benefits)

    # Remove duplicates while preserving order
    benefits = list(dict.fromkeys(benefits))

    # Print debug information
    print("DEBUG: Extracted benefits:", benefits)

    return json.dumps(benefits) if benefits else None


def extract_salary_info_linkedin(job_details: Dict[str, Any]) -> dict:
    """Extract salary information from LinkedIn format"""
    no_salary = {
        'salary_type': None,
        'salary_min': None,
        'salary_max': None,
        'salary_currency': 'USD'
    }

    sources = (
            job_details.get('job_insight', []) +
            job_details.get('segment_cards', []) +
            job_details.get('details_modules', [])
    )

    pattern = re.compile(
        r'\$(\d+(?:,\d{3})*(?:\.\d+)?)([Kk])?(?:/(yr|year|hr|month))?'
        r'(?:\s*-\s*\$(\d+(?:,\d{3})*(?:\.\d+)?)([Kk])?(?:/(yr|year|hr|month))?)?',
        re.IGNORECASE
    )

    def parse_salary(val_str: str, k_flag: str = None) -> Decimal:
        val = Decimal(val_str.replace(',', ''))
        return val * 1000 if k_flag else val

    def determine_salary_type(val_min: Decimal, val_max: Decimal, suffixes: List[str]) -> SalaryType:
        lower_suffixes = [str(s).lower() for s in suffixes if s]
        if any('month' in s for s in lower_suffixes):
            return SalaryType.MONTHLY
        if any(s in ['yr', 'year'] for s in lower_suffixes):
            return SalaryType.YEARLY
        if any('hr' in s for s in lower_suffixes):
            return SalaryType.HOURLY
        if val_min > 10000 or val_max > 10000:
            return SalaryType.YEARLY
        if val_min > 1000 or val_max > 1000:
            return SalaryType.YEARLY
        return SalaryType.HOURLY

    for source in sources:
        if not isinstance(source, str):
            continue

        # Debug: Show the source being processed
        print(f"DEBUG: Processing source: {source}")

        if "try premium" in source.lower():
            print(f"DEBUG: Skipping due to 'try premium' in text: {source}")
            continue

        match = pattern.search(source)
        if match:
            print(f"DEBUG: Match found in source: {source}")
            print(f"DEBUG: Matched groups: {match.groups()}")

            num1_str = match.group(1)
            k1_flag = match.group(2)
            suf1 = match.group(3)
            num2_str = match.group(4)
            k2_flag = match.group(5)
            suf2 = match.group(6)

            print(f"DEBUG: Parsed first salary: {num1_str} (K: {k1_flag}, Suffix: {suf1})")
            if num2_str:
                print(f"DEBUG: Parsed second salary: {num2_str} (K: {k2_flag}, Suffix: {suf2})")

            try:
                min_val = parse_salary(num1_str, k1_flag)
                max_val = parse_salary(num2_str, k2_flag) if num2_str else min_val

                if min_val == 0 and max_val == 0:
                    print(f"DEBUG: Skipping due to min and max both being 0.")
                    continue

                salary_type = determine_salary_type(min_val, max_val, [suf1, suf2])
                print(f"DEBUG: Final salary type: {salary_type}, Min: {min_val}, Max: {max_val}")

                return {
                    'salary_type': salary_type,
                    'salary_min': min_val,
                    'salary_max': max_val,
                    'salary_currency': 'USD'
                }

            except Exception as e:
                print(f"DEBUG: Exception while parsing salaries: {e}")
                continue

    # If no match was found in any source
    print("DEBUG: No salary found.")
    return no_salary

def extract_remote_status_linkedin(job_details: Dict[str, Any]) -> Optional[RemoteStatus]:
    """Extract remote status from LinkedIn job details"""
    # Check job insights
    if job_insights := job_details.get('job_insight', []):
        for insight in job_insights:
            if 'Remote' in insight:
                return RemoteStatus.REMOTE
            elif 'Hybrid' in insight:
                return RemoteStatus.HYBRID
            elif 'On-site' in insight:
                return RemoteStatus.ONSITE

    # Check description
    if description := job_details.get('description', '').lower():
        if 'fully remote' in description:
            return RemoteStatus.REMOTE
        elif 'hybrid' in description:
            return RemoteStatus.HYBRID
        elif any(x in description for x in ['on-site', 'onsite', 'in person']):
            return RemoteStatus.ONSITE

    return None


def process_job_data_linkedin(raw_content: str) -> Dict[str, Any]:
    """Process and extract all job information from LinkedIn raw content"""
    try:
        print("\nDEBUG: Starting process_job_data_linkedin")
        # print(f"DEBUG: raw_content type: {type(raw_content)}")

        if isinstance(raw_content, str):
            # print("DEBUG: Parsing raw_content as JSON")
            raw_data = json.loads(raw_content)
            if 'raw_content' in raw_data:
                # print("DEBUG: Found nested raw_content, parsing that")
                job_details = json.loads(raw_data['raw_content'])
            else:
                # print("DEBUG: Using directly parsed content")
                job_details = raw_data
        else:
            job_details = raw_content

        # print(f"DEBUG: job_details keys: {job_details.keys() if isinstance(job_details, dict) else 'not a dict'}")

        processed_data = {}

        # Basic job info (job_url from raw_data)
        processed_data.update({
            "title": job_details.get("title", ""),
            "company": job_details.get("company", ""),
            "description": job_details.get("description", ""),
        })

        # Location info
        location_info = extract_location_info_linkedin(job_details)
        processed_data.update(location_info)

        # Extract posting date from job insights
        if job_insights := job_details.get('job_insight', []):
            for insight in job_insights:
                if isinstance(insight, str) and any(
                        x in insight.lower() for x in ['ago', 'week', 'month', 'hour', 'day']):
                    try:
                        time_parts = [part for part in insight.split(' · ') if 'ago' in part]
                        if time_parts:
                            time_str = time_parts[0].strip().lower()
                            current_time = datetime.now(CENTRAL_TZ)

                            if 'week' in time_str:
                                weeks = int(time_str.split()[0])
                                processed_data["date_posted"] = current_time - timedelta(weeks=weeks)
                            elif 'month' in time_str:
                                months = int(time_str.split()[0])
                                processed_data["date_posted"] = current_time - timedelta(days=months * 30)
                            elif 'day' in time_str:
                                days = int(time_str.split()[0])
                                processed_data["date_posted"] = current_time - timedelta(days=days)
                            elif 'hour' in time_str:
                                hours = int(time_str.split()[0])
                                processed_data["date_posted"] = current_time - timedelta(hours=hours)
                    except Exception as e:
                        print(f"Warning: Error parsing date: {e}")

        # Experience level from job insights
        if job_insights := job_details.get('job_insight', []):
            for insight in job_insights:
                if "Entry level" in insight:
                    processed_data['experience_level'] = "Entry level"
                    break
                elif "Associate" in insight:
                    processed_data['experience_level'] = "Associate"
                    break
                elif "Mid-Senior level" in insight:
                    processed_data['experience_level'] = "Mid level"
                    break
                elif "Senior level" in insight:
                    processed_data['experience_level'] = "Senior level"
                    break
                elif "Executive" in insight:
                    processed_data['experience_level'] = "Executive"
                    break

        # Combine requirements and skills
        requirements_set = set()

        # Get skills from original skills
        if skills := job_details.get('skills'):
            if isinstance(skills, list) and skills:
                skills_text = skills[0]
                if 'missing on your profile' in skills_text:
                    skills_list = skills_text.split('missing on your profile\n')[-1].split(', ')
                    requirements_set.update([skill.strip() for skill in skills_list if skill.strip()])

        # Get skills from Technology section in segment_cards
        if segment_cards := job_details.get('segment_cards', []):
            for card in segment_cards:
                if isinstance(card, str) and 'Technology:' in card:
                    tech_skills = card.split('Technology:')[-1].strip().split(', ')
                    requirements_set.update([skill.strip() for skill in tech_skills if skill.strip()])

        # Convert to list and store
        if requirements_set:
            processed_data['requirements'] = json.dumps(list(requirements_set))

        # Add salary information
        salary_info = extract_salary_info_linkedin(job_details)
        processed_data.update(salary_info)

        # Add remote status
        processed_data['remote_status'] = extract_remote_status_linkedin(job_details)

        # Add benefits
        if benefits := extract_benefits_linkedin(job_details):
            processed_data['benefits'] = benefits

        # Add job type
        if job_insights := job_details.get('job_insight', []):
            for insight in job_insights:
                if 'Full-time' in insight:
                    processed_data['job_type'] = JobType.FULL_TIME
                    break
                elif 'Part-time' in insight:
                    processed_data['job_type'] = JobType.PART_TIME
                    break
                elif 'Contract' in insight:
                    processed_data['job_type'] = JobType.CONTRACT
                    break

        print("DEBUG: Successfully processed job data")
        return processed_data

    except json.JSONDecodeError as e:
        print(f"DEBUG: JSON decode error: {str(e)}")
        raise ValueError(f"Failed to parse LinkedIn JSON data: {str(e)}")
    except Exception as e:
        print(f"DEBUG: Processing error: {str(e)}")
        raise ValueError(f"Failed to process LinkedIn job data: {str(e)}")


def process_job_data(raw_content: str) -> Dict[str, Any]:
    try:
        job_details = extract_job_details(raw_content)

        processed_data = {
            **extract_base_job_info(job_details),
            **extract_location_info(job_details.get('location', {})),
        }

        # Extract date in Central Time
        if date_published := job_details.get("datePublished"):
            # Convert timestamp to Central time
            processed_data["date_posted"] = datetime.fromtimestamp(
                int(date_published) / 1000
            ).astimezone(CENTRAL_TZ)

        # Extract salary from the description text
        if desc_data := job_details.get("description", {}):
            desc_text = desc_data.get("text", "")
            if desc_text:
                # Look for salary pattern in the text
                salary_pattern = r'Salary Range:\s*\$(\d{1,3}(?:,\d{3})*)\s*-\s*\$(\d{1,3}(?:,\d{3})*)'
                match = re.search(salary_pattern, desc_text, re.IGNORECASE)

                if match:
                    processed_data.update({
                        'salary_type': SalaryType.YEARLY,
                        'salary_min': Decimal(match.group(1).replace(',', '')),
                        'salary_max': Decimal(match.group(2).replace(',', '')),
                        'salary_currency': 'USD'
                    })

        # Extract other fields
        if attributes := job_details.get('attributes', []):
            processed_data['job_type'] = extract_job_type(attributes)
            processed_data['remote_status'] = extract_remote_status(job_details)
            processed_data['experience_level'] = next(
                (attr['label'] for attr in attributes
                 if attr.get('label') in ["Entry level", "Mid level", "Senior level"]),
                None
            )

        if benefits := extract_benefits(job_details):
            processed_data['benefits'] = benefits

        return processed_data

    except Exception as e:
        raise ValueError(f"Failed to process job data: {str(e)}")


def process_raw_job(db: Session, raw_job: RawJobPost) -> ProcessedJob:
    try:
        if raw_job.source == JobSource.LINKEDIN:
            processed_data = process_job_data_linkedin(raw_job.raw_content)
            processed_data['job_url'] = raw_job.job_url
        elif raw_job.source == JobSource.INDEED:
            processed_data = process_job_data(raw_job.raw_content)
            if raw_job.salary_text:
                salary_info = extract_salary_info(raw_job)
                processed_data.update(salary_info)
        else:
            raise ValueError(f"Unknown job source: {raw_job.source}")

        processed_data['raw_job_post_id'] = raw_job.id

        # Create ProcessedJob instance
        db_job = ProcessedJob(**processed_data)

        db.add(db_job)
        db.commit()
        db.refresh(db_job)

        raw_job.processed = True
        db.commit()

        return db_job

    except Exception as e:
        db.rollback()
        print(f"Error processing job {raw_job.job_url}: {str(e)}")
        raise

def process_unprocessed_jobs(db: Session, limit: int = 10):
    """Process a batch of unprocessed raw jobs"""
    unprocessed_jobs = db.query(RawJobPost).filter(
        RawJobPost.processed == False
    ).limit(limit).all()

    results = {"success": 0, "failed": 0, "errors": []}

    for raw_job in unprocessed_jobs:
        try:
            process_raw_job(db, raw_job)
            results["success"] += 1
        except Exception as e:
            results["failed"] += 1
            results["errors"].append({
                "job_url": raw_job.job_url,
                "error": str(e)
            })

    return results