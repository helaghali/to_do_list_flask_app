FROM python:3.12-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Install build deps to compile wheels
RUN apt-get update \
  && apt-get install -y --no-install-recommends build-essential ca-certificates \
  && rm -rf /var/lib/apt/lists/*

COPY requirements.txt ./
# build wheels in the builder stage to avoid build deps in final image
RUN pip wheel --no-cache-dir --no-deps -w /wheels -r requirements.txt

### Final image
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Keep runtime deps minimal (ca-certificates). Do not carry build-essential.
RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# Create a non-root user for running the app
RUN useradd -m -d /home/flaskuser -s /bin/bash flaskuser \
  && mkdir -p /app/instance \
  && chown -R flaskuser:flaskuser /app

# Copy pre-built wheels from builder and install without hitting the network
COPY --from=builder /wheels /wheels
COPY requirements.txt ./
RUN pip install --no-cache-dir --no-index --find-links=/wheels -r requirements.txt

# Copy application code and set ownership
COPY --chown=flaskuser:flaskuser . .

USER flaskuser

EXPOSE 5000

# Basic healthcheck that performs an HTTP GET against /health
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD python -c "import sys, http.client; conn=http.client.HTTPConnection('127.0.0.1',5000,timeout=5); conn.request('GET','/health'); r=conn.getresponse(); sys.exit(0 if r.status==200 else 1)"

# Use gunicorn for production-like server
CMD ["gunicorn", "-w", "2", "-b", "0.0.0.0:5000", "run:app"]
