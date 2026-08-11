#!/bin/bash
docker stop jaeger prometheus alertmanager grafana redis redis-exporter
echo "All services stopped"