import pytest
import json
from datetime import datetime
from decimal import Decimal
from zoneinfo import ZoneInfo
from typing import List, Dict, Any
from app.crud.process_indeed_raw_jobs import process_job_data_indeed


def load_indeed_jobs() -> List[Dict[str, Any]]:
    """Load and return only Indeed jobs from test fixtures"""
    with open('tests/fixtures/job_fixtures.json', 'r') as f:
        data = json.load(f)
        return [job for job in data.get('jobs', []) if job.get('source') == 'INDEED']


@pytest.fixture
def indeed_jobs() -> List[Dict[str, Any]]:
    """Fixture that returns all Indeed jobs from the test data"""
    return load_indeed_jobs()


def test_view_processed_data(indeed_jobs):
    """Just view the processed data - not actually testing anything"""
    # Get the first job and process it
    job = indeed_jobs[0]
    result = process_job_data_indeed(job['raw_content'])

    # Print out all data nicely formatted
    print("\n")  # Start with blank line
    print("=" * 80)
    print("PROCESSED JOB DATA")
    print("=" * 80)

    # Basic Info
    print("\nBASIC INFORMATION:")
    print(f"Title: {result.get('title')}")
    print(f"Company: {result.get('company')}")
    print(f"Job URL: {result.get('job_url')}")

    # Location
    print("\nLOCATION:")
    print(f"Location: {result.get('location_raw')}")
    print(f"Latitude: {result.get('latitude')}")
    print(f"Longitude: {result.get('longitude')}")

    # Job Details
    print("\nJOB DETAILS:")
    print(f"Job Type: {result.get('job_type')}")
    print(f"Remote Status: {result.get('remote_status')}")
    print(f"Experience Level: {result.get('experience_level')}")
    print(f"Salary: {result.get('salary_text')}")

    # Benefits
    print("\nBENEFITS:")
    benefits = result.get('benefits', [])
    if benefits:
        for benefit in benefits:
            print(f"- {benefit}")
    else:
        print("No benefits listed")

    # Requirements
    print("\nREQUIREMENTS:")
    requirements = result.get('requirements', [])
    if requirements:
        for req in requirements:
            print(f"- {req}")
    else:
        print("No requirements listed")

    # Description (truncated)
    print("\nDESCRIPTION PREVIEW:")
    description = result.get('description', '')
    print(f"{description[:200]}...")

    print("\n" + "=" * 80 + "\n")


def test_basic_fields(indeed_jobs):
    """Test processing of basic fields for all Indeed jobs"""
    for job in indeed_jobs:
        result = process_job_data_indeed(job['raw_content'])

        # Basic fields should always be present
        assert isinstance(result["title"], str)
        assert isinstance(result["company"], str)
        assert isinstance(result["job_url"], str)
        assert isinstance(result["description"], str)

        # Fields should not be empty
        assert len(result["title"]) > 0
        assert len(result["company"]) > 0
        assert len(result["job_url"]) > 0
        assert len(result["description"]) > 0

        # Test specific values from raw data
        raw_job = json.loads(job['raw_content'])['host_query_execution_result']['data']['jobData']['results'][0]['job']
        assert result["title"] == raw_job["title"]
        assert result["company"] == raw_job["sourceEmployerName"]
        assert result["job_url"] == raw_job["url"]


def test_location_processing(indeed_jobs):
    """Test location processing for all Indeed jobs"""
    for job in indeed_jobs:
        result = process_job_data_indeed(job['raw_content'])
        raw_job = json.loads(job['raw_content'])['host_query_execution_result']['data']['jobData']['results'][0]['job']

        # Location fields should be present and correct
        assert isinstance(result["location_raw"], str)
        assert isinstance(result["latitude"], Decimal)
        assert isinstance(result["longitude"], Decimal)

        assert result["location_raw"] == raw_job["location"]["formatted"]["long"]
        assert result["latitude"] == Decimal(str(raw_job["location"]["latitude"]))
        assert result["longitude"] == Decimal(str(raw_job["location"]["longitude"]))


def test_date_processing(indeed_jobs):
    """Test date processing for all Indeed jobs"""
    for job in indeed_jobs:
        result = process_job_data_indeed(job['raw_content'])

        # Date should be properly processed
        assert isinstance(result["date_posted"], datetime)
        assert result["date_posted"].tzinfo == ZoneInfo("America/Chicago")


def test_attributes_processing(indeed_jobs):
    """Test processing of attributes for all Indeed jobs"""
    for job in indeed_jobs:
        result = process_job_data_indeed(job['raw_content'])
        raw_job = json.loads(job['raw_content'])['host_query_execution_result']['data']['jobData']['results'][0]['job']

        # Job type, remote status, experience level
        if "job_type" in result:
            assert isinstance(result["job_type"], str)

        if "remote_status" in result:
            assert isinstance(result["remote_status"], str)

        if "experience_level" in result:
            assert isinstance(result["experience_level"], str)

        # Requirements
        if "requirements" in result:
            assert isinstance(result["requirements"], list)
            for req in result["requirements"]:
                assert isinstance(req, str)
                assert len(req) > 0

        # Test against raw attributes
        raw_attributes = [attr["label"] for attr in raw_job.get("attributes", [])]
        if "Full-time" in raw_attributes:
            assert result.get("job_type") == "Full-time"
        if "Remote" in raw_attributes:
            assert result.get("remote_status") == "Remote"
        if "Senior level" in raw_attributes:
            assert result.get("experience_level") == "Senior level"


def test_benefits_processing(indeed_jobs):
    """Test processing of benefits for all Indeed jobs"""
    for job in indeed_jobs:
        result = process_job_data_indeed(job['raw_content'])
        raw_job = json.loads(job['raw_content'])['host_query_execution_result']['data']['jobData']['results'][0]['job']

        # Benefits should be a list if present
        if "benefits" in result:
            assert isinstance(result["benefits"], list)
            for benefit in result["benefits"]:
                assert isinstance(benefit, str)
                assert len(benefit) > 0

        # Test against raw benefits
        raw_benefits = raw_job.get("benefits", [])
        for benefit in raw_benefits:
            assert benefit["label"] in result.get("benefits", [])


def test_salary_processing(indeed_jobs):
    """Test salary processing for all Indeed jobs"""
    for job in indeed_jobs:
        result = process_job_data_indeed(job['raw_content'])

        # Salary text if present
        if "salary_text" in result:
            assert isinstance(result["salary_text"], str)
            assert len(result["salary_text"]) > 0
            assert "$" in result["salary_text"]


def test_error_cases():
    """Test various error cases and edge conditions"""
    # Test invalid JSON
    with pytest.raises(ValueError):
        process_job_data_indeed("invalid json")

    # Test empty job data
    empty_data = {
        "host_query_execution_result": {
            "data": {
                "jobData": {
                    "results": [{
                        "__typename": "JobDataResult",
                        "job": {
                            "__typename": "Job",
                            "title": "",
                            "sourceEmployerName": "",
                            "url": "",
                            "description": {}
                        }
                    }]
                }
            }
        }
    }
    result = process_job_data_indeed(json.dumps(empty_data))
    assert result["title"] == ""
    assert result["company"] == ""
    assert result["job_url"] == ""
    assert "No description available" in result["description"]


def test_description_formats():
    """Test different description format handling"""
    # Test HTML description
    html_data = {
        "host_query_execution_result": {
            "data": {
                "jobData": {
                    "results": [{
                        "job": {
                            "title": "Test Job",
                            "sourceEmployerName": "Test Company",
                            "url": "https://example.com",
                            "description": {"html": "<p>HTML Description</p>"}
                        }
                    }]
                }
            }
        }
    }
    result = process_job_data_indeed(json.dumps(html_data))
    assert result["description"] == "<p>HTML Description</p>"

    # Test text-only description
    text_data = {
        "host_query_execution_result": {
            "data": {
                "jobData": {
                    "results": [{
                        "job": {
                            "title": "Test Job",
                            "sourceEmployerName": "Test Company",
                            "url": "https://example.com",
                            "description": {"text": "Text Description"}
                        }
                    }]
                }
            }
        }
    }
    result = process_job_data_indeed(json.dumps(text_data))
    assert result["description"] == "Text Description"