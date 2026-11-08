-- 05_revenue_growth.sql
-- Run after 03_create_base_view.sql.
-- Goal: compare each company's revenue with the immediately preceding year.
-- Formula: (current revenue - previous revenue) / previous revenue * 100.

CREATE OR REPLACE VIEW vw_revenue_growth AS
-- Step 1: Look back one row within each company.
-- WITH gives this intermediate query a name: revenue_history.
-- PARTITION BY keeps the companies separate; ORDER BY puts years in order.
-- LAG returns the value from the previous row.
WITH revenue_history AS (
    SELECT
        company_id,
        ticker,
        company_name,
        fiscal_year,
        revenue,
        LAG(fiscal_year) OVER (
            PARTITION BY company_id ORDER BY fiscal_year
        ) AS previous_fiscal_year,
        LAG(revenue) OVER (
            PARTITION BY company_id ORDER BY fiscal_year
        ) AS previous_revenue
    FROM vw_financial_base
)
-- Step 2: Calculate growth only when the previous calendar year is present.
-- Without this check, a missing year could produce a misleading YoY result.
-- CASE without ELSE returns NULL when the condition is not met.
SELECT
    company_id,
    ticker,
    company_name,
    fiscal_year,
    revenue,
    CASE
        WHEN fiscal_year = previous_fiscal_year + 1
        THEN previous_revenue
    END AS previous_year_revenue,
    CASE
        WHEN fiscal_year = previous_fiscal_year + 1
        THEN ROUND(
            100.0 * (revenue - previous_revenue)
            / NULLIF(previous_revenue, 0),
            2
        )
    END AS revenue_growth_pct
FROM revenue_history;

-- Step 3: Display the results.
-- 2021 growth is NULL because the CSV has no 2020 revenue.
SELECT *
FROM vw_revenue_growth
ORDER BY ticker, fiscal_year;
