# migrations/add_status_column.py
from sqlalchemy import text
from app.database import engine

def add_status_column():
    with engine.connect() as connection:
        # Add the status column with a default value
        connection.execute(text("""
        ALTER TABLE processed_jobs 
        ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'new' NOT NULL;
        """))
        connection.commit()

if __name__ == "__main__":
    add_status_column()