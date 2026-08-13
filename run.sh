#!/bin/bash
opentelemetry-instrument \
  --service_name monitoring-lab \
  --traces_exporter otlp \
  --exporter_otlp_endpoint http://localhost:4317 \
  --metrics_exporter console \
  uvicorn app:app --reload --host 0.0.0.0 2>&1 | tee app.log