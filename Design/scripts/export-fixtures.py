"""Refresh the offline design fixture from the same sources as HornMusicCore."""
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parents[2]
model = root / "FrenchHornApp/Model"
excluded = {"TrebleClefNoteVisualizations.swift", "PitchColor.swift"}
sources = sorted(p for p in model.rglob("*.swift") if p.name not in excluded)
with tempfile.TemporaryDirectory(prefix="adagio-design-") as build:
    executable = Path(build) / "export"
    subprocess.run(["/usr/bin/swiftc", *map(str, sources),
                    str(Path(__file__).with_suffix(".swift")), "-o", str(executable)], check=True)
    result = subprocess.run([str(executable)], check=True, capture_output=True, text=True)
    (root / "Design/instrument-fixtures.js").write_text(result.stdout)
print("Updated Design/instrument-fixtures.js from 8 instrument configurations.")
