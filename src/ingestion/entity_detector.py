from __future__ import annotations

def entity_from_header(line: str) -> str | None:
    return line.split("|", 1)[1].strip().upper() if line.startswith("HDR|") and "|" in line else None
def is_footer(line: str) -> bool:
    return line.startswith("FTR|RECORDCOUNT|")
