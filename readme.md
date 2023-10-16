To run the application using docker execute the following:
```commandline
docker build --no-cache -t myimage .
docker run -d --name mycontainer -p 8080:8080 myimage
```
To run the application using poetry:
```commandline
poetry shell
poetry install
opentelemetry-bootstrap --action=install
export OTEL_METRICS_EXPORTER=none
export OTEL_TRACES_EXPORTER=none
export OTEL_PYTHON_LOG_CORRELATION=true
export OTEL_SERVICE_NAME=log-issue-repro
opentelemetry-instrument uvicorn main:app --host 127.0.0.1 --port 8080
```

Once application is running, execute:
```commandline
curl http://www.localhost:8080/break
```

Observe the logs:
```commandline
2023-10-17 00:45:22,334 INFO [activity] [main.py:29] [trace_id=8799f34465cd9905efcee0dce40633b4 span_id=32efef8c434b3a07 resource.service.name=log-issue-repro trace_sampled=True] - Log with valid trace-id and span-id
2023-10-17 00:45:22,339 ERROR [activity] [main.py:14] [trace_id=0 span_id=0 resource.service.name=log-issue-repro trace_sampled=False] - Log with 0 trace-id and span-id
```

First log line has proper trace-id and span-id
Second log line from exception handler has trace-id and span-id as 0