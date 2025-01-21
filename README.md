# Job Market Analytics Platform

A comprehensive data pipeline and analytics platform that automates job posting collection, processing, and visualization for the data/tech industry. Built with FastAPI, Airflow, Streamlit, and PostgreSQL.

## Overview
Job Compass is an ETL platform that helps job seekers track and analyze job postings. It automatically ingests job listings from multiple sources, processes the data, and provides interactive visualizations and analytics.

## System Architecture
```mermaid
flowchart TB
    subgraph DataSources ["Data Sources"]
        direction TB
        indeed["Indeed"]
        linkedin["LinkedIn"]
        builtIn["BuiltInChicago"]
    end
    subgraph Airflow ["Orchestration (Airflow)"]
        scheduler["Scheduler (9 AM/9 PM CT)"]
        scraper["Scraper DAG (Raw Data Collection)"]
        transformer["Process Raw Jobs DAG (Data Transformation)"]
        skills["Extract Skills DAG (Data Transformation)"]
    end
    subgraph Infrastructure ["Infrastructure"]
        direction TB
        flare["FlareSolverr (Anti-Bot Protection)"]
        db[(PostgreSQL Job Postings Database)]
    end
    subgraph API ["FastAPI Backend"]
        endpoints["REST API Endpoints"]
        models["SQLAlchemy Data Models"]
        schemas["Pydantic Data Schemas"]
    end
    subgraph Frontend ["Streamlit Dashboard"]
        postings["Job Postings and Status Management"]
        analytics["Job Analytics"]
        calendar["Job Status Calendar"]
        maps["Job Locations Map"]
    end
    
    indeed --> flare
    linkedin --> flare
    builtIn --> flare
    flare --> scraper
    scheduler --> scraper
    scraper --> db
    scraper --> transformer
    transformer --> skills
    transformer --> db
    skills --> db
    db --> endpoints
    endpoints --> postings
    endpoints --> analytics
    endpoints --> calendar
    endpoints --> maps
    
    classDef source fill:#e3f2fd,stroke:#1565c0,stroke-width:3px
    classDef infra fill:#ffebee,stroke:#d32f2f,stroke-width:3px
    classDef api fill:#e8f5e9,stroke:#388e3c,stroke-width:3px
    classDef frontend fill:#fff3e0,stroke:#f57c00,stroke-width:3px
    classDef airflow fill:#e1f5fe,stroke:#03a9f4,stroke-width:3px
    
    class indeed,linkedin,builtIn source
    class flare,db infra
    class scheduler airflow
    class scraper airflow
    class transformer airflow
    class skills airflow
    class endpoints,models,schemas api
    class postings,analytics,calendar,maps frontend
    
    %% Background colors for subgraphs
    style DataSources fill:#f0f4f8,stroke:#1565c0,stroke-width:1px
    style Airflow fill:#e0f7fa,stroke:#00bcd4,stroke-width:1px
    style Infrastructure fill:#fff3e0,stroke:#ef6c00,stroke-width:1px
    style API fill:#f3e5f5,stroke:#8e24aa,stroke-width:1px
    style Frontend fill:#e8eaf6,stroke:#3f51b5,stroke-width:1px
```

### 1. Data Collection Layer
- Scheduled Airflow DAGs for job scraping
- Source-specific scrapers with error handling
- Raw data storage in PostgreSQL

### 2. Processing Layer
- Duplicates detection while scraping to ensure no repeated job entries
- Job data normalization adn enrichment
- Skill extraction and categorization
- Salary standardization
- Location data processing

###  3.Analytics Layer
- REST API for data access
- Interactive dashboard
- Real-time filtering and analysis

## Technology Stack
-------------------------
### Backend
- FastAPI: REST API with async support
- PostgreSQL: Primary database
- SQLAlchemy: ORM for database operations
- Pydantic: Data validation and settings management

### Data Pipeline
- Apache Airflow: Workflow orchestration
- Docker: Containerization
- Playwright: Web scrapign with browser automation
- FlareSolverr: Anti-bot bypass solution

### Frontend
- Streamlit: Interactive dashboard
- Plotly: Data visualization
- Pandas: Data manipulation
- Leaflet: Geographic visualization 


