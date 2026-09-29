--!jinja
-- =====================================================================
-- 05 - Python stored procedure whose code is imported from Git
-- The handler file snowflake/procedures/analytics_proc.py is read from the
-- Snowflake Git repository of this environment's branch.
-- Template values come from the pipeline:
--   EXECUTE IMMEDIATE FROM ... USING (database => 'THREEIGROUP_DEV_DB', branch => 'dev', env => 'dev')
-- =====================================================================

CREATE OR REPLACE PROCEDURE {{ database }}.GOLD.SP_FUND_SUMMARY()
  RETURNS VARIANT
  LANGUAGE PYTHON
  RUNTIME_VERSION = '3.12'
  PACKAGES = ('snowflake-snowpark-python')
  IMPORTS = ('@{{ database }}.INTEGRATIONS.GITHUB_REPO/branches/{{ branch }}/snowflake/procedures/analytics_proc.py')
  HANDLER = 'analytics_proc.main'
  COMMENT = 'Portfolio summary by currency ({{ env }}) - code imported from GitHub';
