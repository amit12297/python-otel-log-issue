FROM python:3.10.12 as base

ENV ENVIRONMENT=prod \
    TESTING=0 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_NO_INTERACTION=1 \
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv" \
    DIRPATH="/otel-issue-example"

ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

FROM base as builder

ENV POETRY_VERSION="1.3.2"
RUN pip install poetry=="$POETRY_VERSION"

WORKDIR $PYSETUP_PATH
COPY ./pyproject.toml ./
RUN poetry install --no-root --no-ansi --no-interaction

RUN opentelemetry-bootstrap --action=install

FROM base as final

WORKDIR $DIRPATH

COPY --from=builder $VENV_PATH $VENV_PATH
COPY main.py .

EXPOSE 8080

ENV OTEL_METRICS_EXPORTER=none \
    OTEL_TRACES_EXPORTER=none \
    OTEL_PYTHON_LOG_CORRELATION=true \
    OTEL_SERVICE_NAME=log-issue-repro

CMD opentelemetry-instrument uvicorn main:app --host 0.0.0.0 --port 8080
