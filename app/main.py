import os
import json
import time
import secrets
import logging
import uuid
import sys
from contextvars import ContextVar

from datetime import datetime, timezone
from dotenv import load_dotenv
from fastapi import FastAPI, Request, Header, HTTPException, Depends

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
