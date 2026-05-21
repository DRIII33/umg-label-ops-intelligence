
-- =========================================================================================
-- SYSTEM VERTICAL: PRESCRIPTIVE AUTOMATED ACTION ALERTS (AIR TRAFFIC CONTROL VIEW)
-- TARGET ENVIRONMENT: Google BigQuery Cloud Architecture
-- SCOPE IDENTIFIER: driiiportfolio
-- OBJECTIVE: Close the 2026 Latin Market Breakout Gaps via analytical anomaly triggers.
-- =========================================================================================

CREATE OR REPLACE VIEW `driiiportfolio.umg_label_ops.v_viral_alerts` AS (
  WITH TimeSeriesCalculations AS (
    SELECT
      timestamp,
      artist_name,
      region,
      dsp,
      genre,
      isrc,
      streams,
      marketing_spend_usd,
      
      -- Generate analytical rolling averages using analytics partitions
      AVG(streams) OVER(
        PARTITION BY artist_name, region, dsp
        ORDER BY timestamp
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
      ) AS rolling_3p_stream_avg,
      
      -- Isolate previous timestamp metrics to track immediate velocity acceleration
      LAG(streams, 1) OVER(
        PARTITION BY artist_name, region, dsp
        ORDER BY timestamp
      ) AS prior_period_streams
    FROM
      `driiiportfolio.umg_label_ops.simulated_telemetry`
  ),
  VelocityMetrics AS (
    SELECT
      *,
      -- Quantify exact statistical rate of consumption growth
      CASE
        WHEN prior_period_streams IS NOT NULL AND prior_period_streams > 0
          THEN SAFE_DIVIDE((streams - prior_period_streams), prior_period_streams) * 100
        ELSE 0.0
      END AS stream_velocity_percentage_spike
    FROM
      TimeSeriesCalculations
  )
  SELECT
    timestamp,
    artist_name,
    region,
    dsp,
    genre,
    isrc,
    streams,
    marketing_spend_usd,
    ROUND(rolling_3p_stream_avg, 1) AS rolling_3p_stream_avg,
    ROUND(stream_velocity_percentage_spike, 2) AS stream_velocity_percentage_spike,
    
    -- PRESCRIPTIVE OPERATIONAL ACTION TRIGGERS (Close systemic latency gap)
    CASE
      WHEN stream_velocity_percentage_spike >= 150.0 AND marketing_spend_usd = 0.0
        THEN 'TRIGGER_ACTION: IMMEDIATE REGIONAL BUDGET INJECTION REQUIRED — UNCAPTURED VIRALITY'
      WHEN stream_velocity_percentage_spike >= 150.0 AND marketing_spend_usd > 0.0
        THEN 'TRIGGER_ACTION: SCALED SUPPLY CHAIN COURIER VERIFICATION — ACCELERATE DSP PLAYLIST PLACEMENT'
      WHEN streams > 50000 AND marketing_spend_usd > 2500.0 AND stream_velocity_percentage_spike < -30.0
        THEN 'TRIGGER_ACTION: FINANCIAL MITIGATION REQUIRED — HALT DEFENSIVE MARKETING OVERRUN'
      ELSE 'MONITOR_STATUS: STEADY LAUNCH STATE LIFE-CYCLE'
    END AS operational_prescriptive_protocol

  FROM
    VelocityMetrics
  WHERE
    -- Filter out historical baseline padding to present actionable insights exclusively
    stream_velocity_percentage_spike != 0.0
);
