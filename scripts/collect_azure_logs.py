import json
import sys
import argparse
import hashlib
import os
import sqlite3
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description="Extract app events and suppress replayed log lines.")
    parser.add_argument("--state-file", type=Path)
    args = parser.parse_args()
    os.umask(0o077)
    if args.state_file:
        args.state_file.parent.mkdir(parents=True, exist_ok=True)
    with sqlite3.connect(str(args.state_file) if args.state_file else ":memory:") as seen:
        seen.execute("CREATE TABLE IF NOT EXISTS events (id INTEGER PRIMARY KEY, hash TEXT UNIQUE)")
        for line in sys.stdin:
            start = line.find("{")
            if start < 0:
                continue
            try:
                event = json.loads(line[start:])
            except json.JSONDecodeError:
                continue
            if not isinstance(event, dict) or event.get("service") != "azure-security-lab":
                continue
            fingerprint = hashlib.sha256(json.dumps(event, sort_keys=True).encode()).hexdigest()
            if seen.execute("SELECT 1 FROM events WHERE hash = ?", (fingerprint,)).fetchone():
                continue
            print(json.dumps(event), flush=True)
            seen.execute("INSERT INTO events (hash) VALUES (?)", (fingerprint,))
            seen.execute("DELETE FROM events WHERE id <= (SELECT MAX(id) - 10000 FROM events)")
            seen.commit()


if __name__ == "__main__":
    try:
        main()
    except (KeyboardInterrupt, BrokenPipeError):
        pass
