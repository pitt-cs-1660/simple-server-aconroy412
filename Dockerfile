# Build stage
FROM python:3.12 AS builder

# install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Change the working directory to the `app` directory
WORKDIR /app

COPY pyproject.toml ./

# Install dependencies
RUN uv sync --no-install-project --no-editable

# Copy the project into the intermediate image
COPY . /cc_simple_server ./

# Sync the project
RUN uv sync --no-editable
#----------------------------
# second stage
FROM python:3.12-slim

# copy from build
COPY --from=builder /app/.venv /app/.venv
ENV PATH="/app/.venv/bin:$PATH"


# copy source code
COPY --from=builder /app/cc_simple_server ./cc_simple_server
COPY --from=builder /app/tests ./tests


#create user
RUN useradd -m appuser
# RUN chown -R appuser:appuser /app
# USER appuser

#expose port
EXPOSE 8000

#run FASTAPI on container
CMD ["uvicorn", "cc_simple_server.server:app", "--reload", "--host", "0.0.0.0", "--port", "8000"]
