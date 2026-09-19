def logical_records(lines: list[str], expected_columns: int):
    buffer=[]
    for line in lines:
        buffer.append(line.strip())
        raw=" ".join(buffer)
        if raw.count("|") == expected_columns-1:
            yield raw.split("|"), raw
            buffer=[]
        elif raw.count("|") > expected_columns-1:
            yield None, raw
            buffer=[]
    if buffer: yield None, " ".join(buffer)
