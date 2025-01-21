import pendulum
from datetime import timedelta
from airflow import DAG
from airflow.providers.docker.operators.docker import DockerOperator
from airflow.models import Variable
from docker.types import Mount

local_tz = pendulum.timezone("America/Chicago")

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': local_tz.datetime(2024, 1, 1),
    'email': [],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

SCRAPER_CONFIGS = [
    {"source": "indeed", "category": "data_engineer", "max_pages": 15},
    {"source": "indeed", "category": "data_scientist", "max_pages": 15},
    {"source": "indeed", "category": "python_developer", "max_pages": 15},
    {"source": "linkedin", "category": "data_engineer", "max_pages": 15},
    {"source": "linkedin", "category": "data_scientist", "max_pages": 15},
    {"source": "linkedin", "category": "python_developer", "max_pages": 15},
    {"source": "builtinchicago", "category": "data_engineer", "max_pages": 15},
    {"source": "builtinchicago", "category": "data_scientist", "max_pages": 15},
    {"source": "builtinchicago", "category": "python_developer", "max_pages": 15},
]

with DAG(
        'job_scraper',
        default_args=default_args,
        description='Schedule job scraping and processing tasks',
        schedule_interval='0 9,21 * * *',
        catchup=False
) as dag:
    # 1. Scraping Tasks
    scraping_tasks = []
    for config in SCRAPER_CONFIGS:
        task = DockerOperator(
            task_id=f'scrape_{config["source"]}_{config["category"]}',
            image='job-search-scraper:latest',
            command=(
                f'python -m app.scrapers.scraper_main '
                f'--source {config["source"]} '
                f'--category {config["category"]} '
                f'--max_pages {config["max_pages"]}'
            ),
            network_mode='job-search_scraper_network',
            api_version='auto',
            docker_url='unix://var/run/docker.sock',
            auto_remove=True,
            environment={
                'DATABASE_HOSTNAME': 'db',
                'DATABASE_PORT': '5432',
                'DATABASE_USERNAME': '{{ var.value.DATABASE_USERNAME }}',
                'DATABASE_PASSWORD': '{{ var.value.DATABASE_PASSWORD }}',
                'DATABASE_NAME': 'job_postings',
                'FLARESOLVERR_URL': 'http://flaresolverr:8191/v1',
                'PYTHONUNBUFFERED': '1',
                'LINKEDIN_EMAIL': '{{ var.value.LINKEDIN_EMAIL }}',
                'LINKEDIN_PASSWORD': '{{ var.value.LINKEDIN_PASSWORD }}'
            },
            force_pull=False,
            mounts=[
                Mount(
                    source='/var/run/docker.sock',
                    target='/var/run/docker.sock',
                    type='bind'
                ),
                Mount(
                    source='scraper_logs',
                    target='/app/logs',
                    type='volume',
                    driver_config={
                        'type': 'volume',
                        'driver': 'local',
                        'o': 'bind'
                    }
                )
            ],
            mount_tmp_dir=False,
            privileged=True,
            working_dir='/app'
        )
        scraping_tasks.append(task)

    # 2. Processing Task (optional based on Variable)
    process_jobs = DockerOperator(
        task_id='process_raw_jobs',
        image='job-search-scraper:latest',
        command='python /app/scripts/process_jobs.py',
        network_mode='job-search_scraper_network',
        api_version='auto',
        docker_url='unix://var/run/docker.sock',
        auto_remove=True,
        environment={
            'DATABASE_HOSTNAME': 'db',
            'DATABASE_PORT': '5432',
            'DATABASE_USERNAME': '{{ var.value.DATABASE_USERNAME }}',
            'DATABASE_PASSWORD': '{{ var.value.DATABASE_PASSWORD }}',
            'DATABASE_NAME': 'job_postings',
            'FLARESOLVERR_URL': 'http://flaresolverr:8191/v1',
            'PYTHONUNBUFFERED': '1',
            'LINKEDIN_EMAIL': '{{ var.value.LINKEDIN_EMAIL }}',
            'LINKEDIN_PASSWORD': '{{ var.value.LINKEDIN_PASSWORD }}'
        },
        force_pull=False,
        mounts=[
            Mount(
                source='/var/run/docker.sock',
                target='/var/run/docker.sock',
                type='bind'
            ),
            Mount(
                source='scraper_logs',
                target='/app/logs',
                type='volume',
                driver_config={
                    'type': 'volume',
                    'driver': 'local',
                    'o': 'bind'
                }
            )
        ],
        mount_tmp_dir=False,
        privileged=True,
        working_dir='/app'
    )

    # 3. Skills Population Task (optional based on Variable)
    populate_skills = DockerOperator(
        task_id='populate_skills',
        image='job-search-scraper:latest',
        command='python /app/scripts/populate_skills.py',
        network_mode='job-search_scraper_network',
        api_version='auto',
        docker_url='unix://var/run/docker.sock',
        auto_remove=True,
        environment={
            'DATABASE_HOSTNAME': 'db',
            'DATABASE_PORT': '5432',
            'DATABASE_USERNAME': '{{ var.value.DATABASE_USERNAME }}',
            'DATABASE_PASSWORD': '{{ var.value.DATABASE_PASSWORD }}',
            'DATABASE_NAME': 'job_postings',
            'PYTHONUNBUFFERED': '1'
        },
        force_pull=False,
        mounts=[
            Mount(
                source='/var/run/docker.sock',
                target='/var/run/docker.sock',
                type='bind'
            ),
            Mount(
                source='scraper_logs',
                target='/app/logs',
                type='volume',
                driver_config={
                    'type': 'volume',
                    'driver': 'local',
                    'o': 'bind'
                }
            )
        ],
        mount_tmp_dir=False,
        privileged=True,
        working_dir='/app'
    )

    # Set up task dependencies based on Variables
    process_enabled = Variable.get("enable_job_processing", default_var="true").lower() == "true"
    skills_enabled = Variable.get("enable_skills_population", default_var="true").lower() == "true"

    # Always run scraping tasks first
    if process_enabled and skills_enabled:
        # Run full pipeline
        scraping_tasks >> process_jobs >> populate_skills
    elif process_enabled:
        # Run scraping and processing only
        scraping_tasks >> process_jobs
    elif skills_enabled:
        # Run scraping and skills population only
        scraping_tasks >> populate_skills
    else:
        # Run only scraping
        pass