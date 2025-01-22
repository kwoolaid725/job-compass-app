# app/config.py
from pydantic_settings import BaseSettings
from functools import lru_cache
import os
from dotenv import load_dotenv

# Load .env file from the same directory as this file
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), '.env'))

class Settings(BaseSettings):
    # Database settings
    DATABASE_USERNAME: str = os.getenv('DATABASE_USERNAME')
    DATABASE_PASSWORD: str = os.getenv('DATABASE_PASSWORD')
    DATABASE_HOSTNAME: str = os.getenv('DATABASE_HOSTNAME')
    DATABASE_PORT: int = int(os.getenv('DATABASE_PORT', '5432'))
    DATABASE_NAME: str = os.getenv('DATABASE_NAME')

    # Add new settings
    OPENAI_API_KEY: str = os.getenv('OPENAI_API_KEY', '')
    LINKEDIN_EMAIL: str = os.getenv('LINKEDIN_EMAIL', '')
    LINKEDIN_PASSWORD: str = os.getenv('LINKEDIN_PASSWORD', '')
    AIRFLOW_USER: str = os.getenv('AIRFLOW_USER', '')
    AIRFLOW_PASSWORD: str = os.getenv('AIRFLOW_PASSWORD', '')
    AIRFLOW_SECRET_KEY: str = os.getenv('AIRFLOW_SECRET_KEY', '')
    UID: str = os.getenv('UID', '')
    GID: str = os.getenv('GID', '')
    AIRFLOW__DATABASE__SQL_ALCHEMY_CONN: str = os.getenv('AIRFLOW__DATABASE__SQL_ALCHEMY_CONN', '')

    @property
    def DATABASE_URL(self) -> str:
        return (
            f'postgresql://{self.DATABASE_USERNAME}:{self.DATABASE_PASSWORD}@'
            f'{self.DATABASE_HOSTNAME}:{self.DATABASE_PORT}/{self.DATABASE_NAME}'
        )

    class Config:
        env_file = '.env'
        case_sensitive = True


@lru_cache()
def get_settings():
    return Settings()


settings = get_settings()