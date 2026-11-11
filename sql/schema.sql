BEGIN;

CREATE TABLE IF NOT EXISTS companies (
    company_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    legal_name TEXT NOT NULL,
    industry TEXT NOT NULL,
    country_code CHAR(2) NOT NULL DEFAULT 'US',
    founded_year SMALLINT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT companies_legal_name_unique UNIQUE (legal_name),
    CONSTRAINT companies_founded_year_valid
        CHECK (founded_year IS NULL OR founded_year BETWEEN 1800 AND 2100)
);

CREATE TABLE IF NOT EXISTS financial_statements (
    statement_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    company_id BIGINT NOT NULL REFERENCES companies(company_id) ON DELETE CASCADE,
    fiscal_year SMALLINT NOT NULL,
    revenue NUMERIC(18, 2) NOT NULL,
    net_income NUMERIC(18, 2) NOT NULL,
    total_assets NUMERIC(18, 2) NOT NULL,
    total_liabilities NUMERIC(18, 2) NOT NULL,
    cash_flow_from_operations NUMERIC(18, 2),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT financial_statements_company_year_unique
        UNIQUE (company_id, fiscal_year),
    CONSTRAINT financial_statements_year_valid
        CHECK (fiscal_year BETWEEN 1900 AND 2100),
    CONSTRAINT financial_statements_nonnegative_values
        CHECK (revenue >= 0 AND total_assets >= 0 AND total_liabilities >= 0)
);

CREATE TABLE IF NOT EXISTS loan_applications (
    application_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    company_id BIGINT NOT NULL REFERENCES companies(company_id) ON DELETE RESTRICT,
    requested_amount NUMERIC(18, 2) NOT NULL CHECK (requested_amount > 0),
    loan_purpose TEXT NOT NULL,
    term_months SMALLINT NOT NULL CHECK (term_months BETWEEN 1 AND 360),
    application_status TEXT NOT NULL DEFAULT 'pending',
    submitted_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    decided_at TIMESTAMPTZ,
    CONSTRAINT loan_applications_status_valid
        CHECK (application_status IN ('pending', 'approved', 'declined', 'withdrawn')),
    CONSTRAINT loan_applications_decision_time_valid
        CHECK (decided_at IS NULL OR decided_at >= submitted_at)
);

CREATE TABLE IF NOT EXISTS credit_assessments (
    assessment_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    application_id BIGINT NOT NULL REFERENCES loan_applications(application_id) ON DELETE CASCADE,
    credit_score SMALLINT NOT NULL CHECK (credit_score BETWEEN 0 AND 100),
    risk_grade TEXT NOT NULL CHECK (risk_grade IN ('A', 'B', 'C', 'D', 'E')),
    debt_to_asset_ratio NUMERIC(7, 4)
        CHECK (debt_to_asset_ratio IS NULL OR debt_to_asset_ratio >= 0),
    recommendation TEXT NOT NULL
        CHECK (recommendation IN ('approve', 'review', 'decline')),
    rationale TEXT,
    assessed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT credit_assessments_application_unique UNIQUE (application_id)
);

CREATE INDEX IF NOT EXISTS idx_financial_statements_company
    ON financial_statements (company_id);

CREATE INDEX IF NOT EXISTS idx_loan_applications_company_status
    ON loan_applications (company_id, application_status);

CREATE INDEX IF NOT EXISTS idx_credit_assessments_risk_grade
    ON credit_assessments (risk_grade);

COMMIT;
