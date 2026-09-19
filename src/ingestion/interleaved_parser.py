from .entity_detector import entity_from_header, is_footer
from .record_parser import logical_records
def parse(lines: list[str], metadata: dict):
    i=0
    while i<len(lines):
        entity=entity_from_header(lines[i])
        if not entity: i+=1; continue
        header=lines[i+1].split("|"); i+=2; block=[]
        while i<len(lines) and not is_footer(lines[i]): block.append(lines[i]); i+=1
        expected=metadata[entity]["expected_columns"]
        for values,raw in logical_records(block, expected):
            yield entity, header, values, raw
        i+=1
