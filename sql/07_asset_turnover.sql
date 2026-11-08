-- 07_asset_turnover.sql
-- Run after 03_create_base_view.sql.
-- Goal: calculate revenue generated per dollar of average total assets.
-- Average assets = (previous year-end assets + current year-end assets) / 2.
-- Asset turnover = revenue / average assets. The result is a multiple.

CREATE OR REPLACE VIEW vw_asset_turnover AS
-- Step 1: Get the previous year's closing assets for each company.
WITH asset_history AS (
    SELECT
        company_id,
        ticker,
        company_name,
        fiscal_year,
        revenue,
        total_assets,
        LAG(fiscal_year) OVER (
            PARTITION BY company_id ORDER BY fiscal_year
        ) AS previous_fiscal_year,
        LAG(total_assets) OVER (
            PARTITION BY company_id ORDER BY fiscal_year
        ) AS previous_assets
    FROM vw_financial_base
),
-- Step 2: Average the two year-end balances only for consecutive years.
asset_averages AS (
    SELECT
        company_id,
        ticker,
        company_name,
        fiscal_year,
        revenue,
        CASE
            WHEN fiscal_year = previous_fiscal_year + 1
            THEN (previous_assets + total_assets) / 2.0
        END AS average_assets
    FROM asset_history
)
-- Step 3: Divide revenue by average assets. Do not multiply by 100.
SELECT
    company_id,
    ticker,
    company_name,
    fiscal_year,
    revenue,
    average_assets,
    ROUND(revenue / NULLIF(average_assets, 0), 2) AS asset_turnover
FROM asset_averages;

-- Step 4: Display the results.
-- 2021 turnover is NULL because the CSV has no 2020 closing assets.
SELECT *
FROM vw_asset_turnover
ORDER BY ticker, fiscal_year;
