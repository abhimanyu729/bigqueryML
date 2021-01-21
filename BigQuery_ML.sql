# Number of people in different demographics

SELECT 
sex, marital_status, count( id ) AS count
FROM `bigquery-public-data.ml_datasets.credit_card_default` 
GROUP BY 1,2
ORDER BY 1,2



#training the model
CREATE or REPLACE MODEL creditcard.creditdefault_model
OPTIONS
  (model_type='logistic_reg', labels=['default_payment_next_month']) AS

WITH params AS (
    SELECT
    1 AS TRAIN,
    2 AS EVAL
    ),

  creditcard AS (
  SELECT
    limit_balance AS balance, age, pay_0, pay_2, pay_3, pay_4, bill_amt_1, bill_amt_2, bill_amt_3, bill_amt_4, bill_amt_5, bill_amt_6, pay_amt_1, pay_amt_2, pay_amt_3, pay_amt_4, pay_amt_6, 
    CAST(default_payment_next_month AS INT64) AS default_payment_next_month
    FROM
    `bigquery-public-data.ml_datasets.credit_card_default` , params
    WHERE 
    MOD(ABS(FARM_FINGERPRINT(CAST( id AS STRING))),2) = params.TRAIN
  )

  SELECT *
  FROM creditcard

#evaluating the model
SELECT
  roc_auc,
  CASE
    WHEN roc_auc > .9 THEN 'good'
    WHEN roc_auc > .8 THEN 'fair'
    WHEN roc_auc > .7 THEN 'decent'
    WHEN roc_auc > .6 THEN 'not great'
  ELSE 'poor' END AS model_quality
FROM
  ML.EVALUATE(MODEL creditcard.creditdefault_model,  (

WITH params AS (
    SELECT
    1 AS TRAIN,
    2 AS EVAL
    ),

  creditcard AS (
  SELECT
    limit_balance AS balance, age, pay_0, pay_2, pay_3, pay_4, bill_amt_1, bill_amt_2, bill_amt_3, bill_amt_4, bill_amt_5, bill_amt_6, pay_amt_1, pay_amt_2, pay_amt_3, pay_amt_4, pay_amt_6, 
    CAST(default_payment_next_month AS INT64) AS default_payment_next_month
    FROM
    `bigquery-public-data.ml_datasets.credit_card_default` , params
    WHERE 
    MOD(ABS(FARM_FINGERPRINT(CAST( id AS STRING))),2) = params.TRAIN
  )

  SELECT *
  FROM creditcard

));



######################################################################################################################################################################

## Training model after feature engineering


## Training Model
CREATE or REPLACE MODEL creditcard.creditdefault_model
OPTIONS
  (model_type='logistic_reg', labels=['default_payment_next_month']) AS

WITH params AS (
    SELECT
    1 AS TRAIN,
    2 AS EVAL
    ),

  creditcard AS (
  SELECT
    limit_balance AS balance, age, (pay_0 + pay_2 + pay_3 + pay_4 + CAST( pay_5 AS INT64 ) + CAST( pay_6 AS INT64)) AS pay , (bill_amt_1 + bill_amt_2 + bill_amt_3 + bill_amt_4 + bill_amt_5 + bill_amt_6) as bill, (pay_amt_1 + pay_amt_2 + pay_amt_3 + pay_amt_4 + pay_amt_5 + pay_amt_6) as pay_amt, CAST(default_payment_next_month AS INT64) AS default_payment_next_month, CAST( sex AS INT64) AS SEX, CAST( education_level AS INT64) education, CAST(marital_status AS INT64) AS marital_status
    FROM
    `bigquery-public-data.ml_datasets.credit_card_default` , params
    WHERE 
    MOD(ABS(FARM_FINGERPRINT(CAST( id AS STRING))),2) = params.TRAIN
  )

  SELECT *
  FROM creditcard




#evaluating the model
SELECT
  roc_auc,
  CASE
    WHEN roc_auc > .9 THEN 'good'
    WHEN roc_auc > .8 THEN 'fair'
    WHEN roc_auc > .7 THEN 'decent'
    WHEN roc_auc > .6 THEN 'not great'
  ELSE 'poor' END AS model_quality
FROM
  ML.EVALUATE(MODEL creditcard.creditdefault_model,  (

WITH params AS (
    SELECT
    1 AS TRAIN,
    2 AS EVAL
    ),

  creditcard AS (
  SELECT
    limit_balance AS balance, age, (pay_0 + pay_2 + pay_3 + pay_4 + CAST( pay_5 AS INT64 ) + CAST( pay_6 AS INT64)) AS pay , (bill_amt_1 + bill_amt_2 + bill_amt_3 + bill_amt_4 + bill_amt_5 + bill_amt_6) as bill, (pay_amt_1 + pay_amt_2 + pay_amt_3 + pay_amt_4 + pay_amt_5 + pay_amt_6) as pay_amt, CAST(default_payment_next_month AS INT64) AS default_payment_next_month, CAST( sex AS INT64) AS SEX, CAST( education_level AS INT64) education, CAST(marital_status AS INT64) AS marital_status
    FROM
    `bigquery-public-data.ml_datasets.credit_card_default` , params
    WHERE 
    MOD(ABS(FARM_FINGERPRINT(CAST( id AS STRING))),3) = params.EVAL
  )

  SELECT *
  FROM creditcard

));
