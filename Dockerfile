# FROM python:3.11-alpine as base

# FROM base as builder

# RUN apk update && apk --no-cache add python3-dev libpq-dev gst-libav && mkdir /install

# WORKDIR /install
# COPY requirements.txt ./
# RUN pip install --no-cache-dir --prefix=/install -r ./requirements.txt

# FROM base

# ARG USER=user
# ARG USER_UID=1001
# ARG PROJECT_NAME=website
# ARG GUNICORN_PORT=8000
# ARG GUNICORN_WORKERS=2
# # the value is in seconds
# ARG GUNICORN_TIMEOUT=60
# ARG GUNICORN_LOG_LEVEL=info
# ARG DJANGO_BASE_DIR=/usr/src/$PROJECT_NAME
# ARG DJANGO_STATIC_ROOT=/var/www/static
# ARG DJANGO_MEDIA_ROOT=/var/www/media
# ARG DJANGO_SQLITE_DIR=/sqlite
# # The superuser with the data below will be created only if there are no users in the database!
# ARG DJANGO_SUPERUSER_USERNAME=admin
# ARG DJANGO_SUPERUSER_PASSWORD=admin
# ARG DJANGO_SUPERUSER_EMAIL=admin@example.com
# ARG DJANGO_DEV_SERVER_PORT=8000

# ENV \
# 	USER=$USER \
# 	USER_UID=$USER_UID \
# 	PROJECT_NAME=$PROJECT_NAME \
# 	GUNICORN_PORT=$GUNICORN_PORT \
# 	GUNICORN_WORKERS=$GUNICORN_WORKERS \
# 	GUNICORN_TIMEOUT=$GUNICORN_TIMEOUT \
# 	GUNICORN_LOG_LEVEL=$GUNICORN_LOG_LEVEL \
# 	DJANGO_BASE_DIR=$DJANGO_BASE_DIR \
# 	DJANGO_STATIC_ROOT=$DJANGO_STATIC_ROOT \
# 	DJANGO_MEDIA_ROOT=$DJANGO_MEDIA_ROOT \
# 	DJANGO_SQLITE_DIR=$DJANGO_SQLITE_DIR \
# 	DJANGO_SUPERUSER_USERNAME=$DJANGO_SUPERUSER_USERNAME \
# 	DJANGO_SUPERUSER_PASSWORD=$DJANGO_SUPERUSER_PASSWORD \
# 	DJANGO_SUPERUSER_EMAIL=$DJANGO_SUPERUSER_EMAIL \
# 	DJANGO_DEV_SERVER_PORT=$DJANGO_DEV_SERVER_PORT


# COPY --from=builder /install /usr/local
# COPY docker-entrypoint.sh /
# COPY docker-cmd.sh /
# COPY $PROJECT_NAME $DJANGO_BASE_DIR

# # User
# RUN chmod +x /docker-entrypoint.sh /docker-cmd.sh && \
#     apk --no-cache add su-exec libpq-dev && \
#     mkdir -p $DJANGO_STATIC_ROOT $DJANGO_MEDIA_ROOT $DJANGO_SQLITE_DIR && \
#     adduser -s /bin/sh -D -u $USER_UID $USER && \
#     chown -R $USER:$USER $DJANGO_BASE_DIR $DJANGO_STATIC_ROOT $DJANGO_MEDIA_ROOT $DJANGO_SQLITE_DIR

# WORKDIR $DJANGO_BASE_DIR
# ENTRYPOINT ["/docker-entrypoint.sh"]
# CMD ["/docker-cmd.sh"]

# EXPOSE $GUNICORN_PORT






# # Use an official Python image based on Ubuntu as the base
# FROM python:3.11 as base

# FROM base as builder

# # Update package lists and install dependencies
# # Note: The packages might have different names in Ubuntu. Adjust as necessary.
# RUN apt-get update && \
#     apt-get install -y --no-install-recommends python3-dev libpq-dev gstreamer1.0-libav && \
#     mkdir /install

# WORKDIR /install
# COPY requirements.txt ./
# RUN pip install --no-cache-dir --prefix=/install -r ./requirements.txt

# FROM base

# ARG USER=user
# ARG USER_UID=1001
# ARG PROJECT_NAME=website
# ARG GUNICORN_PORT=8000
# ARG GUNICORN_WORKERS=2
# # the value is in seconds
# ARG GUNICORN_TIMEOUT=60
# ARG GUNICORN_LOG_LEVEL=info
# ARG DJANGO_BASE_DIR=/usr/src/$PROJECT_NAME
# ARG DJANGO_STATIC_ROOT=/var/www/static
# ARG DJANGO_MEDIA_ROOT=/var/www/media
# ARG DJANGO_SQLITE_DIR=/sqlite
# # The superuser with the data below will be created only if there are no users in the database!
# ARG DJANGO_SUPERUSER_USERNAME=admin
# ARG DJANGO_SUPERUSER_PASSWORD=admin
# ARG DJANGO_SUPERUSER_EMAIL=admin@example.com
# ARG DJANGO_DEV_SERVER_PORT=8000

# ENV \
# 	USER=$USER \
# 	USER_UID=$USER_UID \
# 	PROJECT_NAME=$PROJECT_NAME \
# 	GUNICORN_PORT=$GUNICORN_PORT \
# 	GUNICORN_WORKERS=$GUNICORN_WORKERS \
# 	GUNICORN_TIMEOUT=$GUNICORN_TIMEOUT \
# 	GUNICORN_LOG_LEVEL=$GUNICORN_LOG_LEVEL \
# 	DJANGO_BASE_DIR=$DJANGO_BASE_DIR \
# 	DJANGO_STATIC_ROOT=$DJANGO_STATIC_ROOT \
# 	DJANGO_MEDIA_ROOT=$DJANGO_MEDIA_ROOT \
# 	DJANGO_SQLITE_DIR=$DJANGO_SQLITE_DIR \
# 	DJANGO_SUPERUSER_USERNAME=$DJANGO_SUPERUSER_USERNAME \
# 	DJANGO_SUPERUSER_PASSWORD=$DJANGO_SUPERUSER_PASSWORD \
# 	DJANGO_SUPERUSER_EMAIL=$DJANGO_SUPERUSER_EMAIL \
# 	DJANGO_DEV_SERVER_PORT=$DJANGO_DEV_SERVER_PORT

# COPY --from=builder /install /usr/local
# COPY docker-entrypoint.sh /
# COPY docker-cmd.sh /
# COPY $PROJECT_NAME $DJANGO_BASE_DIR

# # Setup and user configuration for Ubuntu
# RUN chmod +x /docker-entrypoint.sh /docker-cmd.sh && \
#     apt-get install -y --no-install-recommends libpq-dev && \
#     mkdir -p $DJANGO_STATIC_ROOT $DJANGO_MEDIA_ROOT $DJANGO_SQLITE_DIR && \
#     adduser --disabled-password --gecos '' --uid $USER_UID $USER && \
#     chown -R $USER:$USER $DJANGO_BASE_DIR $DJANGO_STATIC_ROOT $DJANGO_MEDIA_ROOT $DJANGO_SQLITE_DIR

# WORKDIR $DJANGO_BASE_DIR
# ENTRYPOINT ["/docker-entrypoint.sh"]
# CMD ["/docker-cmd.sh"]

# EXPOSE $GUNICORN_PORT





# Use an official Python runtime as a parent image
FROM python:3.11 as base

# Builder stage to install dependencies
FROM base as builder

# Update package lists
RUN apt-get update && \
    apt-get install -y --no-install-recommends python3-dev libpq-dev gstreamer1.0-libav && \
    mkdir /install

WORKDIR /install
COPY requirements.txt ./
# Install Python dependencies
RUN pip install --no-cache-dir --prefix=/install -r ./requirements.txt

# Final stage to set up the application
FROM base

# Environment variables
ARG USER=user
ARG USER_UID=1001
ARG PROJECT_NAME=website
ARG GUNICORN_PORT=8000
ARG GUNICORN_WORKERS=2
ARG GUNICORN_TIMEOUT=60
ARG GUNICORN_LOG_LEVEL=info
ARG DJANGO_BASE_DIR=/usr/src/$PROJECT_NAME
ARG DJANGO_STATIC_ROOT=/var/www/static
ARG DJANGO_MEDIA_ROOT=/var/www/media
ARG DJANGO_SQLITE_DIR=/sqlite
ARG DJANGO_SUPERUSER_USERNAME=admin
ARG DJANGO_SUPERUSER_PASSWORD=admin
ARG DJANGO_SUPERUSER_EMAIL=admin@example.com
ARG DJANGO_DEV_SERVER_PORT=8000

ENV \
    USER=$USER \
    USER_UID=$USER_UID \
    PROJECT_NAME=$PROJECT_NAME \
    GUNICORN_PORT=$GUNICORN_PORT \
    GUNICORN_WORKERS=$GUNICORN_WORKERS \
    GUNICORN_TIMEOUT=$GUNICORN_TIMEOUT \
    GUNICORN_LOG_LEVEL=$GUNICORN_LOG_LEVEL \
    DJANGO_BASE_DIR=$DJANGO_BASE_DIR \
    DJANGO_STATIC_ROOT=$DJANGO_STATIC_ROOT \
    DJANGO_MEDIA_ROOT=$DJANGO_MEDIA_ROOT \
    DJANGO_SQLITE_DIR=$DJANGO_SQLITE_DIR \
    DJANGO_SUPERUSER_USERNAME=$DJANGO_SUPERUSER_USERNAME \
    DJANGO_SUPERUSER_PASSWORD=$DJANGO_SUPERUSER_PASSWORD \
    DJANGO_SUPERUSER_EMAIL=$DJANGO_SUPERUSER_EMAIL \
    DJANGO_DEV_SERVER_PORT=$DJANGO_DEV_SERVER_PORT

# Copy installed dependencies
COPY --from=builder /install /usr/local
COPY docker-entrypoint.sh /
COPY docker-cmd.sh /
COPY $PROJECT_NAME $DJANGO_BASE_DIR

# Install Gosu, setup directories, and configure permissions
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gosu \
        libpq-dev \
        gstreamer1.0-libav \
        libsoup2.4-1 \
        libgtk-3-0 \
        libgdk-pixbuf2.0-0 \
        libwoff1 \
        libharfbuzz-icu0 \
        gstreamer1.0-plugins-bad \
        libenchant-2-2 \
        libsecret-1-0 \
        libhyphen0 \
        libmanette-0.2-0 \
        libgbm1 \
        libxkbcommon0 \
        libgles2 \
        libgstreamer-gl1.0-0 \
        libgstreamer-plugins-base1.0-0 \
        xvfb && \
    rm -rf /var/lib/apt/lists/* && \
    chmod +x /docker-entrypoint.sh /docker-cmd.sh && \
    mkdir -p $DJANGO_STATIC_ROOT $DJANGO_MEDIA_ROOT $DJANGO_SQLITE_DIR && \
    adduser --disabled-password --gecos '' --uid $USER_UID $USER && \
    chown -R $USER:$USER $DJANGO_BASE_DIR $DJANGO_STATIC_ROOT $DJANGO_MEDIA_ROOT $DJANGO_SQLITE_DIR

RUN playwright install

WORKDIR $DJANGO_BASE_DIR
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/docker-cmd.sh"]

EXPOSE $GUNICORN_PORT
