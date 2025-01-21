from app.crud.job_queries import find_duplicates, remove_duplicates
from app.database import SessionLocal
from typing import Dict


def display_duplicates(duplicates: Dict):
    for normalized_url, duplicate_info in duplicates.items():
        print(f"\n🔍 Duplicate Group (Normalized URL: {normalized_url}):")
        print(f"   Total Duplicates: {duplicate_info['count']}")
        print("   Duplicate Entries:")

        for entry in duplicate_info['entries']:
            print(f"   - ID: {entry['id']}")
            print(f"     URL: {entry['job_url']}")
            print(f"     Source: {entry['source']}")
            print(f"     Category: {entry.get('job_category', 'N/A')}")  # Use .get() to avoid KeyError
            print(f"     Created At: {entry['created_at']}")
            print(f"     Processed: {entry.get('processed', 'Unknown')}")
            print("   ---")


def main():
    with SessionLocal() as db:
        # First check for duplicates
        duplicates = find_duplicates(db)

        if duplicates:
            print(f"\n❗ Found {len(duplicates)} groups of duplicate jobs")

            # Display detailed duplicate information
            display_duplicates(duplicates)

            # Ask for confirmation
            response = input("\n🤔 Do you want to remove duplicates? (y/n): ")

            if response.lower() == 'y':
                result = remove_duplicates(db)
                print(f"\n{result['message']}")

                # Verify duplicates are gone
                remaining_duplicates = find_duplicates(db)

                if not remaining_duplicates:
                    print("✅ All duplicates have been successfully removed")
                else:
                    print(f"⚠️ {len(remaining_duplicates)} duplicate groups still remain")

                    # Optional: Display remaining duplicates
                    choice = input("Do you want to view remaining duplicates? (y/n): ")
                    if choice.lower() == 'y':
                        display_duplicates(remaining_duplicates)
            else:
                print("Operation cancelled")
        else:
            print("No duplicates found")


if __name__ == "__main__":
    main()