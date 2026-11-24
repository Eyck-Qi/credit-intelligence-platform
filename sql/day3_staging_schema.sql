
CREATE TABLE IF NOT EXISTS stg_financial_statements (
    staging_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    company_name TEXT,
    fiscal_year TEXT,
    revenue TEXT,
    net_income TEXT,
    total_assets TEXT,
    total_liabilities TEXT,
    cash_flow_from_operations TEXT,
    source_file TEXT NOT NULL,
    loaded_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_stg_financials_company_year
    ON stg_financial_statements (company_name, fiscal_year);
