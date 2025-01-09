FROM python:3.11-slim

# Install system dependencies including Chrome and its dependencies
RUN apt-get update && apt-get install -y \
    chromium \
    chromium-driver \
    libnss3 \
    libgconf-2-4 \
    libfontconfig1 \
    wget \
    curl \
    gcc \
    python3-dev \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables for Chrome
ENV CHROME_BIN=/usr/bin/chromium \
    CHROME_PATH=/usr/lib/chromium/ \
    CHROMEDRIVER_PATH=/usr/bin/chromedriver \
    PYTHONPATH=/app \
    PYTHONUNBUFFERED=1

# Set up working directory
WORKDIR /app

# Upgrade pip first
RUN python -m pip install --upgrade pip

# Copy and install requirements with verbose output
COPY requirements.actions.txt .
RUN python -m pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.actions.txt

RUN playwright install chromium && \
    playwright install-deps \

# Copy the application code
COPY app/ ./app/

# Create directories for data storage
RUN mkdir -p data error_screenshots \
    && chmod 777 data error_screenshots

# Create volume mount points
VOLUME ["/app/data", "/app/error_screenshots", "/app/logs"]

# Run scraper with parameters
CMD ["python", "-m", "app.scrapers.scraper_main", "--source", "indeed", "--category", "data_engineer"]