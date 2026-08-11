docker run -d --name redis-exporter -p 9121:9121 --env REDIS_ADDR=redis://172.17.0.1:6379 oliver006/redis_exporter:latest
