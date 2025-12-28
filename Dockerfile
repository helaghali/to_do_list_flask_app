FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# system deps (kept minimal)
RUN apt-get update \
  && apt-get install -y --no-install-recommends build-essential ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# install python deps
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# copy app
COPY . .

# ensure instance folder exists
RUN mkdir -p /app/instance

# non-root user
RUN adduser --disabled-password --gecos "" flaskuser || true \
  && chown -R flaskuser:flaskuser /app
USER flaskuser

EXPOSE 5000

# Use gunicorn for production-like server
CMD ["gunicorn", "-w", "2", "-b", "0.0.0.0:5000", "run:app"]
