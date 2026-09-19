CREATE
OR REPLACE VIEW `${PROJECT_ID}.pjabdulrahman_dq.vw_dq_summary` AS
SELECT
    batch_id,
    entity_name,
    rule_name,
    COUNT(*) failed_record_count,
    MAX(failed_at) last_failure_at
FROM
    `${PROJECT_ID}.pjabdulrahman_dq.quarantine_records`
GROUP BY
    batch_id,
    entity_name,
    rule_name;