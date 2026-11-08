-- 06_roe.sql
-- Run after 03_create_base_view.sql.
-- Goal: calculate return on equity (ROE) using average shareholders' equity.
-- Average equity = (previous year-end equity + current year-end equity) / 2.
-- ROE (%) = current net income / average equity * 100.

CREATE OR REPLACE VIEW vw_roe AS
-- Step 1: Get the previous year's closing equity for each company.
WITH equity_history AS (
    SELECT
        company_id,
        ticker,
        company_name,
        fiscal_year,
        net_income,
        shareholders_equity,
        LAG(fiscal_year) OVER (
            PARTITION BY company_id ORDER BY fiscal_year
        ) AS previous_fiscal_year,
        LAG(shareholders_equity) OVER (
            PARTITION BY company_id ORDER BY fiscal_year
        ) AS previous_equity
    FROM vw_financial_base
),
-- Step 2: Average the two year-end balances only for consecutive years.
-- Missing either balance leaves the average NULL.
equity_averages AS (
    SELECT
        company_id,
        ticker,
        company_name,
        fiscal_year,
        net_income,
        CASE
            WHEN fiscal_year = previous_fiscal_year + 1
            THEN (previous_equity + shareholders_equity) / 2.0
        END AS average_equity
    FROM equity_history
)
-- Step 3: Divide net income by the average and convert to a percentage.
-- Keep the full precision of the average; round only the final ratio.
SELECT
    company_id,
    ticker,
    company_name,
    fiscal_year,
    net_income,
    average_equity,
    ROUND(100.0 * net_income / NULLIF(average_equity, 0), 2) AS roe_pct
FROM equity_averages;

-- Step 4: Display the results.
-- 2021 ROE is NULL because the CSV has no 2020 closing equity.
SELECT *
FROM vw_roe
ORDER BY ticker, fiscal_year;
