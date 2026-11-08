-- 03_create_base_view.sql
-- Run after creating the tables and loading the CSV files.
-- Goal: put the three financial statements into one company-year view.
-- All financial amounts are in USD millions.

-- Step 1: Create a view. A view saves a query; it does not copy the data.
-- Start with the income statement and add the company details.
-- Match each balance sheet and cash flow on BOTH company_id and fiscal_year.
-- LEFT JOIN keeps the income statement row if another statement is missing.
-- Missing values stay NULL (unknown); they are not changed to zero.
CREATE OR REPLACE VIEW vw_financial_base AS
SELECT
    i.company_id,
    c.ticker,
    c.company_name,
    i.fiscal_year,

    -- Income statement
    i.revenue,
    i.cost_of_revenue,
    i.gross_profit,
    i.operating_income,
    i.interest_expense,
    i.net_income,

    -- Balance sheet
    b.cash,
    b.inventory,
    b.total_assets,
    b.total_liabilities,
    b.total_debt,
    b.shareholders_equity,
    b.marketable_securities,
    b.non_finance_debt,
    b.finance_debt,

    -- Cash flow statement
    f.operating_cash_flow,
    f.capital_expenditures,
    f.operating_cash_flow_ex_finance,
    f.capex_ex_finance,
    f.finance_operating_cash_flow
FROM income_statements AS i
JOIN companies AS c
    ON i.company_id = c.company_id
LEFT JOIN balance_sheets AS b
    ON i.company_id = b.company_id
    AND i.fiscal_year = b.fiscal_year
LEFT JOIN cash_flows AS f
    ON i.company_id = f.company_id
    AND i.fiscal_year = f.fiscal_year;

-- Step 2: Check the combined data.
-- With the supplied CSV files, this returns 15 rows: 3 companies x 5 years.
SELECT *
FROM vw_financial_base
ORDER BY ticker, fiscal_year;
