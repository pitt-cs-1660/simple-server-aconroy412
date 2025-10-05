# Build stage
FROM python:3.12 AS builder

# install package
RUN python -m pip install --upgrade pip && python -m pip install uv

WORKDIR /app

# copy dependencies
COPY pyproject.toml .

#install dependencies
RUN uv venv
RUN uv pip install --requirements pyproject.toml --python /app/.venv

#----------------------------
# second stage
FROM python:3.12-slim

WORKDIR /app

# copy from build
COPY --from=builder /app/.venv /app/.venv
ENV PATH="/app/.venv/bin:$PATH"


# copy source code
COPY . .

#create user
RUN useradd -m appuser
RUN chown -R appuser:appuser /app
USER appuser

#expose port
EXPOSE 8000

#run FASTAPI on container
CMD ["uvicorn", "cc_simple_server.server:app", "--reload", "--host", "0.0.0.0", "--port", "8000"]
