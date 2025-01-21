# view_job_data.py
import json
import asyncio
from app.crud.process_indeed_raw_jobs import process_job_data_indeed
from app.crud.process_linkedin_raw_jobs import process_job_data_linkedin
from app.crud.process_builtinchicago_raw_jobs import process_job_data_builtinchicago
from app.scripts.process_jobs import extract_salary_info_openai


async def view_and_save_jobs():
    """View all sample jobs and save processed results separately by source"""
    # Load the test data
    with open('fixtures/job_fixtures.json', 'r') as f:
        data = json.load(f)
        indeed_jobs = [job for job in data.get('sample_jobs', []) if job.get('source') == 'INDEED']
        linkedin_jobs = [job for job in data.get('sample_jobs', []) if job.get('source') == 'LINKEDIN']
        builtinchicago_jobs = [job for job in data.get('sample_jobs', []) if job.get('source') == 'BUILTINCHICAGO']

    # Process Indeed jobs
    processed_indeed_jobs = []
    for job in indeed_jobs:
        result = process_job_data_indeed(job['raw_content'])
        # Add salary info
        salary_info = await extract_salary_info_openai(
            result.get('description', ''),
            job.get('salary_text', '')
        )
        if salary_info:
            result.update(salary_info)
        processed_indeed_jobs.append(result)

    # Process LinkedIn jobs
    processed_linkedin_jobs = []
    for job in linkedin_jobs:
        result = process_job_data_linkedin(job['raw_content'])
        result["job_url"] = job.get("job_url", None)

        # Only add OpenAI salary extraction if no salary was extracted by LinkedIn method
        if not any(result.get(key) for key in ['salary_min', 'salary_max', 'salary_type']):
            salary_info = await extract_salary_info_openai(
                result.get('description', ''),
                job.get('salary_text', '')
            )
            if salary_info:
                result.update(salary_info)

        processed_linkedin_jobs.append(result)

    # Process BuiltInChicago jobs
    processed_builtinchicago_jobs = []
    for job in builtinchicago_jobs:
        result = process_job_data_builtinchicago(job['raw_content'])
        result["job_url"] = job.get("job_url", None)

        # Only add OpenAI salary extraction if no salary was extracted by BuiltInChicago method
        if not any(result.get(key) for key in ['salary_min', 'salary_max', 'salary_type']):
            salary_info = await extract_salary_info_openai(
                result.get('description', ''),
                job.get('salary_text', '')
            )
            if salary_info:
                result.update(salary_info)

        processed_builtinchicago_jobs.append(result)

    # Save results for each source
    sources_data = {
        # 'indeed': {'jobs': processed_indeed_jobs, 'filename': 'indeed_processed_jobs.json'},
        # 'linkedin': {'jobs': processed_linkedin_jobs, 'filename': 'linkedin_processed_jobs.json'},
        'builtinchicago': {'jobs': processed_builtinchicago_jobs, 'filename': 'builtinchicago_processed_jobs.json'}
    }

    for source, data in sources_data.items():
        output = {
            "processed_jobs": data['jobs'],
            "total_jobs": len(data['jobs'])
        }
        with open(data['filename'], 'w', encoding='utf-8') as f:
            json.dump(output, f, indent=2, default=str)
        print(f"\nProcessed {len(data['jobs'])} {source} jobs. Results saved to '{data['filename']}'")


if __name__ == "__main__":
    asyncio.run(view_and_save_jobs())