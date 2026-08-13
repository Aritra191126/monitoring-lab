import psycopg2
import time

conns = []
for i in range(20):
    conn = psycopg2.connect(
        host="172.17.0.1",
        port=5432,
        dbname="labdb",
        user="postgres",
        password="labpassword"
    )
    conns.append(conn)
    print(f"Opened connection {i+1}")
    time.sleep(0.2)

print("Holding 20 connections open. Press Ctrl+C to release.")
while True:
    time.sleep(10)