FROM python:3.9-alpine

# Set environment variables
ENV PYTHONUNBUFFERED=1

# Create a virtual environment
RUN python -m venv /py

# Upgrade pip
RUN /py/bin/pip install --upgrade pip

# Install PostgreSQL client
RUN apk add --update --no-cache postgresql-client

# Install temporary dependencies
RUN apk add --update --no-cache --virtual .tmp-build-deps \
    build-base postgresql-dev musl-dev

# Install project dependencies
COPY requirements.txt /tmp/requirements.txt
RUN /py/bin/pip install -r /tmp/requirements.txt

# Install development dependencies if in development mode
ARG DEV=false
COPY requirements.dev.txt /tmp/requirements.dev.txt
RUN if [ "$DEV" = "true" ]; then /py/bin/pip install -r /tmp/requirements.dev.txt; fi

# Cleanup
RUN rm -rf /tmp
RUN apk del .tmp-build-deps

# Add a user for running the application
RUN adduser \
    --disabled-password \
    --no-create-home \
    django-user

# Set the working directory
WORKDIR /app

# Copy the application code to the container
COPY . /app

# Set the PATH to use the virtual environment's Python
ENV PATH="/py/bin:$PATH"

# Set the user to run the application
USER django-user
