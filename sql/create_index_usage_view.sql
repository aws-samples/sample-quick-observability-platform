-- Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
-- SPDX-License-Identifier: MIT-0
-- Index Usage view
-- Matches the QuickSight Index Usage dataset Custom SQL
-- Shows per-source storage metrics with human-readable size columns
-- Deduplicates: Amazon Quick emits one log event per document indexed,
-- each containing the same aggregate source-level totals. This GROUP BY
-- collapses those duplicates into one row per source per day.
CREATE OR REPLACE VIEW ${DATABASE}.index_usage AS
SELECT
    MAX(CAST(from_iso8601_timestamp(timestamp) AS timestamp)) AS event_time,
    MAX(CASE WHEN user_arn LIKE '%/%' THEN ELEMENT_AT(SPLIT(user_arn, '/'), -1) ELSE user_arn END) AS user_name,
    consumed_index_size,
    ROUND(consumed_index_size / 1073741824.0, 4) AS consumed_index_size_gb,
    ROUND(consumed_index_size / 1048576.0, 2) AS consumed_index_size_mb,
    source_type,
    source_name,
    source_arn,
    consumed_source_size,
    ROUND(consumed_source_size / 1073741824.0, 4) AS consumed_source_size_gb,
    ROUND(consumed_source_size / 1048576.0, 2) AS consumed_source_size_mb,
    consumed_source_doc_count,
    MAX(resource_arn) AS resource_arn,
    MAX(account_id) AS account_id,
    year, month, day
FROM ${DATABASE}.index_usage_logs
WHERE timestamp IS NOT NULL
GROUP BY source_arn, source_type, source_name, consumed_index_size,
         consumed_source_size, consumed_source_doc_count, year, month, day;
