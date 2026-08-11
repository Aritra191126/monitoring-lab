import redis
import time 
clients = []
for i in range(50):
    r = redis.Redis(host='172.17.0.1', port=6379)
    r.ping()
    clients.append(r)
    print(f"Opened connection {i+1}")
    time.sleep(0.1)
print("Holding 50 connections open. Press Ctrl+C to release")
while True:
    time.sleep(10)    