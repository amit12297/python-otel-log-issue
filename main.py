import logging
from typing import Union, Any

import uvicorn
from starlette.requests import Request
from starlette.responses import JSONResponse

from fastapi import FastAPI

logger = logging.getLogger("activity")


async def unhandled_exception_handler(request: Request, exc: Exception):
    logger.error("Log with 0 trace-id and span-id")
    return JSONResponse(content={"message": "Something went wrong"}, status_code=500)


app = FastAPI(exception_handlers={Exception: unhandled_exception_handler})


@app.get("/")
def read_root():
    logger.info("Log with valid trace-id and span-id")
    return {"Hello": "World"}


@app.get("/break")
def break_path():
    logger.info("Log with valid trace-id and span-id")
    1 / 0
    return {"Unreachable": "Code"}


if __name__ == "__main__":
    uvicorn.run(app=app, port=8080, host="127.0.0.1", reload=False)
