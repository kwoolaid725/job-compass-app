# Job Market Analytics Platform

A comprehensive data pipeline and analytics platform that automates job posting collection, processing, and visualization for the data/tech industry. Built with FastAPI, Airflow, Streamlit, and PostgreSQL.

## Overview
Job Compass is an ETL platform that helps job seekers track and analyze job postings. It automatically ingests job listings from multiple sources, processes the data, and provides interactive visualizations and analytics.

<img width="1497" alt="image" src="https://github.com/user-attachments/assets/f6379b9d-ab9a-4fec-9e9a-60e179929c23" />
<img width="1493" alt="Screenshot 2025-03-28 at 1 04 15 PM" src="https://github.com/user-attachments/assets/9baf3610-03aa-446e-ab6b-1e5707e8b4f8" />
<img width="1468" alt="Screenshot 2025-03-28 at 1 05 19 PM" src="https://github.com/user-attachments/assets/c0ee9cd0-b289-41a7-974c-de60283b2dcd" />



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

    classDef source fill:#e3f2fd,stroke:#1565c0,stroke-width:3px,color:#003049
    classDef infra fill:#ffebee,stroke:#d32f2f,stroke-width:3px,color:#003049
    classDef api fill:#e8f5e9,stroke:#388e3c,stroke-width:3px,color:#003049
    classDef frontend fill:#fff3e0,stroke:#f57c00,stroke-width:3px,color:#003049
    classDef airflow fill:#e1f5fe,stroke:#03a9f4,stroke-width:3px,color:#003049
    
    class indeed,linkedin,builtIn source
    class flare,db infra
    class scheduler airflow
    class scraper airflow
    class transformer airflow
    class skills airflow
    class endpoints,models,schemas api
    class postings,analytics,calendar,maps frontend
    
    %% Background colors for subgraphs

    style DataSources fill:#f0f4f8,stroke:#1565c0,stroke-width:1px,color:#000000
    style Airflow fill:#e0f7fa,stroke:#00bcd4,stroke-width:1px,color:#000000
    style Infrastructure fill:#fff3e0,stroke:#ef6c00,stroke-width:1px,color:#000000
    style API fill:#f3e5f5,stroke:#8e24aa,stroke-width:1px,color:#000000
    style Frontend fill:#e8eaf6,stroke:#3f51b5,stroke-width:1px,color:#000000
    %% Set default link color
    linkStyle default stroke:#778da9,stroke-width:2px
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



