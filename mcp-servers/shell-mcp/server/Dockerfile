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

WORKDIR /app

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy server code
COPY server.py .

EXPOSE 3000

CMD ["python", "server.py"]
