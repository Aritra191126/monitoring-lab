FROM python:3.11-slim
WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN opentelemetry-bootstrap -a install 

COPY app.py .
EXPOSE 8000

CMD [ "opentelemetry-instrument", \
      "--service_name", "monitoring-lab", \
      "--traces_exporter", "otlp", \
      "--exporter_otlp_endpoint", "http://jaeger:4317", \
      "--metrics_exporter", "console", \
      "uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]