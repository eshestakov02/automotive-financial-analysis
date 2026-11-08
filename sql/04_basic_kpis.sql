-- 04_basic_kpis.sql
-- Run after 03_create_base_view.sql.
-- Goal: calculate the metrics that only need the current year's data.
-- Amounts are in USD millions. Percentage columns use 12.50 to mean 12.50%.
-- Debt and interest coverage ratios are multiples, not percentages.

-- Step 1: Create the KPI view from the combined financial statements.
-- NULLIF(value, 0) changes a zero denominator to NULL to avoid division by zero.
-- ROUND(value, 2) displays two decimal places.
CREATE OR REPLACE VIEW vw_kpi_basic AS
SELECT
    company_id,
    ticker,
    company_name,
    fiscal_year,
    revenue,
    operating_income,
    net_income,

    -- Profitability: profit divided by revenue, multiplied by 100.
    ROUND(100.0 * operating_income / NULLIF(revenue, 0), 2)
        AS operating_margin_pct,
    ROUND(100.0 * net_income / NULLIF(revenue, 0), 2)
        AS net_margin_pct,

    -- Cash generation: operating cash flow minus capital expenditures.
    -- The supplied CSV records capital expenditures as positive outflows.
    operating_cash_flow - capital_expenditures
        AS free_cash_flow,

    -- Use the separately supplied ex-finance / Automotive figures.
    -- Do not derive GM Automotive cash flow by subtracting finance cash flow.
    operating_cash_flow_ex_finance - capex_ex_finance
        AS ex_finance_free_cash_flow,

    -- Leverage: show consolidated debt and non-finance debt separately.
    ROUND(total_debt / NULLIF(shareholders_equity, 0), 2)
        AS debt_to_equity,
    ROUND(non_finance_debt / NULLIF(shareholders_equity, 0), 2)
        AS non_finance_debt_to_equity,

    -- Liquidity: cash plus marketable securities (an amount, not a ratio).
    cash + marketable_securities
        AS cash_and_securities,

    -- Coverage proxy: operating income divided by reported interest expense.
    -- Financing operations limit comparability across the three companies.
    ROUND(operating_income / NULLIF(interest_expense, 0), 2)
        AS interest_coverage_proxy
FROM vw_financial_base;

-- Step 2: Display the results in company and year order.
SELECT *
FROM vw_kpi_basic
ORDER BY ticker, fiscal_year;
