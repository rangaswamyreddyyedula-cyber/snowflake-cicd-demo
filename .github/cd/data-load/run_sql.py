"""Runs every .sql file in snowflake/deploy (in name order) against one database.

Settings come from environment variables set by the workflow:
SNOWFLAKE_ORGANIZATION_NAME, SNOWFLAKE_ACCOUNT_NAME, SNOWFLAKE_USER,
SNOWFLAKE_PASSWORD (the access token), SNOWFLAKE_ROLE, SNOWFLAKE_WAREHOUSE,
TARGET_DATABASE (TEST_CICD_DEMO_TEST or TEST_CICD_DEMO_PROD).
"""
import glob
import os
import sys

import snowflake.connector

SQL_FOLDER = "snowflake/deploy"
COUNT_TABLES = [
    "BRONZE.EFRONT_FUNDS_RAW",
    "BRONZE.EFRONT_INVESTMENTS_RAW",
    "BRONZE.CHRONOGRAPH_VALUATIONS_RAW",
    "SILVER.DIM_FUND",
    "SILVER.DIM_PORTFOLIO_COMPANY",
    "SILVER.FACT_VALUATION",
]


def main() -> int:
    database = os.environ["TARGET_DATABASE"]
    files = sorted(glob.glob(os.path.join(SQL_FOLDER, "*.sql")))
    if not files:
        print(f"No .sql files found in {SQL_FOLDER}")
        return 1

    conn = snowflake.connector.connect(
        account=f'{os.environ["SNOWFLAKE_ORGANIZATION_NAME"]}-{os.environ["SNOWFLAKE_ACCOUNT_NAME"]}',
        user=os.environ["SNOWFLAKE_USER"],
        password=os.environ["SNOWFLAKE_PASSWORD"],
        role=os.environ["SNOWFLAKE_ROLE"],
        warehouse=os.environ["SNOWFLAKE_WAREHOUSE"],
        database=database,
        session_parameters={"QUERY_TAG": "github-actions-data-load"},
    )
    try:
        print(f"Connected. Target database: {database}")
        for path in files:
            print(f"::group::{path}")
            with open(path, encoding="utf-8") as f:
                sql = f.read()
            for cur in conn.execute_string(sql, remove_comments=True):
                print(f"OK  query id {cur.sfqid}  rows {cur.rowcount}")
            print("::endgroup::")

        lines = [f"## Data load - {database}", "", "| Table | Rows |", "| --- | --- |"]
        cur = conn.cursor()
        for table in COUNT_TABLES:
            count = cur.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
            print(f"{table}: {count} rows")
            lines.append(f"| {table} | {count} |")
        summary = os.environ.get("GITHUB_STEP_SUMMARY")
        if summary:
            with open(summary, "a", encoding="utf-8") as f:
                f.write("\n".join(lines) + "\n")
    finally:
        conn.close()
    return 0


if __name__ == "__main__":
    sys.exit(main())
