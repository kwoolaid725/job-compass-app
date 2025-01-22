FROM python:3.11-slim


RUN echo 'Acquire::Retries "3";' > /etc/apt/apt.conf.d/80-retries \
    && echo "deb http://mirror.csclub.uwaterloo.ca/debian/ bookworm main" > /etc/apt/sources.list \
    && echo "deb http://mirror.csclub.uwaterloo.ca/debian-security/ bookworm-security main" >> /etc/apt/sources.list \
    && echo "deb http://mirror.csclub.uwaterloo.ca/debian/ bookworm-updates main" >> /etc/apt/sources.list

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

ENV CHROME_BIN=/usr/bin/chromium \
    CHROME_PATH=/usr/lib/chromium/ \
    CHROMEDRIVER_PATH=/usr/bin/chromedriver \
    PYTHONPATH=/app \
    PYTHONUNBUFFERED=1

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

USER airflow
WORKDIR /home/airflow


COPY requirements.actions.txt /home/airflow/requirements.actions.txt

RUN python -m pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.actions.txt


RUN python -m pip install playwright && \
    python -m playwright install chromium && \
    python -m playwright install-deps chromium

USER root
WORKDIR /app
RUN mkdir -p /app/logs \
    && chown airflow:root /app/logs \
    && chmod 775 /app/logs

USER airflow
WORKDIR /app

COPY ./app ./app

VOLUME ["/app/logs", "/app/data", "/app/error_screenshots"]

CMD ["python", "-m", "app.scrapers.scraper_main", "--source", "indeed", "--category", "data_engineer"]