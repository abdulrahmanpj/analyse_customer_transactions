import json
from datetime import datetime,timezone
from pathlib import Path
import apache_beam as beam
from apache_beam.io.filesystems import FileSystems
from apache_beam.io.gcp.bigquery import WriteToBigQuery
from apache_beam.options.pipeline_options import PipelineOptions,SetupOptions
import yaml
from src.ingestion.interleaved_parser import parse

SCHEMA="entity_name:STRING,batch_id:STRING,source_file:STRING,record_number:INTEGER,raw_record:STRING,payload:JSON,ingested_at:TIMESTAMP"
class Options(PipelineOptions):
 @classmethod
 def _add_argparse_args(cls,p):
  for name in ("input_uri","batch_id","bronze_dataset"): p.add_value_provider_argument(f"--{name}",required=True)

class ParseFile(beam.DoFn):
 def __init__(self,metadata,batch): self.metadata,self.batch=metadata,batch
 def process(self,uri):
  with FileSystems.open(uri) as stream: lines=stream.read().decode("utf-8-sig").splitlines()
  counts={}
  for entity,headers,values,raw in parse(lines,self.metadata):
   counts[entity]=counts.get(entity,0)+1
   if values is None: continue
   yield {"entity_name":entity,"batch_id":self.batch,"source_file":uri,"record_number":counts[entity],"raw_record":raw,"payload":json.dumps(dict(zip(headers,values))),"ingested_at":datetime.now(timezone.utc).isoformat()}

def run(argv=None):
 opts=PipelineOptions(argv); opts.view_as(SetupOptions).save_main_session=True; custom=opts.view_as(Options); project=opts.get_all_options()["project"]
 with (Path(__file__).parents[2]/"config"/"entities.yaml").open() as stream: metadata=yaml.safe_load(stream)["entities"]
 with beam.Pipeline(options=opts) as p:
  records=(p|beam.Create([custom.input_uri.get()])|beam.ParDo(ParseFile(metadata,custom.batch_id.get())))
  records|WriteToBigQuery(table=lambda r:f"{project}:{custom.bronze_dataset.get()}.bronze_{r['entity_name'].lower()}",schema=SCHEMA,create_disposition="CREATE_NEVER",write_disposition="WRITE_APPEND")
if __name__=="__main__": run()
