FROM python:3.11-slim

# ------------------------------------------------------------------------------
# 1) Use a more reliable APT mirror and add retry logic
# ------------------------------------------------------------------------------
RUN echo 'Acquire::Retries "3";' > /etc/apt/apt.conf.d/80-retries \
    && echo "deb http://mirror.csclub.uwaterloo.ca/debian/ bookworm main" > /etc/apt/sources.list \
    && echo "deb http://mirror.csclub.uwaterloo.ca/debian-security/ bookworm-security main" >> /etc/apt/sources.list \
    && echo "deb http://mirror.csclub.uwaterloo.ca/debian/ bookworm-updates main" >> /etc/apt/sources.list

# ------------------------------------------------------------------------------
# 2) Install system dependencies (as root)
# ------------------------------------------------------------------------------
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
    iputils-ping \
    dnsutils \
    net-tools \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------------------
# 3) Set up environment variables for Chromium & Python
# ------------------------------------------------------------------------------
ENV CHROME_BIN=/usr/bin/chromium \
    CHROME_PATH=/usr/lib/chromium/ \
    CHROMEDRIVER_PATH=/usr/bin/chromedriver \
    PYTHONPATH=/app \
    PYTHONUNBUFFERED=1

# ------------------------------------------------------------------------------
# 4) Create airflow user & groups while still root
# ------------------------------------------------------------------------------
ARG UID=1000
ARG GID=1000
ARG DOCKER_GROUP_ID=999

RUN if ! getent group docker > /dev/null 2>&1; then \
        groupadd -g ${DOCKER_GROUP_ID} docker || true; \
    fi && \
    if ! getent group ${GID} > /dev/null 2>&1; then \
        groupadd -g ${GID} airflowgroup; \
    fi && \
    useradd -m -u ${UID} -g ${GID} -s /bin/bash airflow || true && \
    usermod -aG docker airflow || true && \
    usermod -aG sudo airflow && \
    echo "airflow ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ------------------------------------------------------------------------------
# 5) Switch to airflow user BEFORE installing Python deps & Playwright
#    This ensures the browsers go into /home/airflow/.cache
# ------------------------------------------------------------------------------
USER airflow
WORKDIR /home/airflow

# Copy in your requirements file to the airflow home (or keep in /app)
COPY requirements.actions.txt /home/airflow/requirements.actions.txt

RUN python -m pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.actions.txt

# Install Playwright and the Chromium browser as airflow user
RUN python -m pip install playwright && \
    python -m playwright install chromium && \
    python -m playwright install-deps chromium

# ------------------------------------------------------------------------------
# 6) Switch briefly back to root to fix /app/logs permissions (if needed)
# ------------------------------------------------------------------------------
USER root
WORKDIR /app
RUN mkdir -p /app/logs \
    && chown airflow:root /app/logs \
    && chmod 775 /app/logs

# ------------------------------------------------------------------------------
# 7) Switch back to airflow user for final runtime
# ------------------------------------------------------------------------------
USER airflow
WORKDIR /app

# ------------------------------------------------------------------------------
# 8) Copy your application code
# ------------------------------------------------------------------------------
COPY ./app ./app

# ------------------------------------------------------------------------------
# 9) Create volume mount points with proper permissions
# ------------------------------------------------------------------------------
VOLUME ["/app/logs", "/app/data", "/app/error_screenshots"]

# ------------------------------------------------------------------------------
# 10) Default command
# ------------------------------------------------------------------------------
CMD ["python", "-m", "app.scrapers.scraper_main", "--source", "indeed", "--category", "data_engineer"]