# Day 8: Power BI Credit Intelligence Dashboard

Day 8 turns the Day 7 Excel decision report into an interactive dashboard in
Power BI Service. The report is saved in the authenticated Power BI workspace
as `Credit Intelligence Dashboard Report`.

## Data source

- Workbook: `outputs/day7-credit-report/credit_intelligence_report.xlsx`
- Imported table: `DecisionDetailTable`
- Grain: one row per credit application

## Dashboard components

- KPI cards: total applications, total requested amount, and average credit score
- Column chart: applications by system decision
- Donut chart: applications by risk grade
- Detail table: company, industry, requested amount, credit score, risk grade,
  system decision, decision reason, and assessment match
- Interactive slicers: industry, risk grade, and system decision

## Verified baseline

- Total applications: 3
- Total requested amount: $3.65M
- Average credit score: 64.0
- System decisions: 1 approve, 1 decline, and 1 review
- Risk grades: 1 A, 1 C, and 1 D
- All three system recommendations match the stored assessment recommendation

The slicers were tested to confirm that the KPI cards, charts, and detail table
filter together. Requested amount and credit score remain unsummarized in the
detail table, while the KPI cards use Sum and Average respectively.

## Artifact note

The live report is stored in Power BI Service and requires the owner's Microsoft
account. Power BI did not produce a local `.pbix` or PDF download during the
Day 8 archive step, so the repository records the reproducible source workbook,
dashboard specification, and verified results instead of account-bound cloud
content.
