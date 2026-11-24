# Day 10 Portfolio Guide

## 30-second project summary

I built an end-to-end credit intelligence platform that transforms raw company
financial data into explainable lending recommendations. PostgreSQL handles the
staging, data-quality checks, financial calculations, risk classification, and
decision logic. Python automates CSV and formatted Excel reporting, and Power BI
presents the portfolio through KPIs, risk distributions, filters, and detailed
decision reasons.

## Resume-ready version

- Built a staged PostgreSQL ETL workflow to validate, deduplicate, reconcile,
  and load borrower financial data into a normalized credit analytics model.
- Developed explainable SQL risk and lending-decision views using CTEs, window
  functions, financial ratios, and conditional rules to classify applications
  as approve, review, or decline.
- Automated CSV and formatted Excel outputs with Python and created a Power BI
  dashboard for portfolio exposure, credit quality, decision distribution, and
  assessment monitoring.

## Interview explanation

### What problem does it solve?

It organizes several pieces of credit analysis into one repeatable workflow.
Instead of manually checking raw files, calculating ratios, and writing a
recommendation for every borrower, the platform validates the inputs, computes
the financial indicators, applies transparent decision rules, and produces a
report that an analyst can review.

### Why use a staging table?

The raw CSV intentionally contains text fields, duplicates, and invalid values.
Loading it first into a permissive staging table prevents bad records from
breaking or contaminating the core tables. SQL validation decides which rows
are accepted, rejected, or deduplicated before the formal load.

### Why use SQL views?

Views save the calculation logic without duplicating the underlying data. The
financial metrics, latest risk profile, and decision engine can be queried
consistently by Python, Excel, or another reporting tool.

### What does Python add?

SQL performs the database calculations. Python connects to the database,
retrieves the result sets, and creates portable CSV and Excel deliverables. It
also makes the workflow testable and repeatable.

### What is the main limitation?

The project uses a small synthetic dataset and rule-based thresholds. It shows
data engineering, financial analysis, decision logic, and reporting, but it is
not a production underwriting model and does not estimate probability of
default from historical outcomes.

## Evidence checklist

- [x] SQL schema, staging, validation, reconciliation, views, and decision logic
- [x] Python CSV and Excel report generation
- [x] Automated tests and lint checks
- [x] Power BI dashboard with KPI measures and interactive slicers
- [x] Add a clean dashboard screenshot to `docs/images/`
- [x] Add the screenshot to the main README
- [ ] Commit and push the final Day 10 documentation
