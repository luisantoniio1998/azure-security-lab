"""Convert local JSONL to LogScale structured ingestion JSON; no network calls."""
import argparse
import json
from pathlib import Path


def payload(lines):
    events = []
    for line in lines:
        if not line.strip():
            continue
        event = json.loads(line)
        if event.get("service") != "azure-security-lab" or not event.get("timestamp"):
            raise ValueError("Expected timestamped Azure Security Lab events")
        events.append({"timestamp": event["timestamp"], "attributes": event})
    if not events:
        raise ValueError("No security events found")
    return [{"tags": {"service": "azure-security-lab", "source": "fastapi"}, "events": events}]


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    result = payload(args.input.read_text().splitlines())
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, indent=2) + "\n")
    print(f"Prepared {len(result[0]['events'])} events; nothing transmitted")
