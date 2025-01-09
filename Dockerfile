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

# Copy requirements first (better caching)
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.actions.txt

# Copy the application code
COPY app/ ./app/

# Create directories for data storage
RUN mkdir -p data error_screenshots \
    && chmod 777 data error_screenshots

# Set up volume mount points
VOLUME ["/app/data", "/app/error_screenshots"]

# Run scraper with parameters
CMD ["python", "-m", "app.scrapers.scraper_main", "--source", "indeed", "--category", "data_engineer"]