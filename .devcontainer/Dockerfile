FROM python:3.13-slim-bookworm

# --- System libs required by cadquery-ocp (OCP) wheels ---
# OCP ships prebuilt OpenCascade binaries that dlopen these at runtime even
# in headless use (no X server needed, just the shared libs).
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1 \
    libglu1-mesa \
    libxrender1 \
    libxi6 \
    libxmu6 \
    libxext6 \
    libglib2.0-0 \
    libgomp1 \
    libfontconfig1 \
    git \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# --- uv for fast, reproducible installs ---
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

WORKDIR /workspace

# --- Python deps ---
# Pin versions once you land on known-good ones; loose for now.
RUN uv venv /opt/venv
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN uv pip install \
    build123d \
    ocp_vscode \
    numpy

# ocp_vscode's viewer server listens here; VS Code extension connects to it.
EXPOSE 3939

# Non-root user matching typical devcontainer conventions
RUN useradd -ms /bin/bash dev && chown -R dev:dev /workspace /opt/venv
USER dev

CMD ["sleep", "infinity"]