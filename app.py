import random, time 
from fastapi import FastAPI, HTTPException
from prometheus_fastapi_instrumentator import Instrumentator
app = FastAPI()

@app.get("/fast")
def fast():
    return {"status":"ok"}
@app.get("/slow")
def slow():
    time.sleep(random.uniform(0.1,0.5))
@app.get("/flaky")
def flaky():
    if random.random() < 0.3:
        raise HTTPException(status_code=500, detail="random_failure")    
    return {"status":"ok"} 

Instrumentator().instrument(app).expose(app)