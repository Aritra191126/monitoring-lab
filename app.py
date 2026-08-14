import random, time 
from fastapi import FastAPI, HTTPException
from prometheus_fastapi_instrumentator import Instrumentator

import logging
import json
from opentelemetry import trace

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

@app.get("/fast")
def fast():
    logger.info("Fast endpoint triggered")
    return {"status":"ok"}

@app.get("/slow")
def slow():
    logger.info("Slow node encountered")
    time.sleep(random.uniform(0.1,0.5))

@app.get("/flaky")
def flaky():
    if random.random() < 0.3:
        logger.error("flaky endpoint failed")
        raise HTTPException(status_code=500, detail="random failure")
    logger.info("flaky endpoint succeeded")
    return {"status": "ok"}

Instrumentator().instrument(app).expose(app)