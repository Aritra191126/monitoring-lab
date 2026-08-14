#!/bin/bash
set -e

echo "== Jaeger =="
docker start jaeger 2>/dev/null || docker run -d --name jaeger \
  -p 16686:16686 -p 4317:4317 \
  jaegertracing/all-in-one:1.53

echo "== Alertmanager =="
docker start alertmanager 2>/dev/null || docker run -d --name alertmanager \
  -p 9093:9093 \
  -v "$(pwd)/alertmanager.yml:/etc/alertmanager/alertmanager.yml" \
  prom/alertmanager:latest

echo "== Grafana =="
docker start grafana 2>/dev/null || docker run -d --name grafana \
  -p 3000:3000 \
  grafana/grafana:latest

echo "== Redis =="
docker start redis 2>/dev/null || docker run -d --name redis \
  -p 6379:6379 \
  redis:latest

echo "== Redis Exporter =="
docker start redis-exporter 2>/dev/null || docker run -d --name redis-exporter \
  -p 9121:9121 \
  --env REDIS_ADDR=redis://172.17.0.1:6379 \
  oliver006/redis_exporter:latest

echo "== Postgres =="
docker start postgres 2>/dev/null || docker run -d --name postgres \
  -e POSTGRES_PASSWORD=labpassword \
  -e POSTGRES_DB=labdb \
  -p 5432:5432 \
  postgres:latest

echo "== Postgres Exporter =="
docker start postgres-exporter 2>/dev/null || docker run -d --name postgres-exporter \
  -p 9187:9187 \
  -e DATA_SOURCE_NAME="postgresql://postgres:labpassword@172.17.0.1:5432/labdb?sslmode=disable" \
  prometheuscommunity/postgres-exporter:latest

echo "== Loki =="
docker start loki 2>/dev/null || docker run -d --name loki \
  -p 3100:3100 \
  grafana/loki:latest

echo "== Ensure app.log exists before Promtail mounts it =="
touch "$(pwd)/app.log"

echo "== Promtail =="
docker start promtail 2>/dev/null || docker run -d --name promtail \
  -v "$(pwd)/promtail-config.yml:/etc/promtail/config.yml" \
  -v "$(pwd)/app.log:/var/log/app/app.log" \
  grafana/promtail:latest \
  -config.file=/etc/promtail/config.yml

echo "== Prometheus (recreated fresh to pick up config changes) =="
docker rm -f prometheus 2>/dev/null || true
docker run -d --name prometheus -p 9090:9090 \
  -v "$(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml" \
  -v "$(pwd)/alert_rules.yml:/etc/prometheus/alert_rules.yml" \
  prom/prometheus:latest

echo ""
echo "All services started. Run ./run.sh in another terminal to start your app."
echo ""
docker ps