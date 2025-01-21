from sqlalchemy import text
from app.crud.job_queries import (
    find_duplicates,
    remove_duplicates,
    find_processed_job_duplicates,
    remove_processed_job_duplicates,
    remove_duplicates_with_cascade
)
from app.database import SessionLocal
from typing import Dict



def display_duplicates(duplicates: Dict):
    for normalized_url, duplicate_info in duplicates.items():
        print(f"\n🔍 Duplicate Group (Normalized URL: {normalized_url}):")
        print(f"   Total Duplicates: {duplicate_info['count']}")
        print("   Duplicate Entries:")

        for entry in duplicate_info['entries']:
            print(f"   - ID: {entry['id']}")
            if 'job_url' in entry:  # For raw jobs
                print(f"     URL: {entry['job_url']}")
                print(f"     Source: {entry['source']}")
            else:  # For processed jobs
                print(f"     Title: {entry['title']}")
                print(f"     Company: {entry['company']}")
            print(f"     Created At: {entry['created_at']}")
            print("   ---")


def cleanup_processed_jobs(db) -> dict:
    """
    Find and remove duplicate processed jobs in one operation.
    """
    try:
        # First find duplicates
        duplicates = find_processed_job_duplicates(db)

        if not duplicates:
            return {
                "success": True,
                "deleted_count": 0,
                "message": "No duplicates found in processed_jobs table"
            }

        # Display the duplicates found
        print("\n=== Found Duplicates in Processed Jobs ===")
        for raw_job_id, duplicate_info in duplicates.items():
            print(f"\n🔍 Duplicate Group for Raw Job ID: {raw_job_id}")
            print(f"   Total Duplicates: {duplicate_info['count']}")
            for entry in duplicate_info['entries']:
                print(f"   - ID: {entry['id']}")
                print(f"     Title: {entry['title']}")
                print(f"     Company: {entry['company']}")
                print(f"     Created At: {entry['created_at']}")
                print("   ---")

        # Ask for confirmation
        response = input("\n🤔 Do you want to remove these duplicates from processed_jobs? (y/n): ")

        if response.lower() != 'y':
            return {
                "success": False,
                "message": "Operation cancelled by user"
            }

        # Remove duplicates
        result = remove_processed_job_duplicates(db)

        if result["success"]:
            return {
                "success": True,
                "duplicate_groups_found": len(duplicates),
                "deleted_count": result["deleted_count"],
                "message": f"Successfully found {len(duplicates)} duplicate groups and removed {result['deleted_count']} duplicate entries"
            }
        else:
            return result

    except Exception as e:
        return {
            "success": False,
            "message": f"Error during cleanup: {str(e)}"
        }




def main():
    with SessionLocal() as db:
        print("\n=== Job Database Cleanup Utility ===")


        choice = input(
            "\nSelect operation:\n1. Clean up raw job posts\n2. Clean up processed jobs\nEnter choice (1/2): ")

        if choice == '1':
            duplicates = find_duplicates(db)
            if duplicates:
                print(f"\n❗ Found {len(duplicates)} groups of duplicate jobs")
                display_duplicates(duplicates)
                response = input("\n🤔 Do you want to remove duplicates? (y/n): ")
                if response.lower() == 'y':
                    result = remove_duplicates_with_cascade(db)
                    print(f"\n{result['message']}")

        elif choice == '2':
            result = cleanup_processed_jobs(db)
            print(f"\n=== Cleanup Results ===")
            print(f"Success: {result['success']}")
            print(f"Message: {result['message']}")


if __name__ == "__main__":
    main()