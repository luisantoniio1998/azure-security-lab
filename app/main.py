import os
import json
import time
import secrets
import logging

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
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("security")

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
        **fields
    }))


# HTTP Request Logging
@app.middleware("http")
async def security_logging(request: Request, call_next):
    start = time.perf_counter()

    try:
        response = await call_next(request)
    except Exception:
        security_event(
            "http_request_error",
            source_ip=request.client.host if request.client else None,
            method=request.method,
            path=request.url.path
        )
        raise

    security_event(
        "http_request",
        source_ip=request.client.host if request.client else None,
        method=request.method,
        path=request.url.path,
        status_code=response.status_code,
        duration_ms=round((time.perf_counter() - start) * 1000, 2)
    )

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
            reason="invalid_or_missing_key"
        )

        raise HTTPException(
            status_code=401,
            detail="Invalid API key"
        )

    security_event(
        "authentication_success",
        source_ip=request.client.host if request.client else None,
        method="api_key"
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
