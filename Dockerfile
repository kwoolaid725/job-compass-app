FROM python:3.11-slim

# Install system dependencies
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

# Set environment variables
ENV CHROME_BIN=/usr/bin/chromium \
    CHROME_PATH=/usr/lib/chromium/ \
    CHROMEDRIVER_PATH=/usr/bin/chromedriver \
    PYTHONPATH=/app \
    PYTHONUNBUFFERED=1

# Set up working directory
WORKDIR /app

# Upgrade pip and install requirements
COPY requirements.actions.txt .
RUN python -m pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.actions.txt

# Install playwright and its dependencies
RUN playwright install chromium && \
    playwright install-deps chromium

# Create necessary directories
RUN mkdir -p app/logs data error_screenshots && \
    chmod -R 777 app/logs data error_screenshots

# Copy application code
COPY ./app ./app

# Create volume mount points
VOLUME ["/app/data", "/app/error_screenshots", "/app/logs"]

# Default command
CMD ["python", "-m", "app.scrapers.scraper_main", "--source", "indeed", "--category", "data_engineer"]