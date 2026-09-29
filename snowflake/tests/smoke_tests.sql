--!jinja
-- =====================================================================
-- Smoke tests - run by the pipeline after every deployment:
--   EXECUTE IMMEDIATE FROM @<DB>.INTEGRATIONS.GITHUB_REPO/branches/<branch>/snowflake/tests/smoke_tests.sql
--     USING (database => '<DB>', branch => '<branch>', env => '<env>')
-- Each check raises an error if it fails, so the GitHub job turns red.
-- =====================================================================

DECLARE
  n INTEGER;
  bronze_empty    EXCEPTION (-20001, 'Smoke test failed: BRONZE tables are empty');
  silver_dupes    EXCEPTION (-20002, 'Smoke test failed: SILVER.DIM_PORTFOLIO_COMPANY has duplicate INVESTMENT_ID');
  gold_empty      EXCEPTION (-20003, 'Smoke test failed: GOLD.V_FUND_PERFORMANCE returns no rows');
  proc_failed     EXCEPTION (-20004, 'Smoke test failed: GOLD.SP_FUND_SUMMARY returned no funds');
BEGIN
  -- 1. BRONZE has data
  SELECT LEAST(
           (SELECT COUNT(*) FROM {{ database }}.BRONZE.EFRONT_FUNDS_RAW),
           (SELECT COUNT(*) FROM {{ database }}.BRONZE.EFRONT_INVESTMENTS_RAW),
           (SELECT COUNT(*) FROM {{ database }}.BRONZE.CHRONOGRAPH_VALUATIONS_RAW))
    INTO :n;
  IF (n = 0) THEN RAISE bronze_empty; END IF;

  -- 2. SILVER removed the duplicate investment
  SELECT COUNT(*) - COUNT(DISTINCT INVESTMENT_ID)
    INTO :n FROM {{ database }}.SILVER.DIM_PORTFOLIO_COMPANY;
  IF (n > 0) THEN RAISE silver_dupes; END IF;

  -- 3. GOLD view answers
  SELECT COUNT(*) INTO :n FROM {{ database }}.GOLD.V_FUND_PERFORMANCE;
  IF (n = 0) THEN RAISE gold_empty; END IF;

  -- 4. Python procedure imported from Git runs
  CALL {{ database }}.GOLD.SP_FUND_SUMMARY();
  SELECT COALESCE($1:funds::INTEGER, 0) INTO :n FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));
  IF (n = 0) THEN RAISE proc_failed; END IF;

  RETURN 'All smoke tests passed ({{ env }})';
END;
