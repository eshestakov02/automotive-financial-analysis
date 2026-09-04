-- =============================================
-- Automotive Financial Analysis
-- 02_load_data.sql
--
-- Loads cleaned financial statement CSV files
-- into PostgreSQL.
-- Financial statement amounts are in USD millions.
-- =============================================


-- Income Statements
\copy income_statements
FROM '../data/income_statements.csv'
WITH (
    FORMAT csv,
    HEADER true
);


-- Balance Sheets
\copy balance_sheets
FROM '../data/balance_sheets.csv'
WITH (
    FORMAT csv,
    HEADER true
);


-- Cash Flow Statements
\copy cash_flows
FROM '../data/cash_flows.csv'
WITH (
    FORMAT csv,
    HEADER true
);

