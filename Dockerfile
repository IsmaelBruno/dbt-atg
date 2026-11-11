
FROM python:3.11-slim

WORKDIR /usr/app

# Installer Git
RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    rm -rf /var/lib/apt/lists/*

# Installer dbt et son adaptateur PostgreSQL
RUN pip install --no-cache-dir \
    "dbt-core==1.12.6" \
    "dbt-postgres==1.11.0"

COPY . .

CMD ["tail", "-f", "/dev/null"]
