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
    && rm -rf /var/lib/apt/lists/*

# Set environment variables for Chrome
ENV CHROME_BIN=/usr/bin/chromium
ENV CHROME_PATH=/usr/lib/chromium/
ENV CHROMEDRIVER_PATH=/usr/bin/chromedriver
ENV PYTHONPATH=/app

# Set up working directory
WORKDIR /app

# Upgrade pip first
RUN python -m pip install --upgrade pip

# Copy and install requirements with verbose output
COPY requirements.actions.txt .
RUN pip install --no-cache-dir -v -r requirements.actions.txt || \
    (echo "Failed to install requirements. Contents of requirements.actions.txt:" && \
     cat requirements.actions.txt && \
     exit 1)

# Copy the application code
COPY app/ ./app/

# Create directories for data storage
RUN mkdir -p data error_screenshots \
    && chmod 777 data error_screenshots

# Set up volume mount points
VOLUME ["/app/data", "/app/error_screenshots"]

# Run scraper with parameters
CMD ["python", "-m", "app.scrapers.scraper_main", "--source", "indeed", "--category", "data_engineer"]