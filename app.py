import random, time
from fastapi import FastAPI, HTTPException
from prometheus_fastapi_instrumentator import Instrumentator

import logging
import json
from opentelemetry import trace

import redis
from redis.exceptions import RedisError
import psycopg2
from psycopg2 import OperationalError as PgOperationalError


class JSONFormatter(logging.Formatter):
    def format(self, record):
        span = trace.get_current_span()
        span_context = span.get_span_context()
        log_entry = {
            "timestamp": self.formatTime(record),
            "level": record.levelname,
            "message": record.getMessage(),
            "trace_id": format(span_context.trace_id, "032x") if span_context.trace_id else None,
        }
        return json.dumps(log_entry)


logger = logging.getLogger("monitoring-lab")
handler = logging.StreamHandler()
handler.setFormatter(JSONFormatter())
logger.addHandler(handler)
logger.setLevel(logging.INFO)

app = FastAPI()

# Redis client (connection-pooled, reused across requests)
redis_client = redis.Redis(
    host="redis", port=6379, socket_connect_timeout=2, socket_timeout=2
)


def get_pg_connection():
    # Intentionally opens a fresh connection per call (mirrors leak_pg_connections.py)
    # so that connection exhaustion caused by the leak script shows up here too.
    return psycopg2.connect(
        host="postgres",
        port=5432,
        dbname="labdb",
        user="postgres",
        password="labpassword",
        connect_timeout=2,
    )


@app.get("/fast")
def fast():
    logger.info("Fast endpoint triggered")
    return {"status": "ok"}


@app.get("/slow")
def slow():
    logger.info("Slow node encountered")
    time.sleep(random.uniform(0.1, 0.5))


@app.get("/flaky")
def flaky():
    if random.random() < 0.3:
        logger.error("flaky endpoint failed")
        raise HTTPException(status_code=500, detail="random failure")
    logger.info("flaky endpoint succeeded")
    return {"status": "ok"}


@app.get("/redis")
def redis_endpoint():
    try:
        redis_client.set("monitoring-lab:ping", "pong", ex=30)
        value = redis_client.get("monitoring-lab:ping")
        logger.info("Redis endpoint succeeded")
        return {"status": "ok", "value": value}
    except RedisError as e:
        logger.error(f"Redis endpoint failed: {e}")
        raise HTTPException(status_code=503, detail="redis unavailable")


@app.get("/postgres")
def postgres_endpoint():
    try:
        conn = get_pg_connection()
        cur = conn.cursor()
        cur.execute("SELECT 1")
        cur.fetchone()
        cur.close()
        conn.close()
        logger.info("Postgres endpoint succeeded")
        return {"status": "ok"}
    except PgOperationalError as e:
        logger.error(f"Postgres endpoint failed: {e}")
        raise HTTPException(status_code=503, detail="postgres unavailable")


Instrumentator().instrument(app).expose(app)