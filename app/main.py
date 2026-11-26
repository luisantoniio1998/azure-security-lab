import os
import json
import time
import secrets
import logging
import uuid
import sys
from pathlib import Path
from contextvars import ContextVar

from datetime import datetime, timezone
from dotenv import load_dotenv
from fastapi import FastAPI, Request, Header, HTTPException, Depends
from fastapi.responses import FileResponse
from pydantic import BaseModel, Field

if __package__:
    from . import database
else:
    import database

# Environment
if os.getenv("APP_ENV", "development") != "production":
    load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), ".env"), override=False)

API_KEY = os.getenv("API_KEY", "")
if not API_KEY or API_KEY.startswith("@Microsoft.KeyVault("):
    raise RuntimeError("API_KEY must be supplied through the environment or a resolved Key Vault reference")

# Logging
logger = logging.getLogger("security")
logger.setLevel(logging.INFO)
logger.propagate = False
handler = logging.StreamHandler(sys.stdout)
handler.setFormatter(logging.Formatter("%(message)s"))
logger.handlers = [handler]
request_id = ContextVar("request_id", default=None)

# Application
app = FastAPI(
    title="Azure Security Lab API",
    description="Security Engineering Lab",
    version="1.0.0"
)

class NoteInput(BaseModel):
    text: str = Field(min_length=1, max_length=2000)


def security_event(event: str, **fields):
    logger.info(json.dumps({
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "event": event,
        "schema_version": "1.0",
        "service": "azure-security-lab",
        "environment": os.getenv("APP_ENV", "development"),
        "request_id": request_id.get(),
        **fields
    }))


# HTTP Request Logging
@app.middleware("http")
async def security_logging(request: Request, call_next):
    start = time.perf_counter()
    token = request_id.set(str(uuid.uuid4()))

    try:
        response = await call_next(request)
    except Exception:
        security_event(
            "http_request_error",
            source_ip=request.client.host if request.client else None,
            method=request.method,
            path=request.url.path if request.url.path in {"/health", "/secure"} else "<unmatched>"
        )
        request_id.reset(token)
        raise

    security_event(
        "http_request",
        source_ip=request.client.host if request.client else None,
        method=request.method,
        path=request.url.path if request.url.path in {"/health", "/secure"} else "<unmatched>",
        status_code=response.status_code,
        duration_ms=round((time.perf_counter() - start) * 1000, 2)
    )

    response.headers["X-Request-ID"] = request_id.get()
    request_id.reset(token)
    return response


# API Key Authentication
def verify_api_key(
    request: Request,
    x_api_key: str | None = Header(default=None)
):
    if not x_api_key or not secrets.compare_digest(x_api_key.encode("utf-8"), API_KEY.encode("utf-8")):
        security_event(
            "authentication_failure",
            source_ip=request.client.host if request.client else None,
            method="api_key",
            outcome="failure",
            reason="invalid_or_missing_key"
        )

        raise HTTPException(
            status_code=401,
            detail="Invalid API key"
        )

    security_event(
        "authentication_success",
        source_ip=request.client.host if request.client else None,
        method="api_key",
        outcome="success"
    )


# Public Endpoint
@app.get("/", include_in_schema=False)
def frontend():
    return FileResponse(Path(__file__).with_name("index.html"))


@app.get("/health")
def health():
    return {
        "status": "healthy",
        "service": "azure-security-lab",
        "timestamp": datetime.now(timezone.utc).isoformat()
    }


# Protected Endpoint
@app.get("/secure", dependencies=[Depends(verify_api_key)])
def secure_endpoint():
    return {
        "status": "authorized",
        "message": "Access granted"
    }


@app.get("/notes", dependencies=[Depends(verify_api_key)])
def list_notes():
    return database.list_notes()


@app.post("/notes", status_code=201, dependencies=[Depends(verify_api_key)])
def create_note(body: NoteInput):
    text = body.text.strip()
    if not text:
        raise HTTPException(status_code=422, detail="Write something first")
    note = database.create_note(text)
    security_event("note_created", note_id=str(note["id"]))
    return note


@app.delete("/notes/{note_id}", dependencies=[Depends(verify_api_key)])
def delete_note(note_id: uuid.UUID):
    if not database.delete_note(note_id):
        raise HTTPException(status_code=404, detail="Note not found")
    security_event("note_deleted", note_id=str(note_id))
    return {"status": "deleted"}
