FROM gcr.io/dataflow-templates-base/python311-template-launcher-base
WORKDIR /template
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY src ./src
COPY config/entities.yaml ./config/entities.yaml
ENV PYTHONPATH=/template
ENV FLEX_TEMPLATE_PYTHON_PY_FILE=/template/src/ingestion/dataflow_job.py
ENV FLEX_TEMPLATE_PYTHON_REQUIREMENTS_FILE=/template/requirements.txt
