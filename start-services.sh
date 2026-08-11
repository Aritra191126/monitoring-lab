#!/bin/bash

echo "Starting Jaeger..."
docker start jaeger 2>/dev/null || docker run -d --name jaeger \
  -p 16686:16686 -p 4317:4317 \
  jaegertracing/all-in-one:1.53

echo "Starting Alertmanager..."
docker start alertmanager 2>/dev/null || docker run -d --name alertmanager \
  -p 9093:9093 \
  -v $(pwd)/alertmanager.yml:/etc/alertmanager/alertmanager.yml \
  prom/alertmanager:latest

echo "Starting Prometheus..."
docker rm -f prometheus 2>/dev/null
docker run -d --name prometheus -p 9090:9090 \
  -v $(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml \
  -v $(pwd)/alert_rules.yml:/etc/prometheus/alert_rules.yml \
  prom/prometheus:latest

echo "Starting Grafana..."
docker start grafana 2>/dev/null || docker run -d --name grafana \
  -p 3000:3000 \
  grafana/grafana:latest

echo "All services started. Run ./run.sh in another terminal to start your app."
docker ps
