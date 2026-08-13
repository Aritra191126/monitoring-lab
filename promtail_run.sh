docker run -d --name promtail \
  -v $(pwd)/promtail-config.yml:/etc/promtail/config.yml \
  -v $(pwd)/app.log:/var/log/app/app.log \
  grafana/promtail:latest \
  -config.file=/etc/promtail/config.yml