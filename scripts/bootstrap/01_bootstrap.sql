-- =====================================================================
-- ONE-TIME BOOTSTRAP - run by an ACCOUNTADMIN in Snowsight
-- Creates the Terraform role, warehouse, service user and access token.
-- No key pair needed: the service user logs in with a programmatic
-- access token (PAT), generated at the end of this script.
-- Run it once in the TEST account and once in the PROD account
-- (only once if TEST and PROD are the same Snowflake account).
-- =====================================================================

USE ROLE ACCOUNTADMIN;

-- 1. Role used only by Terraform
CREATE ROLE IF NOT EXISTS TF_DEPLOY_ROLE
  COMMENT = 'Terraform CI/CD deploy role - used only by SVC_TERRAFORM_CICD';

GRANT CREATE DATABASE  ON ACCOUNT TO ROLE TF_DEPLOY_ROLE;
GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE TF_DEPLOY_ROLE;
GRANT CREATE ROLE      ON ACCOUNT TO ROLE TF_DEPLOY_ROLE;
GRANT MANAGE GRANTS    ON ACCOUNT TO ROLE TF_DEPLOY_ROLE;  -- managed access + future grants
GRANT ROLE TF_DEPLOY_ROLE TO ROLE SYSADMIN;

-- 2. Small warehouse for Terraform
CREATE WAREHOUSE IF NOT EXISTS TF_DEPLOY_WH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE
  COMMENT = 'Warehouse for Terraform CI/CD';

GRANT USAGE ON WAREHOUSE TF_DEPLOY_WH TO ROLE TF_DEPLOY_ROLE;

-- 3. Service user (no password, no key pair)
CREATE USER IF NOT EXISTS SVC_TERRAFORM_CICD
  TYPE = SERVICE
  DEFAULT_ROLE = TF_DEPLOY_ROLE
  DEFAULT_WAREHOUSE = TF_DEPLOY_WH
  COMMENT = 'GitHub Actions Terraform service user (demo)';

GRANT ROLE TF_DEPLOY_ROLE TO USER SVC_TERRAFORM_CICD;

-- 4. Access tokens require the user to have a network policy.
--    GitHub runners use changing IPs, so for the DEMO this allows any IP
--    for this one user only. Tighten or remove after the demo.
CREATE NETWORK POLICY IF NOT EXISTS TF_DEMO_NETWORK_POLICY
  ALLOWED_IP_LIST = ('0.0.0.0/0')
  COMMENT = 'Demo only - lets GitHub Actions runners reach Snowflake';

ALTER USER SVC_TERRAFORM_CICD SET NETWORK_POLICY = TF_DEMO_NETWORK_POLICY;

-- 5. Generate the access token (valid 30 days, restricted to TF_DEPLOY_ROLE)
--    COPY the "token_secret" value from the result NOW - it is shown only once.
ALTER USER SVC_TERRAFORM_CICD
  ADD PROGRAMMATIC ACCESS TOKEN TF_DEMO_TOKEN
  ROLE_RESTRICTION = 'TF_DEPLOY_ROLE'
  DAYS_TO_EXPIRY = 30
  COMMENT = 'GitHub Actions Terraform demo';

-- 6. Values for the GitHub secrets
SELECT CURRENT_ORGANIZATION_NAME() AS SNOWFLAKE_ORGANIZATION_NAME,
       CURRENT_ACCOUNT_NAME()      AS SNOWFLAKE_ACCOUNT_NAME;

-- =====================================================================
-- AFTER THE DEMO - revoke access
-- =====================================================================
-- ALTER USER SVC_TERRAFORM_CICD REMOVE PROGRAMMATIC ACCESS TOKEN TF_DEMO_TOKEN;
-- ALTER USER SVC_TERRAFORM_CICD UNSET NETWORK_POLICY;
-- DROP NETWORK POLICY IF EXISTS TF_DEMO_NETWORK_POLICY;
