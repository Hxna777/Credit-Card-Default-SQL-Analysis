USE credit_card_default;

CREATE TABLE clients AS
SELECT
  ID                           AS client_id,
  LIMIT_BAL                    AS credit_limit,
  SEX                          AS sex,
  EDUCATION                    AS education,
  MARRIAGE                     AS marriage,
  AGE                          AS age,
  PAY_0                        AS status_sep,
  PAY_2                        AS status_aug,
  PAY_3                        AS status_jul,
  PAY_4                        AS status_jun,
  PAY_5                        AS status_may,
  PAY_6                        AS status_apr,
  BILL_AMT1                    AS bill_sep,
  BILL_AMT2                    AS bill_aug,
  BILL_AMT3                    AS bill_jul,
  BILL_AMT4                    AS bill_jun,
  BILL_AMT5                    AS bill_may,
  BILL_AMT6                    AS bill_apr,
  PAY_AMT1                     AS paid_sep,
  PAY_AMT2                     AS paid_aug,
  PAY_AMT3                     AS paid_jul,
  PAY_AMT4                     AS paid_jun,
  PAY_AMT5                     AS paid_may,
  PAY_AMT6                     AS paid_apr,
  `default.payment.next.month` AS defaulted
FROM credit_raw;
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT client_id) AS unique_clients
FROM clients;
SELECT defaulted, COUNT(*) AS clients
FROM clients
GROUP BY defaulted;
SELECT
  SUM(credit_limit IS NULL) AS missing_limit,
  SUM(status_sep IS NULL)   AS missing_status,
  SUM(bill_sep IS NULL)     AS missing_bill,
  SUM(defaulted IS NULL)    AS missing_default
FROM clients;
SELECT status_sep, COUNT(*) AS clients FROM clients GROUP BY status_sep ORDER BY status_sep;
SELECT education, COUNT(*) AS clients FROM clients GROUP BY education ORDER BY education;
SELECT marriage, COUNT(*) AS clients FROM clients GROUP BY marriage ORDER BY marriage;
SELECT MIN(credit_limit), MAX(credit_limit), MIN(age), MAX(age),
       MIN(bill_sep), MAX(bill_sep)
FROM clients;

SELECT COUNT(*) AS negative_bills FROM clients WHERE bill_sep < 0;