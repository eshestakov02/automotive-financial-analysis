-- 08_inventory_turnover.sql
-- Run after 03_create_base_view.sql.
-- Goal: calculate cost of revenue relative to average inventory.
-- Average inventory = (previous year-end inventory + current year-end inventory) / 2.
-- Inventory turnover = cost of revenue / average inventory.
-- The result is a multiple, not a percentage.

CREATE OR REPLACE VIEW vw_inventory_turnover AS
-- Step 1: Get the previous year's closing inventory for each company.
WITH inventory_history AS (
    SELECT
        company_id,
        ticker,
        company_name,
        fiscal_year,
        cost_of_revenue,
        inventory,
        LAG(fiscal_year) OVER (
            PARTITION BY company_id ORDER BY fiscal_year
        ) AS previous_fiscal_year,
        LAG(inventory) OVER (
            PARTITION BY company_id ORDER BY fiscal_year
        ) AS previous_inventory
    FROM vw_financial_base
),
-- Step 2: Average the two year-end balances only for consecutive years.
inventory_averages AS (
    SELECT
        company_id,
        ticker,
        company_name,
        fiscal_year,
        cost_of_revenue,
        CASE
            WHEN fiscal_year = previous_fiscal_year + 1
            THEN (previous_inventory + inventory) / 2.0
        END AS average_inventory
    FROM inventory_history
)
-- Step 3: Divide cost of revenue by average inventory.
SELECT
    company_id,
    ticker,
    company_name,
    fiscal_year,
    cost_of_revenue,
    average_inventory,
    ROUND(cost_of_revenue / NULLIF(average_inventory, 0), 2) AS inventory_turnover
FROM inventory_averages;

-- Step 4: Display the results.
-- 2021 turnover is NULL because the CSV has no 2020 closing inventory.
SELECT *
FROM vw_inventory_turnover
ORDER BY ticker, fiscal_year;
