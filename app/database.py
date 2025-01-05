# app/database.py
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os
from dotenv import load_dotenv

# Load .env file
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), '.env'))

# Environment variables with defaults
DATABASE_USERNAME = os.getenv('DATABASE_USERNAME')
DATABASE_PASSWORD = os.getenv('DATABASE_PASSWORD')
DATABASE_HOSTNAME = os.getenv('DATABASE_HOSTNAME')
DATABASE_PORT = int(os.getenv('DATABASE_PORT', '5432'))
DATABASE_NAME = os.getenv('DATABASE_NAME')

# Construct database URL
SQLALCHEMY_DATABASE_URL = (
    f'postgresql://{DATABASE_USERNAME}:{DATABASE_PASSWORD}@'
    f'{DATABASE_HOSTNAME}:{DATABASE_PORT}/{DATABASE_NAME}'
)

engine = create_engine(SQLALCHEMY_DATABASE_URL)

# Create session factory
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Create base class
Base = declarative_base()

# Database Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()