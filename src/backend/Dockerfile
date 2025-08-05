# syntax=docker/dockerfile:1

FROM python:3.13.5-slim-bookworm

WORKDIR /code

# Copy only backend-related files
COPY api/ ./api/
COPY requirements.txt .
COPY logging_config.py .
COPY gunicorn.conf.py .
COPY files/ ./files/
COPY data/ ./data/

RUN pip install --no-cache-dir --upgrade -r requirements.txt

# Remove frontend build dependencies - not needed for backend
RUN apt-get update \
    && apt-get purge -y krb5-user libkrb5-3 libkrb5support0 libgssapi-krb5-2 \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 50505

CMD ["gunicorn", "api.main:create_app"]
