CREATE TABLE
    IF NOT EXISTS `${PROJECT_ID}.pjabdulrahman_dq.quarantine_records` (
        entity_name STRING,
        record_key STRING,
        batch_id STRING,
        source_file STRING,
        rule_name STRING,
        failure_reason STRING,
        failed_at TIMESTAMP
    );