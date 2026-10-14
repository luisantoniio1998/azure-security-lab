"""Build an allowlisted ZIP locally; this never deploys anything."""
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED

root = Path(__file__).resolve().parents[1]
target = root / "dist" / "app.zip"
target.parent.mkdir(exist_ok=True)
with ZipFile(target, "w", ZIP_DEFLATED) as archive:
    for name in ("main.py", "requirements.txt"):
        archive.write(root / "app" / name, name)
print(target)
