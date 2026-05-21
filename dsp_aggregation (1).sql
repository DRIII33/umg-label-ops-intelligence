
-- =========================================================================================
-- SYSTEM vertical: RECORDED MUSIC ENTERPRISE WAREHOUSE AGGREGATION LAYER
-- TARGET ENVIRONMENT: Google BigQuery Cloud Architecture
-- SCOPE IDENTIFIER: driiiportfolio
-- OBJECTIVE: Standardize multi-DSP ingestion telemetry to identify financial ROI metrics.
-- =========================================================================================

SELECT
  artist_name,
  region,
  genre,
  COUNT(DISTINCT isrc) AS unique_releases_tracked,
  SUM(streams) AS aggregated_streams,
  SUM(marketing_spend_usd) AS aggregated_marketing_investment_usd,
  
  -- Calculate structural financial deployment yield parameters
  SAFE_DIVIDE(SUM(marketing_spend_usd), SUM(streams)) * 1000 AS blended_cpm_usd,
  
  -- Strategic Performance Indexing
  CASE
    WHEN SUM(marketing_spend_usd) > 0 THEN SAFE_DIVIDE(SUM(streams), SUM(marketing_spend_usd))
    ELSE SUM(streams)
  END AS streams_per_dollar_yield

FROM
  `driiiportfolio.umg_label_ops.simulated_telemetry`
GROUP BY
  artist_name,
  region,
  genre
ORDER BY
  aggregated_streams DESC;
