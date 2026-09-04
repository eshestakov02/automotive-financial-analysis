-- =============================================
-- Automotive Financial Analysis
-- 01_create_tables.sql
--
-- Creates the core PostgreSQL tables used to
-- store annual financial data for Tesla, Ford,
-- and General Motors.
--
-- Financial statement amounts are in USD millions.
-- =============================================


-- -------------------------
-- Companies
-- -------------------------

CREATE TABLE IF NOT EXISTS companies (
    company_id SERIAL PRIMARY KEY,
    ticker VARCHAR(10) UNIQUE NOT NULL,
    company_name VARCHAR(100) NOT NULL
);

INSERT INTO companies (ticker, company_name)
VALUES
    ('TSLA', 'Tesla Inc.'),
    ('F', 'Ford Motor Company'),
    ('GM', 'General Motors Company')
ON CONFLICT (ticker) DO NOTHING;


-- -------------------------
-- Income Statements
-- -------------------------

CREATE TABLE IF NOT EXISTS income_statements (
    company_id INT REFERENCES companies(company_id),
    fiscal_year INT,
    revenue NUMERIC,
    cost_of_revenue NUMERIC,
    gross_profit NUMERIC,
    operating_income NUMERIC,
    interest_expense NUMERIC,
    net_income NUMERIC,

    PRIMARY KEY (company_id, fiscal_year)
);


-- -------------------------
-- Balance Sheets
-- -------------------------

CREATE TABLE IF NOT EXISTS balance_sheets (
    company_id INT REFERENCES companies(company_id),
    fiscal_year INT,
    cash NUMERIC,
    inventory NUMERIC,
    total_assets NUMERIC,
    total_liabilities NUMERIC,
    total_debt NUMERIC,
    shareholders_equity NUMERIC,
    marketable_securities NUMERIC,
    non_finance_debt NUMERIC,
    finance_debt NUMERIC,

    PRIMARY KEY (company_id, fiscal_year)
);


-- -------------------------
-- Cash Flow Statements
-- -------------------------

CREATE TABLE IF NOT EXISTS cash_flows (
    company_id INT REFERENCES companies(company_id),
    fiscal_year INT,
    operating_cash_flow NUMERIC,
    capital_expenditures NUMERIC,
    operating_cash_flow_ex_finance NUMERIC,
    capex_ex_finance NUMERIC,
    finance_operating_cash_flow NUMERIC,

    PRIMARY KEY (company_id, fiscal_year)
);

COMMENT ON TABLE companies IS
'Reference table for the three automakers, storing company ID, ticker, and company name.';

COMMENT ON TABLE income_statements IS
'Annual income statement data by company and fiscal year, including revenue, cost of revenue, gross profit, operating income, interest expense, and net income.';

COMMENT ON TABLE balance_sheets IS
'Annual balance sheet data by company and fiscal year, including liquidity, assets, liabilities, shareholder equity, and finance versus non-finance debt.';

COMMENT ON TABLE cash_flows IS
'Annual cash flow data by company and fiscal year, including consolidated operating cash flow and capital expenditures plus ex-finance or automotive cash flow measures.';

