# app/crud/job_queries.py
from sqlalchemy.orm import Session
from sqlalchemy import text
import re
from app.models.job import RawJobPost, JobSource
from typing import List, Dict, Any
from app.database import SessionLocal  # Make sure to import SessionLocal


def get_unprocessed_jobs(db: Session, limit: int = 50) -> List[RawJobPost]:
    """Get jobs that haven't been processed yet"""
    return db.query(RawJobPost) \
        .filter(RawJobPost.processed == False) \
        .order_by(RawJobPost.created_at.desc()) \
        .limit(limit) \
        .all()


def get_linkedin_job_id(url: str) -> str:
    """Extract the job ID from a LinkedIn job URL"""
    match = re.search(r'/view/(\d+)', url)
    return match.group(1) if match else url


def get_indeed_job_id(url: str) -> str:
    """Extract the job ID from an Indeed job URL"""
    match = re.search(r'clk\?jk=([^&]+)', url)
    return match.group(1) if match else url


def print_table_columns(db):
    """
    Print out the column names for the raw_job_posts table
    """
    from sqlalchemy import inspect

    inspector = inspect(db.bind)
    columns = inspector.get_columns('raw_job_posts')
    print("Columns in raw_job_posts:")
    for column in columns:
        print(column['name'])


def find_duplicates(db: Session) -> Dict[str, List[Dict[str, Any]]]:
    """
    Find duplicate job postings, with special handling for LinkedIn and Indeed URLs.
    For LinkedIn, matches based on the view ID number.
    For Indeed, matches based on the job key (jk) in the URL.
    """
    query = text("""
    WITH job_data AS (
        SELECT 
            id,
            job_url,
            source,
            created_at,
            CASE 
                WHEN source = 'LINKEDIN' THEN 
                    REGEXP_REPLACE(job_url, '^.*?/view/(\d+).*$', '\\1')  -- Extract LinkedIn job ID
                WHEN source = 'INDEED' THEN 
                    REGEXP_REPLACE(job_url, '^.*?jk=([^&]+).*$', '\\1')  -- Extract Indeed job key
                ELSE job_url  -- Use full URL for other sources
            END AS normalized_url
        FROM raw_job_posts
        WHERE source IN ('LINKEDIN', 'INDEED')
    ), job_groups AS (
        SELECT 
            normalized_url,
            COUNT(*) as count,
            array_agg(json_build_object(
                'id', id,
                'job_url', job_url,
                'source', source,
                'created_at', created_at
            )) as entries
        FROM job_data
        GROUP BY normalized_url
        HAVING COUNT(*) > 1
    )
    SELECT 
        normalized_url, 
        count, 
        entries
    FROM job_groups
    ORDER BY count DESC;
    """)

    result = db.execute(query)
    duplicates = {}

    print("=== Debugging Duplicate Detection ===")

    for row in result:
        print(f"\nNormalized URL Pattern: {row.normalized_url}")
        print(f"Duplicate Count: {row.count}")
        print("Duplicate Job Details:")

        for entry in row.entries:
            print(f"  - ID: {entry['id']}")
            print(f"    Source: {entry['source']}")
            print(f"    Job URL: {entry['job_url']}")
            print(f"    Created At: {entry['created_at']}")

        duplicates[row.normalized_url] = {
            'count': row.count,
            'entries': row.entries
        }

    print(f"\nTotal Duplicate Groups Found: {len(duplicates)}")

    return duplicates

def remove_duplicates(db: Session) -> dict:
    """
    Remove duplicate job entries, keeping the most recent one based on created_at.
    Returns statistics about removed entries.
    """
    try:
        delete_query = text("""
        WITH duplicates AS (
            SELECT id
            FROM (
                SELECT 
                    id,
                    source,
                    created_at,
                    CASE 
                        WHEN source = 'LINKEDIN' THEN 
                            REGEXP_REPLACE(job_url, '^.*?/view/(\d+).*$', '\\1')  -- Extract LinkedIn job ID
                        WHEN source = 'INDEED' THEN 
                            REGEXP_REPLACE(job_url, '^.*?jk=([^&]+).*$', '\\1')  -- Extract Indeed job key
                        ELSE job_url
                    END AS normalized_url,
                    ROW_NUMBER() OVER (
                        PARTITION BY 
                            CASE 
                                WHEN source = 'LINKEDIN' THEN 
                                    REGEXP_REPLACE(job_url, '^.*?/view/(\d+).*$', '\\1')
                                WHEN source = 'INDEED' THEN 
                                    REGEXP_REPLACE(job_url, '^.*?jk=([^&]+).*$', '\\1')
                                ELSE job_url
                            END,
                            source  -- Partition also by source to avoid mixing
                        ORDER BY created_at DESC  -- Keep the most recent entry
                    ) as rn
                FROM raw_job_posts
                WHERE source IN ('LINKEDIN', 'INDEED')
            ) ranked
            WHERE rn > 1  -- Select all duplicates except the most recent
        )
        DELETE FROM raw_job_posts
        WHERE id IN (SELECT id FROM duplicates)
        RETURNING id;
        """)

        result = db.execute(delete_query)
        deleted_ids = result.fetchall()
        deleted_count = len(deleted_ids)

        db.commit()

        return {
            "success": True,
            "deleted_count": deleted_count,
            "message": f"Successfully removed {deleted_count} duplicate entries"
        }

    except Exception as e:
        db.rollback()
        return {
            "success": False,
            "deleted_count": 0,
            "message": f"Error removing duplicates: {str(e)}"
        }


def check_linkedin_duplicate(db: Session, job_url: str) -> List[RawJobPost]:
    """
    Check for duplicate LinkedIn jobs based on the job ID number
    """
    job_id = get_linkedin_job_id(job_url)

    query = text("""
    SELECT * FROM raw_job_posts
    WHERE source = 'LINKEDIN'
    AND REGEXP_REPLACE(job_url, '^.*?/view/(\d+).*$', '\\1') = :job_id
    """)

    result = db.execute(query, {'job_id': job_id})
    return [row for row in result]


def check_indeed_duplicate(db: Session, job_url: str) -> List[RawJobPost]:
    """
    Check for duplicate Indeed jobs based on the job key
    """
    job_id = get_indeed_job_id(job_url)

    query = text("""
    SELECT * FROM raw_job_posts
    WHERE source = 'INDEED'
    AND REGEXP_REPLACE(job_url, 'clk\?jk=([^&]+)', '\\1') = :job_id
    """)

    result = db.execute(query, {'job_id': job_id})
    return [row for row in result]


def find_indeed_duplicates_batch(db: Session, job_urls: List[str]) -> List[str]:
    """
    Check a batch of job URLs for duplicates.
    Returns a list of duplicate job keys.
    """
    # Extract job keys from URLs
    job_keys = [get_indeed_job_id(url) for url in job_urls if get_indeed_job_id(url)]

    if not job_keys:
        print("⚠️ No valid job keys found.")
        return []

    print(f"🔍 Checking {len(job_keys)} job keys for duplicates...")

    duplicate_keys = []
    for job_key in job_keys:
        query = text("""
                  SELECT id, job_url, source
                  FROM raw_job_posts
                  WHERE source = 'INDEED'
                  AND job_url LIKE :job_key
              """)
        result = db.execute(query, {'job_key': f'%{job_key}%'})
        if result.rowcount > 0:
            duplicate_keys.append(job_key)
            print(f"🔁 Duplicate found for job key: {job_key}")

    print(f"🔁 Found {len(duplicate_keys)} duplicates.")
    print(f"Duplicate Keys: {duplicate_keys}")
    return duplicate_keys

def find_linkedin_duplicates_batch(db: Session, job_urls: List[str]) -> List[str]:
    """
    Check a batch of LinkedIn job URLs for duplicates.
    Returns a list of duplicate LinkedIn job IDs.
    """
    # Extract LinkedIn job IDs from URLs
    job_ids = [get_linkedin_job_id(url) for url in job_urls if get_linkedin_job_id(url)]

    if not job_ids:
        print("⚠️ No valid LinkedIn job IDs found.")
        return []

    print(f"🔍 Checking {len(job_ids)} LinkedIn job IDs for duplicates...")

    duplicate_ids = []
    for job_id in job_ids:
        query = text("""
            SELECT id, job_url, source
            FROM raw_job_posts
            WHERE source = 'LINKEDIN'
            AND job_url LIKE :job_id
        """)
        result = db.execute(query, {'job_id': f'%{job_id}%'})
        if result.rowcount > 0:
            duplicate_ids.append(job_id)
            print(f"🔁 Duplicate found for job ID: {job_id}")

    print(f"🔁 Found {len(duplicate_ids)} duplicates.")
    print(f"Duplicate LinkedIn Job IDs: {duplicate_ids}")
    return duplicate_ids

def get_job_stats(db: Session) -> Dict[str, Any]:
    """Get statistics about job processing status"""
    query = text("""
    SELECT
        COUNT(*) as total_jobs,
        COUNT(CASE WHEN processed = true THEN 1 END) as processed_jobs,
        COUNT(CASE WHEN processed = false THEN 1 END) as unprocessed_jobs,
        json_object_agg(source, source_count) as sources,
        json_object_agg(job_category, category_count) as categories
    FROM raw_job_posts,
    LATERAL (
        SELECT COUNT(*) as source_count
        FROM raw_job_posts r2
        WHERE r2.source = raw_job_posts.source
    ) source_counts,
    LATERAL (
        SELECT COUNT(*) as category_count
        FROM raw_job_posts r3
        WHERE r3.job_category = raw_job_posts.job_category
    ) category_counts
    GROUP BY source, job_category;
    """)

    result = db.execute(query).first()
    return {
        'total_jobs': result.total_jobs,
        'processed_jobs': result.processed_jobs,
        'unprocessed_jobs': result.unprocessed_jobs,
        'sources': result.sources,
        'categories': result.categories
    }

def find_indeed_job_by_key(db: Session, job_key: str) -> List[Dict[str, Any]]:
    """
    Find Indeed job posts by a specific job key (e.g., "9fbe6877346e4ead") in the job URL.
    """
    query = text("""
    SELECT id, job_url, source, created_at, processed
    FROM raw_job_posts
    WHERE source = 'INDEED'
    AND job_url LIKE :job_key
    """)

    result = db.execute(query, {'job_key': f'%{job_key}%'})
    jobs = result.fetchall()

    # Format the output for display
    return [
        {
            'id': row.id,
            'job_url': row.job_url,
            'source': row.source,
            'created_at': row.created_at,
            'processed': row.processed
        }
        for row in jobs
    ]
def check_hardcoded_duplicates(db: Session):
    # Hardcoded job keys
    job_keys = [
        '9fbe6877346e4ead', '48ab0c91cd56b01e', 'e5d601b7f979b517', 'a040c710ad99d611',
        '6829670a14f292d8', '0a51108ef40cf6de', '2f6f0187ee4998cc', 'e227c36b6d0df790',
        '8c6cd220d7114c91', '2fdbd89dfe8b11ee', 'ea39484702dc96a5', '0fe5810ccfcf3943',
        '469f4c69fcc59669', 'b13a1133d9e2cd1f', 'bc09b62cbf0aa9d4'
    ]

    print(f"🔍 Checking {len(job_keys)} hardcoded job keys for duplicates...")

    duplicate_keys = []
    for job_key in job_keys:
        query = text("""
               SELECT id, job_url, source
               FROM raw_job_posts
               WHERE source = 'INDEED'
               AND job_url LIKE :job_key
           """)
        result = db.execute(query, {'job_key': f'%{job_key}%'})
        if result.rowcount > 0:
            duplicate_keys.append(job_key)
            print(f"🔁 Duplicate found for job key: {job_key}")

    print(f"🔁 Found {len(duplicate_keys)} duplicates.")
    print(f"Duplicate Keys: {duplicate_keys}")
    return duplicate_keys


# Separate execution
def main():
    with SessionLocal() as db:
        job_key = "9fbe6877346e4ead"
        jobs = find_indeed_job_by_key(db, job_key)

        if jobs:
            print(f"\nFound {len(jobs)} jobs containing '{job_key}' in the URL:")
            for job in jobs:
                print(f"ID: {job['id']}, URL: {job['job_url']}, Source: {job['source']}, Processed: {job['processed']}")
        else:
            print(f"No jobs found with '{job_key}' in the URL.")

        check_hardcoded_duplicates(db)


if __name__ == "__main__":
    main()