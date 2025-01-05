import os
import json
from app.database import SessionLocal
from app.crud.raw_job import parse_indeed_job, create_raw_job, parse_linkedin_job


def extract_all_json_from_document(file_path: str):
    """Extract and validate all JSON entries from the document"""
    try:
        with open(file_path, 'r') as file:
            content = file.read()

        # Find all job entries (each starting with {"job_url"})
        job_entries = [line.strip() for line in content.split('\n')
                       if line.strip().startswith('{"job_url"')]

        json_objects = []
        for entry in job_entries:
            try:
                json_obj = json.loads(entry)
                if validate_job_entry(json_obj):
                    json_objects.append(json_obj)
            except json.JSONDecodeError as e:
                print(f"Error parsing JSON entry: {str(e)}")
                continue

        return json_objects
    except Exception as e:
        print(f"Error processing file: {str(e)}")
        return []


def extract_job_category(file_path: str) -> str:
    """Extract job category from filename"""
    try:
        filename = os.path.basename(file_path)
        # Remove file extension and split by underscore
        name_parts = os.path.splitext(filename)[0].split('_')

        # Get the category parts (skip 'output' and 'linkedin' if present)
        category_parts = [part for part in name_parts[1:] if part != 'linkedin']
        category = '_'.join(category_parts)
        return category.upper()
    except Exception as e:
        print(f"Error extracting job category from filename: {str(e)}")
        return "OTHERS"


def validate_job_entry(json_obj):
    """Validate that the job entry has required fields based on data structure"""
    # If it has raw_content, it's a LinkedIn post
    if "raw_content" in json_obj:
        return "job_url" in json_obj and "raw_content" in json_obj
    # If it has host_query_execution_result, it's an Indeed post
    return "job_url" in json_obj and "host_query_execution_result" in json_obj


def detect_source(json_obj: dict) -> str:
    """Detect source from the data structure rather than filename"""
    if "raw_content" in json_obj:
        return "linkedin"
    return "indeed"


def upload_jobs_to_db(file_path: str):
    db = SessionLocal()
    try:
        print(f"Current working directory: {os.getcwd()}")
        print(f"File exists: {os.path.exists(file_path)}")

        # Extract job category from filename
        job_category = extract_job_category(file_path)
        print(f"Detected job category: {job_category}")

        json_objects = extract_all_json_from_document(file_path)
        print(f"Found {len(json_objects)} valid job postings")

        success_count = 0
        skip_count = 0
        error_count = 0

        for json_data in json_objects:
            try:
                # Detect source from data structure
                source = detect_source(json_data)

                # Parse job based on detected source
                if source == "linkedin":
                    job_data = parse_linkedin_job(json_data, job_category)
                else:
                    job_data = parse_indeed_job(json_data, job_category)

                if job_data:
                    result = create_raw_job(db, job_data)
                    if result:
                        success_count += 1
                        print(f"✅ Successfully uploaded job: {job_data['job_url']}")
                    else:
                        skip_count += 1
                        print(f"⏭️ Job already exists: {job_data['job_url']}")
                else:
                    error_count += 1
                    print(f"❌ Failed to parse job data")
            except Exception as e:
                error_count += 1
                print(f"❌ Error processing job: {str(e)}")
                continue

        print(f"\nUpload Summary:")
        print(f"Successfully uploaded: {success_count}")
        print(f"Skipped (already exists): {skip_count}")
        print(f"Failed to process: {error_count}")

    except Exception as e:
        print(f"Error uploading to database: {str(e)}")
        raise e
    finally:
        db.close()


if __name__ == "__main__":
    # Get the absolute path to the data directory
    project_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    file_path = os.path.join(project_root, "app/data", "output_data_engineer_linkedin.json")
    print(f"Processing file: {file_path}")
    upload_jobs_to_db(file_path)