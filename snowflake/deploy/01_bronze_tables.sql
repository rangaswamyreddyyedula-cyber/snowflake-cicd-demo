-- =====================================================================
-- 01 - BRONZE raw tables (as delivered by the source systems)
-- Safe to run many times (CREATE TABLE IF NOT EXISTS).
-- The pipeline runs this inside TEST_CICD_DEMO_TEST or TEST_CICD_DEMO_PROD.
-- To run it by hand in Snowsight, first run: USE DATABASE TEST_CICD_DEMO_TEST;
-- =====================================================================

-- Funds, as exported from eFront
CREATE TABLE IF NOT EXISTS BRONZE.EFRONT_FUNDS_RAW (
    FUND_ID           VARCHAR,
    FUND_NAME         VARCHAR,
    STRATEGY          VARCHAR,
    VINTAGE_YEAR      NUMBER(4),
    CURRENCY          VARCHAR,
    COMMITTED_CAPITAL NUMBER(18,2),
    SOURCE_SYSTEM     VARCHAR,
    LOADED_AT         TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Portfolio investments, as exported from eFront
CREATE TABLE IF NOT EXISTS BRONZE.EFRONT_INVESTMENTS_RAW (
    INVESTMENT_ID     VARCHAR,
    FUND_ID           VARCHAR,
    COMPANY_NAME      VARCHAR,
    SECTOR            VARCHAR,
    COUNTRY_CODE      VARCHAR,
    INVESTMENT_DATE   DATE,
    INVESTED_AMOUNT   NUMBER(18,2),
    STATUS            VARCHAR,
    SOURCE_SYSTEM     VARCHAR,
    LOADED_AT         TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Quarterly valuations, as exported from Chronograph
CREATE TABLE IF NOT EXISTS BRONZE.CHRONOGRAPH_VALUATIONS_RAW (
    VALUATION_ID      VARCHAR,
    INVESTMENT_ID     VARCHAR,
    VALUATION_DATE    DATE,
    FAIR_VALUE        NUMBER(18,2),
    CURRENCY          VARCHAR,
    SOURCE_SYSTEM     VARCHAR,
    LOADED_AT         TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);
