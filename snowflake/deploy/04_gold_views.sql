-- =====================================================================
-- 04 - GOLD: business-ready views for reporting (Power BI, analysts)
-- Analysts (ANALYST role) can read these views but not BRONZE or SILVER.
-- =====================================================================

-- Latest valuation per investment, with its multiple on invested capital
CREATE OR REPLACE VIEW GOLD.V_INVESTMENT_LATEST_VALUE AS
SELECT
    C.INVESTMENT_ID,
    C.COMPANY_NAME,
    C.SECTOR,
    C.COUNTRY_CODE,
    C.STATUS,
    F.FUND_NAME,
    F.STRATEGY,
    F.CURRENCY,
    C.INVESTED_AMOUNT,
    V.VALUATION_DATE,
    V.FAIR_VALUE,
    ROUND(V.FAIR_VALUE / NULLIF(C.INVESTED_AMOUNT, 0), 2) AS MOIC
FROM SILVER.DIM_PORTFOLIO_COMPANY C
JOIN SILVER.DIM_FUND F       ON F.FUND_ID = C.FUND_ID
JOIN SILVER.FACT_VALUATION V ON V.INVESTMENT_ID = C.INVESTMENT_ID
QUALIFY ROW_NUMBER() OVER (PARTITION BY C.INVESTMENT_ID ORDER BY V.VALUATION_DATE DESC) = 1;

-- Fund-level performance
CREATE OR REPLACE VIEW GOLD.V_FUND_PERFORMANCE AS
SELECT
    FUND_NAME,
    STRATEGY,
    CURRENCY,
    COUNT(*)                                                    AS INVESTMENTS,
    SUM(INVESTED_AMOUNT)                                        AS TOTAL_INVESTED,
    SUM(FAIR_VALUE)                                             AS TOTAL_FAIR_VALUE,
    ROUND(SUM(FAIR_VALUE) / NULLIF(SUM(INVESTED_AMOUNT), 0), 2) AS FUND_MOIC
FROM GOLD.V_INVESTMENT_LATEST_VALUE
GROUP BY FUND_NAME, STRATEGY, CURRENCY;

-- Exposure by sector
CREATE OR REPLACE VIEW GOLD.V_SECTOR_EXPOSURE AS
SELECT
    SECTOR,
    CURRENCY,
    COUNT(*)        AS INVESTMENTS,
    SUM(FAIR_VALUE) AS TOTAL_FAIR_VALUE
FROM GOLD.V_INVESTMENT_LATEST_VALUE
GROUP BY SECTOR, CURRENCY;
