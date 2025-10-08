FROM python:3.11-alpine

# Install common shell tools
RUN apk add --no-cache \
    bash \
    git \
    curl \
    wget \
    sed \
    grep \
    findutils \
    github-cli

# Create non-root user
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

WORKDIR /app

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy server code
COPY server.py .

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

USER appuser

EXPOSE 3000

CMD ["python", "server.py"]
