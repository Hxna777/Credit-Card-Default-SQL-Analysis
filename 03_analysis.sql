use credit_card_default;
-- q1: portfolio snapshot
SELECT
  COUNT(*)                          AS clients,
  SUM(defaulted)                    AS defaulters,
  ROUND(100 * AVG(defaulted), 1)    AS default_rate_pct,
  ROUND(AVG(credit_limit))          AS avg_limit,
  ROUND(AVG(GREATEST(bill_sep, 0))) AS avg_sept_bill
FROM clients;
-- q2: default rate by credit limit band 
SELECT MIN(credit_limit), MAX(credit_limit) FROM clients;
SELECT
  CASE
    WHEN credit_limit < 50000  THEN '1. under 50k'
    WHEN credit_limit < 100000 THEN '2. 50k-99k'
    WHEN credit_limit < 200000 THEN '3. 100k-199k'
    WHEN credit_limit < 400000 THEN '4. 200k-399k'
    ELSE                            '5. 400k and above'
  END AS limit_band,
  COUNT(*)                       AS clients,
  SUM(defaulted)                 AS defaulters,
  ROUND(100 * AVG(defaulted), 1) AS default_rate_pct
FROM clients
GROUP BY limit_band
ORDER BY limit_band;
-- q3a: default rate by latest repayment status
SELECT
  status_sep,
  COUNT(*)                       AS clients,
  ROUND(100 * AVG(defaulted), 1) AS default_rate_pct
FROM clients
GROUP BY status_sep
ORDER BY status_sep;
-- q3b
SELECT
  CASE
    WHEN status_sep = -2 THEN '1. status -2 (undocumented)'
    WHEN status_sep = -1 THEN '2. status -1 (paid on time)'
    WHEN status_sep = 0  THEN '3. status 0 (undocumented, often read as revolving)'
    WHEN status_sep = 1  THEN '4. 1 month late'
    WHEN status_sep = 2  THEN '5. 2 months late'
    ELSE                      '6. 3+ months late'
  END AS repayment_status,
  COUNT(*)                       AS clients,
  SUM(defaulted)                 AS defaulters,
  ROUND(100 * AVG(defaulted), 1) AS default_rate_pct
FROM clients
GROUP BY repayment_status
ORDER BY repayment_status;
-- q4: default rate by utilization
SELECT COUNT(*) FROM clients WHERE credit_limit <= 0;
SELECT
  CASE
    WHEN GREATEST(bill_sep, 0) / credit_limit = 0    THEN '1. zero balance'
    WHEN GREATEST(bill_sep, 0) / credit_limit < 0.30 THEN '2. under 30%'
    WHEN GREATEST(bill_sep, 0) / credit_limit < 0.60 THEN '3. 30-59%'
    WHEN GREATEST(bill_sep, 0) / credit_limit < 0.90 THEN '4. 60-89%'
    ELSE                                                  '5. 90% or more'
  END AS utilization_band,
  COUNT(*)                       AS clients,
  SUM(defaulted)                 AS defaulters,
  ROUND(100 * AVG(defaulted), 1) AS default_rate_pct
FROM clients
GROUP BY utilization_band
ORDER BY utilization_band;
-- q3c: how concentrated is the risk
SELECT
  COUNT(*)       AS clients_1plus_late,
  SUM(defaulted) AS defaulters_1plus_late,
  ROUND(100 * SUM(defaulted) / (SELECT SUM(defaulted) FROM clients), 1) AS pct_of_all_defaults
FROM clients
WHERE status_sep >= 1;
-- q5: line management segments
WITH segmented AS (
  SELECT
    defaulted,
    credit_limit,
    CASE
      WHEN status_sep <= 0 THEN '1. Low risk (on time / revolving / no use)'
      WHEN status_sep = 1  THEN '2. Watch (1 month late)'
      ELSE                      '3. High risk (2+ months late)'
    END AS risk_tier,
    CASE
      WHEN GREATEST(bill_sep, 0) / credit_limit < 0.30 THEN 'a. low use (<30%)'
      WHEN GREATEST(bill_sep, 0) / credit_limit < 0.60 THEN 'b. medium use (30-59%)'
      ELSE                                                  'c. high use (60%+)'
    END AS use_tier
  FROM clients
)
SELECT
  risk_tier,
  use_tier,
  COUNT(*)                                                  AS clients,
  ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM clients), 1) AS pct_of_clients,
  ROUND(100 * AVG(defaulted), 1)                            AS default_rate_pct,
  ROUND(AVG(credit_limit))                                  AS avg_limit
FROM segmented
GROUP BY risk_tier, use_tier
ORDER BY risk_tier, use_tier;