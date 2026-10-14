import asyncio
import importlib.util
import io
import json
import os
from pathlib import Path
import unittest
import zipfile
import subprocess
import sys

os.environ["APP_ENV"] = "production"
os.environ["API_KEY"] = "local-test-key-only"
from app import main

spec = importlib.util.spec_from_file_location("converter", "scripts/logscale_payload.py")
converter = importlib.util.module_from_spec(spec)
spec.loader.exec_module(converter)


async def request(path, key=None):
    messages = []
    sent = False
    async def receive():
        nonlocal sent
        if not sent:
            sent = True
            return {"type": "http.request", "body": b"", "more_body": False}
        await asyncio.sleep(3600)
    async def send(message):
        messages.append(message)
    headers = [(b"x-api-key", key.encode())] if key else []
    await main.app({"type": "http", "asgi": {"version": "3.0"}, "http_version": "1.1",
                    "scheme": "http", "method": "GET", "path": path, "raw_path": path.encode(),
                    "query_string": b"password=never-log-this", "headers": headers,
                    "client": ("127.0.0.1", 1234), "server": ("localhost", 8000)}, receive, send)
    return next(m for m in messages if m["type"] == "http.response.start")


class SecurityTests(unittest.TestCase):
    def test_auth_logging_and_ingest_payload(self):
        output = io.StringIO()
        main.handler.setStream(output)
        try:
            for key, status in [(None, 401), ("wrong", 401), ("é", 401), (os.environ["API_KEY"], 200)]:
                response = asyncio.run(request("/secure", key))
                self.assertEqual(response["status"], status)
                self.assertIn(b"x-request-id", dict(response["headers"]))
            self.assertEqual(asyncio.run(request("/health"))["status"], 200)
            self.assertEqual(asyncio.run(request("/secret-looking-path"))["status"], 404)
        finally:
            main.handler.setStream(__import__("sys").stdout)
        lines = output.getvalue().splitlines()
        events = [json.loads(line) for line in lines]
        self.assertEqual(sum(e["event"] == "authentication_failure" for e in events), 3)
        self.assertEqual(sum(e["event"] == "authentication_success" for e in events), 1)
        self.assertEqual(events[0]["request_id"], events[1]["request_id"])
        self.assertNotIn(os.environ["API_KEY"], output.getvalue())
        self.assertNotIn("never-log-this", output.getvalue())
        self.assertNotIn("secret-looking-path", output.getvalue())
        self.assertEqual(len(converter.payload(lines)[0]["events"]), len(events))
        self.assertIsNone(main.request_id.get())

    def test_archive_allowlist(self):
        subprocess.run([sys.executable, "scripts/package_app.py"], check=True, capture_output=True)
        with zipfile.ZipFile("dist/app.zip") as archive:
            self.assertEqual(set(archive.namelist()), {"main.py", "requirements.txt"})

    def test_invalid_event_rejected(self):
        with self.assertRaises(ValueError):
            converter.payload(['{"timestamp":"now","service":"other"}'])
