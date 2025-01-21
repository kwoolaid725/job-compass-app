# app/crud/job_queries.py
from sqlalchemy.orm import Session
from sqlalchemy import text
import re
from app.models.job import RawJobPost, JobSource
from typing import List, Dict, Any
from app.database import SessionLocal  # Make sure to import SessionLocal
import json
import os

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

def get_builtinchicago_job_id(url: str) -> str:
    """Extract the job ID from a BuiltIn job URL"""
    match = re.search(r'/(\d+)$', url)
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
                WHEN source = 'BUILTINCHICAGO' THEN
                    REGEXP_REPLACE(job_url, '^.*?/(\d+)$', '\\1')  -- Extract BuiltIn job ID
                ELSE job_url  -- Use full URL for other sources
            END AS normalized_url
        FROM raw_job_posts
        WHERE source IN ('LINKEDIN', 'INDEED', 'BUILTINCHICAGO')
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
    try:
        delete_query = text("""
        WITH duplicate_groups AS (
            SELECT 
                id,
                source,
                created_at,
                CASE 
                    WHEN source = 'LINKEDIN' THEN 
                        REGEXP_REPLACE(job_url, '^.*?/view/(\d+).*$', '\\1')
                    WHEN source = 'INDEED' THEN 
                        REGEXP_REPLACE(job_url, '^.*?jk=([^&]+).*$', '\\1')
                    WHEN source = 'BUILTINCHICAGO' THEN
                        REGEXP_REPLACE(job_url, '^.*?/(\d+)$', '\\1')
                    ELSE job_url
                END AS normalized_url,
                ROW_NUMBER() OVER (
                    PARTITION BY 
                        CASE 
                            WHEN source = 'LINKEDIN' THEN 
                                REGEXP_REPLACE(job_url, '^.*?/view/(\d+).*$', '\\1')
                            WHEN source = 'INDEED' THEN 
                                REGEXP_REPLACE(job_url, '^.*?jk=([^&]+).*$', '\\1')
                            WHEN source = 'BUILTINCHICAGO' THEN
                                REGEXP_REPLACE(job_url, '^.*?/(\d+)$', '\\1')
                            ELSE job_url
                        END,
                        source
                    ORDER BY created_at DESC
                ) as rn
            FROM raw_job_posts
            WHERE source IN ('LINKEDIN', 'INDEED', 'BUILTINCHICAGO')
        ),
        deletable_ids AS (
            SELECT dg.id
            FROM duplicate_groups dg
            WHERE dg.rn > 1
            AND NOT EXISTS (
                SELECT 1 
                FROM processed_jobs pj 
                WHERE pj.raw_job_post_id = dg.id
            )
        )
        DELETE FROM raw_job_posts
        WHERE id IN (SELECT id FROM deletable_ids)
        RETURNING id;
        """)

        result = db.execute(delete_query)
        deleted_ids = result.fetchall()
        deleted_count = len(deleted_ids)

        db.commit()

        # Get count of skipped deletions due to foreign key constraints
        skipped_query = text("""
        WITH duplicate_groups AS (
            SELECT 
                id,
                CASE 
                    WHEN source = 'LINKEDIN' THEN 
                        REGEXP_REPLACE(job_url, '^.*?/view/(\d+).*$', '\\1')
                    WHEN source = 'INDEED' THEN 
                        REGEXP_REPLACE(job_url, '^.*?jk=([^&]+).*$', '\\1')
                    WHEN source = 'BUILTINCHICAGO' THEN
                        REGEXP_REPLACE(job_url, '^.*?/(\d+)$', '\\1')
                    ELSE job_url
                END AS normalized_url,
                ROW_NUMBER() OVER (
                    PARTITION BY 
                        CASE 
                            WHEN source = 'LINKEDIN' THEN 
                                REGEXP_REPLACE(job_url, '^.*?/view/(\d+).*$', '\\1')
                            WHEN source = 'INDEED' THEN 
                                REGEXP_REPLACE(job_url, '^.*?jk=([^&]+).*$', '\\1')
                            WHEN source = 'BUILTINCHICAGO' THEN
                                REGEXP_REPLACE(job_url, '^.*?/(\d+)$', '\\1')
                            ELSE job_url
                        END,
                        source
                    ORDER BY created_at DESC
                ) as rn
            FROM raw_job_posts
            WHERE source IN ('LINKEDIN', 'INDEED', 'BUILTINCHICAGO')
        )
        SELECT COUNT(*) as skipped_count
        FROM duplicate_groups dg
        WHERE dg.rn > 1
        AND EXISTS (
            SELECT 1 
            FROM processed_jobs pj 
            WHERE pj.raw_job_post_id = dg.id
        );
        """)

        skipped_result = db.execute(skipped_query)
        skipped_count = skipped_result.scalar()

        return {
            "success": True,
            "deleted_count": deleted_count,
            "skipped_count": skipped_count,
            "message": f"Successfully removed {deleted_count} duplicate entries. Skipped {skipped_count} entries due to processed job references."
        }

    except Exception as e:
        db.rollback()
        return {
            "success": False,
            "deleted_count": 0,
            "skipped_count": 0,
            "message": f"Error removing duplicates: {str(e)}"
        }

def find_processed_job_duplicates(db: Session) -> Dict[str, List[Dict[str, Any]]]:
    """Find duplicate entries in processed_jobs table based on job URLs from raw_job_posts"""
    query = text("""
    WITH duplicate_groups AS (
        SELECT 
            rj.job_url,
            COUNT(*) as count,
            array_agg(json_build_object(
                'id', pj.id,
                'title', pj.title,
                'company', pj.company,
                'raw_job_post_id', pj.raw_job_post_id,
                'job_url', rj.job_url,
                'created_at', pj.created_at
            ) ORDER BY pj.created_at DESC) as entries
        FROM processed_jobs pj
        JOIN raw_job_posts rj ON pj.raw_job_post_id = rj.id
        GROUP BY rj.job_url
        HAVING COUNT(*) > 1
    )
    SELECT 
        job_url, 
        count, 
        entries
    FROM duplicate_groups
    ORDER BY count DESC;
    """)

    result = db.execute(query)
    duplicates = {}

    print("\n=== Processed Jobs Duplicate Detection ===")

    for row in result:
        print(f"\nDuplicate Group for URL: {row.job_url}")
        print(f"Duplicate Count: {row.count}")
        print("Duplicate Entries:")

        for entry in row.entries:
            print(f"  - ID: {entry['id']}")
            print(f"    Title: {entry['title']}")
            print(f"    Company: {entry['company']}")
            print(f"    Raw Job Post ID: {entry['raw_job_post_id']}")
            print(f"    Created At: {entry['created_at']}")
            print("    ---")

        duplicates[row.job_url] = {
            'count': row.count,
            'entries': row.entries
        }

    print(f"\nTotal Duplicate Groups Found: {len(duplicates)}")

    return duplicates

def remove_processed_job_duplicates(db: Session) -> dict:
    """
    Remove duplicate entries from processed_jobs table, keeping only the most recent entry
    for each unique job URL.
    """
    try:
        delete_query = text("""
        WITH duplicates AS (
            SELECT pj.id
            FROM (
                SELECT 
                    pj.id,
                    pj.created_at,
                    rj.job_url,
                    ROW_NUMBER() OVER (
                        PARTITION BY rj.job_url
                        ORDER BY pj.created_at DESC
                    ) as rn
                FROM processed_jobs pj
                JOIN raw_job_posts rj ON pj.raw_job_post_id = rj.id
                WHERE rj.job_url IS NOT NULL
            ) pj
            WHERE pj.rn > 1
        )
        DELETE FROM processed_jobs
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
            "message": f"Successfully removed {deleted_count} duplicate processed job entries based on job URLs"
        }

    except Exception as e:
        db.rollback()
        return {
            "success": False,
            "deleted_count": 0,
            "message": f"Error removing duplicates: {str(e)}"
        }


def remove_duplicates_with_cascade(db: Session) -> dict:
    """Remove duplicate raw jobs and their processed entries, keeping the newest of each duplicate group."""
    try:
        # First identify the raw job IDs to delete
        identify_query = text("""
        WITH duplicate_groups AS (
            SELECT 
                id,
                source,
                CASE 
                    WHEN source = 'LINKEDIN' THEN 
                        REGEXP_REPLACE(job_url, '^.*?/view/(\d+).*$', '\\1')
                    WHEN source = 'INDEED' THEN 
                        REGEXP_REPLACE(job_url, '^.*?jk=([^&]+).*$', '\\1')
                    WHEN source = 'BUILTINCHICAGO' THEN
                        REGEXP_REPLACE(job_url, '^.*?/(\d+)$', '\\1')
                    ELSE job_url
                END AS normalized_url,
                ROW_NUMBER() OVER (
                    PARTITION BY 
                        CASE 
                            WHEN source = 'LINKEDIN' THEN 
                                REGEXP_REPLACE(job_url, '^.*?/view/(\d+).*$', '\\1')
                            WHEN source = 'INDEED' THEN 
                                REGEXP_REPLACE(job_url, '^.*?jk=([^&]+).*$', '\\1')
                            WHEN source = 'BUILTINCHICAGO' THEN
                                REGEXP_REPLACE(job_url, '^.*?/(\d+)$', '\\1')
                            ELSE job_url
                        END,
                        source
                    ORDER BY created_at DESC
                ) as rn
            FROM raw_job_posts
            WHERE source IN ('LINKEDIN', 'INDEED', 'BUILTINCHICAGO')
        )
        SELECT id
        FROM duplicate_groups
        WHERE rn > 1;
        """)

        # Get IDs to delete
        result = db.execute(identify_query)
        ids_to_delete = [row[0] for row in result]

        if not ids_to_delete:
            return {
                "success": True,
                "deleted_count": 0,
                "message": "No duplicates found to remove"
            }

        # First delete from processed_jobs
        process_delete_query = text("""
        DELETE FROM processed_jobs
        WHERE raw_job_post_id = ANY(:ids);
        """)

        db.execute(process_delete_query, {"ids": ids_to_delete})

        # Then delete from raw_job_posts
        raw_delete_query = text("""
        DELETE FROM raw_job_posts
        WHERE id = ANY(:ids)
        RETURNING id;
        """)

        delete_result = db.execute(raw_delete_query, {"ids": ids_to_delete})
        deleted_ids = delete_result.fetchall()
        deleted_count = len(deleted_ids)

        db.commit()

        return {
            "success": True,
            "deleted_count": deleted_count,
            "message": f"Successfully removed {deleted_count} duplicate entries and their processed jobs"
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

def find_builtinchicago_duplicates_batch(db: Session, job_urls: List[str]) -> List[str]:
    """
    Check a batch of BuiltIn job URLs for duplicates.
    Returns a list of duplicate BuiltIn job IDs.
    """
    # Extract BuiltIn job IDs from URLs
    job_ids = [get_builtinchicago_job_id(url) for url in job_urls if get_builtinchicago_job_id(url)]

    if not job_ids:
        print("⚠️ No valid BuiltIn job IDs found.")
        return []

    print(f"🔍 Checking {len(job_ids)} BuiltInChicago job IDs for duplicates...")

    duplicate_ids = []
    for job_id in job_ids:
        query = text("""
            SELECT id, job_url, source
            FROM raw_job_posts
            WHERE source = 'BUILTINCHICAGO'
            AND job_url LIKE :job_id
        """)
        result = db.execute(query, {'job_id': f'%{job_id}%'})
        if result.rowcount > 0:
            duplicate_ids.append(job_id)
            print(f"🔁 Duplicate found for job ID: {job_id}")

    print(f"🔁 Found {len(duplicate_ids)} duplicates.")
    print(f"Duplicate BuiltInChicago Job IDs: {duplicate_ids}")
    return duplicate_ids

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


def get_raw_job_by_url(db: Session, job_url: str) -> List[Dict[str, Any]]:
    """
    Get all fields from raw_job_posts for a specific URL.

    Args:
        db (Session): Database session
        job_url (str): The job URL to search for

    Returns:
        List[Dict[str, Any]]: List of jobs matching the URL with all their fields
    """
    try:
        # Using text() for raw SQL
        query = text("""
        SELECT *
        FROM raw_job_posts
        WHERE job_url = :job_url;
        """)

        # Execute query with the URL parameter
        result = db.execute(query, {'job_url': job_url})

        # Convert rows to dictionaries properly using _mapping
        jobs = [dict(row._mapping) for row in result]

        if not jobs:
            print(f"No jobs found for URL: {job_url}")
            return []

        return jobs

    except Exception as e:
        print(f"Error querying database: {str(e)}")
        return []


def delete_builtinchicago_jobs(db: Session) -> dict:
    """
    Delete all BuiltInChicago job posts from raw_job_posts.

    Returns:
        A dictionary with deletion statistics
    """
    try:
        delete_query = text("""
        DELETE FROM raw_job_posts 
        WHERE source = 'BUILTINCHICAGO'
        RETURNING id;
        """)

        result = db.execute(delete_query)
        deleted_ids = result.fetchall()
        deleted_count = len(deleted_ids)

        db.commit()

        return {
            "success": True,
            "deleted_count": deleted_count,
            "message": f"Successfully removed {deleted_count} BuiltInChicago job entries"
        }

    except Exception as e:
        db.rollback()
        return {
            "success": False,
            "deleted_count": 0,
            "message": f"Error removing BuiltInChicago jobs: {str(e)}"
        }


def get_source_samples(db: Session, sample_size: int = 10) -> Dict[str, List[Dict[str, Any]]]:
    """
    Retrieve sample rows for each unique job source from raw_job_posts.

    Args:
        db (Session): Database session
        sample_size (int, optional): Number of samples to retrieve per source. Defaults to 10.

    Returns:
        Dict[str, List[Dict[str, Any]]]: A dictionary with source as key and list of sample rows as value
    """
    query = text("""
   WITH source_samples AS (
       SELECT 
           *,
           ROW_NUMBER() OVER (PARTITION BY source ORDER BY RANDOM()) as rn
       FROM raw_job_posts
   )
   SELECT 
       source, 
       json_agg(json_build_object(
           'id', id, 
           'job_url', job_url, 
           'raw_content', raw_content,
           'source', source,
           'job_category', job_category,
           'created_at', created_at,
           'processed', processed,
           'salary_text', salary_text,
           'salary_from_api', salary_from_api
       )) as sample_rows
   FROM source_samples
   WHERE rn <= :sample_size
   GROUP BY source;
   """)

    result = db.execute(query, {'sample_size': sample_size})

    samples = {}
    for row in result:
        samples[row.source] = row.sample_rows

    return samples


def check_job_location_structure(db: Session):
    """Check BuiltInChicago jobs where jobLocation is a list in the raw_content"""
    query = text("""
    WITH parsed_jobs AS (
        SELECT 
            id,
            job_url,
            created_at,
            CASE 
                WHEN raw_content::jsonb->>'json_ld' IS NOT NULL THEN 
                    (raw_content::jsonb->>'json_ld')::jsonb
                ELSE 
                    raw_content::jsonb
            END as job_data
        FROM raw_job_posts
        WHERE source = 'BUILTINCHICAGO'
    )
    SELECT 
        id,
        job_url,
        created_at,
        job_data->>'jobLocation' as job_location_raw,
        jsonb_typeof(job_data->'jobLocation') as location_type,
        job_data->'jobLocation' as location_data
    FROM parsed_jobs
    WHERE jsonb_typeof(job_data->'jobLocation') = 'array'
    ORDER BY created_at DESC;
    """)

    try:
        result = db.execute(query)
        rows = result.fetchall()

        print(f"\nFound {len(rows)} jobs with array-type jobLocation")

        for row in rows:
            print("\n=== Job Details ===")
            print(f"ID: {row.id}")
            print(f"URL: {row.job_url}")
            print(f"Created: {row.created_at}")
            print(f"Location Type: {row.location_type}")
            print(f"Location Data: {row.location_data}")
            print("---")

        return rows

    except Exception as e:
        print(f"Error executing query: {e}")
        print("\nTrying alternative query...")

        # Fallback query that just shows the raw data structure
        fallback_query = text("""
        SELECT 
            id,
            job_url,
            created_at,
            raw_content
        FROM raw_job_posts
        WHERE source = 'BUILTINCHICAGO'
        ORDER BY created_at DESC
        LIMIT 5;
        """)

        try:
            result = db.execute(fallback_query)
            rows = result.fetchall()

            for row in rows:
                print("\n=== Raw Job Details ===")
                print(f"ID: {row.id}")
                print(f"URL: {row.job_url}")
                print(f"Created: {row.created_at}")
                raw_data = json.loads(row.raw_content)
                if 'json_ld' in raw_data:
                    print("\nJSON-LD Structure:")
                    if 'jobLocation' in raw_data['json_ld']:
                        print(f"jobLocation type: {type(raw_data['json_ld']['jobLocation'])}")
                        print(f"jobLocation content: {raw_data['json_ld']['jobLocation']}")
                print("---")

        except Exception as e:
            print(f"Error in fallback query: {e}")

        return []


def check_experience_level_distribution(db: Session):
    """Check experience level distribution and their raw values in processed jobs"""
    query = text("""
    SELECT 
        experience_level,
        COUNT(*) as count,
        array_agg(DISTINCT title) as sample_titles,
        MIN(created_at) as first_seen,
        MAX(created_at) as last_seen
    FROM processed_jobs
    WHERE experience_level IS NOT NULL
    GROUP BY experience_level
    ORDER BY count DESC;
    """)

    try:
        result = db.execute(query)
        rows = result.fetchall()

        print(f"\nFound {len(rows)} distinct experience levels")

        total_jobs = sum(row.count for row in rows)
        print(f"Total jobs with experience level: {total_jobs}\n")

        for row in rows:
            print("\n=== Experience Level Details ===")
            print(f"Level: {row.experience_level}")
            print(f"Count: {row.count} ({(row.count / total_jobs * 100):.1f}%)")
            print(f"First seen: {row.first_seen}")
            print(f"Last seen: {row.last_seen}")
            print("\nSample job titles:")
            # Show up to 3 sample titles
            for title in row.sample_titles[:3]:
                print(f"- {title}")
            print("---")

        return rows

    except Exception as e:
        print(f"Error executing query: {e}")
        print("\nTrying alternative query...")

        # Fallback query that just shows raw experience level data
        fallback_query = text("""
        SELECT 
            id,
            title,
            experience_level,
            created_at
        FROM processed_jobs
        WHERE experience_level IS NOT NULL
        ORDER BY created_at DESC
        LIMIT 10;
        """)

        try:
            result = db.execute(fallback_query)
            rows = result.fetchall()

            for row in rows:
                print("\n=== Raw Job Details ===")
                print(f"ID: {row.id}")
                print(f"Title: {row.title}")
                print(f"Experience Level: {row.experience_level}")
                print(f"Created: {row.created_at}")
                print("---")

        except Exception as e:
            print(f"Error in fallback query: {e}")

# def main():
#     # Create fixtures directory if it doesn't exist
#     fixtures_dir = '../tests/fixtures/'
#     os.makedirs(fixtures_dir, exist_ok=True)
#
#     output_file = os.path.join(fixtures_dir, 'job_fixtures.json')
#
#     with SessionLocal() as db:
#         source_samples = get_source_samples(db)
#
#         # Combine all samples into a single list
#         all_samples = []
#         for samples in source_samples.values():
#             all_samples.extend(samples)
#
#         # Create output dictionary
#         output = {
#             "sample_jobs": all_samples,
#             "total_samples": len(all_samples)
#         }
#
#         # Save to file
#         with open(output_file, 'w', encoding='utf-8') as f:
#             json.dump(output, f, indent=2, default=str)
#
#         print(f"✅ Saved {len(all_samples)} sample jobs to {output_file}")
#         print(
#             f"Samples per source: {', '.join(f'{source}: {len(samples)}' for source, samples in source_samples.items())}")

if __name__ == "__main__":
    db = SessionLocal()
    try:
        check_experience_level_distribution(db)
    finally:
        db.close()

# if __name__ == "__main__":
#     main()

