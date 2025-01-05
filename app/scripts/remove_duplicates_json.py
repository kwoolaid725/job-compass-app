# app/scripts/remove_duplicates_json.py
import json
from pathlib import Path
import os


def remove_duplicates_json():
    # Get the absolute path to the JSON file
    file_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'data', 'output_data_engineer.json')

    # Read the JSON file line by line (since it's one JSON object per line)
    jobs = []
    seen_urls = set()
    duplicate_count = 0

    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            for line in f:
                try:
                    job = json.loads(line.strip())
                    url = job.get('job_url')

                    if url and url not in seen_urls:
                        seen_urls.add(url)
                        jobs.append(job)
                    else:
                        duplicate_count += 1
                except json.JSONDecodeError as e:
                    print(f"Error parsing line: {str(e)}")
                    continue

        # Create backup
        backup_path = file_path.replace('.json', '_backup.json')
        with open(backup_path, 'w', encoding='utf-8') as f:
            for job in jobs:
                f.write(json.dumps(job) + '\n')

        # Write deduplicated data
        with open(file_path, 'w', encoding='utf-8') as f:
            for job in jobs:
                f.write(json.dumps(job) + '\n')

        print(f"Original number of jobs: {len(jobs) + duplicate_count}")
        print(f"Number of jobs after removing duplicates: {len(jobs)}")
        print(f"Removed {duplicate_count} duplicate entries")
        print(f"Created backup at: {backup_path}")
        print(f"Saved deduplicated data to: {file_path}")

    except FileNotFoundError:
        print(f"Error: File not found at {file_path}")
    except Exception as e:
        print(f"Unexpected error: {str(e)}")


if __name__ == "__main__":
    remove_duplicates_json()