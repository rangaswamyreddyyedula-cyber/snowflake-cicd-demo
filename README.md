# snowflake-cicd-demo

GitHub + Terraform CI/CD demo for Snowflake.

Creates TEST_CICD_DEMO_<ENV> with BRONZE, SILVER and GOLD managed access schemas,
read-only/read-write database roles, ENGINEER and ANALYST roles and a warehouse.

Branch flow:
- dev  : write code here (checks + plan against TEST, no deploy)
- test : merge dev -> test by pull request, deploys Snowflake TEST
- main : merge test -> main by pull request, deploys Snowflake PROD after approval
- tfstate : Terraform state, written only by the pipeline

Folders:
- terraform/          what gets built in Snowflake
- .github/ci/         checks run on push to dev and on pull requests
- .github/cd/         deployment steps
- .github/workflows/  triggers (GitHub only reads this folder)
- scripts/bootstrap/  one-time Snowflake setup and checks
