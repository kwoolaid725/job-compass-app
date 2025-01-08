import os
import sys
from dotenv import load_dotenv
import argparse
from sqlalchemy import create_engine
from app.scrapers.scraper_main import main as scraper_main


def test_database_connection():
    """Test database connection"""
    try:
        # Load environment variables
        load_dotenv()

        # Get database credentials
        db_config = {
            'dbname': os.getenv('DATABASE_NAME'),
            'user': os.getenv('DATABASE_USERNAME'),
            'password': os.getenv('DATABASE_PASSWORD'),
            'host': os.getenv('DATABASE_HOSTNAME'),
            'port': os.getenv('DATABASE_PORT', 5432)
        }

        # Try to connect
        db_url = f"postgresql://{db_config['user']}:{db_config['password']}@{db_config['host']}:{db_config['port']}/{db_config['dbname']}"
        engine = create_engine(db_url)
        with engine.connect() as conn:
            print("✅ Database connection successful!")
        return True
    except Exception as e:
        print(f"❌ Database connection failed: {e}")
        return False


def test_linkedin_credentials():
    """Test LinkedIn credentials"""
    email = os.getenv('LINKEDIN_EMAIL')
    password = os.getenv('LINKEDIN_PASSWORD')

    if not email or not password:
        print("❌ LinkedIn credentials not found in environment variables")
        return False

    print("✅ LinkedIn credentials found")
    return True


def test_dependencies():
    """Test if all required packages are installed"""
    required_packages = [
        'playwright',
        'playwright-stealth',
        'sqlalchemy',
        'psycopg2-binary',
    ]

    missing_packages = []
    for package in required_packages:
        try:
            module_name = package.replace('-', '_')
            __import__(module_name)
            print(f"✅ {package} is installed")
        except ImportError:
            try:
                import importlib.metadata
                version = importlib.metadata.version(package)
                print(f"✅ {package} is installed (version: {version})")
            except Exception:
                missing_packages.append(package)
                print(f"❌ {package} is missing")

    return len(missing_packages) == 0

def run_test_scrape(source: str, category: str):
    """Run a test scrape for one source/category"""
    print(f"\nTesting scraper for {source} - {category}")
    try:
        # Create test arguments
        test_args = ['--source', source, '--category', category]

        # Run scraper with test arguments
        scraper_main(test_args)
        print(f"✅ Test scrape successful for {source} - {category}")
        return True
    except Exception as e:
        print(f"❌ Test scrape failed for {source} - {category}: {e}")
        return False


def main():
    parser = argparse.ArgumentParser(description='Test Job Scraper')
    parser.add_argument('--source', type=str, choices=['indeed', 'linkedin'],
                        help='Source to test (indeed or linkedin)')
    parser.add_argument('--category', type=str,
                        choices=['python_developer', 'data_engineer', 'data_scientist'],
                        help='Category to test')
    parser.add_argument('--all', action='store_true',
                        help='Run all pre-deployment checks')

    args = parser.parse_args()

    print("🔍 Running pre-deployment checks...")

    # Check environment and dependencies
    checks_passed = True

    print("\n1. Testing database connection...")
    if not test_database_connection():
        checks_passed = False

    print("\n2. Testing LinkedIn credentials...")
    if not test_linkedin_credentials():
        checks_passed = False

    print("\n3. Testing dependencies...")
    if not test_dependencies():
        checks_passed = False

    # Run test scrape if requested
    if args.source and args.category:
        print(f"\n4. Running test scrape for {args.source} - {args.category}...")
        if not run_test_scrape(args.source, args.category):
            checks_passed = False

    # Final results
    print("\n📋 Test Results Summary:")
    if checks_passed:
        print("✅ All checks passed! Ready for deployment.")
        return 0
    else:
        print("❌ Some checks failed. Please fix issues before deploying.")
        return 1


if __name__ == "__main__":
    sys.exit(main())