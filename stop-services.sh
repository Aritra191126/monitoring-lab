#!/bin/bash
docker stop jaeger prometheus alertmanager grafana \
  redis redis-exporter \
  postgres postgres-exporter \
  loki promtail
echo "All services stopped."
echo "Reminder: also Ctrl+C your ./run.sh terminal and any leak scripts still running."