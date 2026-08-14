docker run -d --name postgres-exporter \
  -p 9187:9187 \
  -e DATA_SOURCE_NAME="postgresql://postgres:labpassword@172.17.0.1:5432/labdb?sslmode=disable" \
  prometheuscommunity/postgres-exporter:latest