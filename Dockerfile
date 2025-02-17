# Use the official Python image from the Docker Hub
FROM python:3.11-bookworm AS base

RUN addgroup --gid 1000 ubuntu
RUN adduser --disabled-password --gecos '' --uid 1000 --gid 1000 ubuntu

ARG USER=ubuntu

RUN DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        git \
        libssl-dev \
        zlib1g-dev \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        wget \
        curl \
        llvm \
        libncurses5-dev \
        xz-utils \
        tk-dev \
        libxml2-dev \
        libxmlsec1-dev \
        libffi-dev \
        liblzma-dev \
        libpq-dev

# Python and poetry installation
USER $USER
ARG HOME="/home/$USER"

ENV PATH="${HOME}/.local/bin:$PATH"

ENV POETRY_VERSION=1.5.1
RUN curl -sSL https://install.python-poetry.org | python3 - \
    && poetry config virtualenvs.in-project true

# Set the working directory in the container
WORKDIR /app

# Copy the pyproject.toml and poetry.lock files to the container
COPY pyproject.toml poetry.lock ./
COPY --chown=1000:1000 ./pyproject.toml .
COPY --chown=1000:1000 ./poetry.lock .
COPY --chown=1000:1000 ./dask.yaml ~/.config/dask/dask.yaml

# Install dependencies
RUN poetry install --no-root

# ----------------------------------------------------
# PRODUCTION
FROM python:3.11-slim-bookworm AS production

RUN DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y libpq-dev libexpat1 \
    tini

RUN addgroup --gid 1000 ubuntu
RUN adduser --disabled-password --gecos '' --uid 1000 --gid 1000 ubuntu

USER 1000    

# Set the working directory in the container
WORKDIR /app

# Copy over the venv and the code
COPY --from=base --chown=1000:1000 /app/.venv ./.venv

# Update the symlinks to the python interpreter in the venv to the new location
RUN ln -sf /usr/local/bin/python /app/.venv/bin/python \
    && ln -sf /usr/local/bin/python3 /app/.venv/bin/python3

ENV VIRTUAL_ENV=/app/.venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

ENTRYPOINT ["tini", "-g", "--"]