"""Handler for the stored procedure GOLD.SP_FUND_SUMMARY.

The file lives in GitHub. Snowflake reads it through the native Git repository
(IMPORTS = '@<DB>.INTEGRATIONS.GITHUB_REPO/branches/<branch>/snowflake/procedures/analytics_proc.py'),
so the Python code is versioned and promoted dev -> test -> main like the SQL.

summarise() holds the business logic and has no Snowflake dependency,
so it is unit tested in the pull request checks (tests/python).
"""


def summarise(rows):
    """Portfolio totals from rows of GOLD.V_FUND_PERFORMANCE.

    rows: list of dicts with FUND_NAME, CURRENCY, INVESTMENTS,
          TOTAL_INVESTED and TOTAL_FAIR_VALUE.
    Returns a dict that is safe to return as a VARIANT.
    """
    by_currency = {}
    for r in rows:
        c = by_currency.setdefault(
            r["CURRENCY"], {"funds": 0, "investments": 0, "invested": 0.0, "fair_value": 0.0}
        )
        c["funds"] += 1
        c["investments"] += int(r["INVESTMENTS"] or 0)
        c["invested"] += float(r["TOTAL_INVESTED"] or 0)
        c["fair_value"] += float(r["TOTAL_FAIR_VALUE"] or 0)

    for c in by_currency.values():
        c["moic"] = round(c["fair_value"] / c["invested"], 2) if c["invested"] else None

    return {
        "funds": sum(c["funds"] for c in by_currency.values()),
        "investments": sum(c["investments"] for c in by_currency.values()),
        "by_currency": by_currency,
    }


def main(session):
    """Stored procedure entry point (HANDLER = 'analytics_proc.main')."""
    rows = [
        r.as_dict()
        for r in session.table("GOLD.V_FUND_PERFORMANCE")
        .select("FUND_NAME", "CURRENCY", "INVESTMENTS", "TOTAL_INVESTED", "TOTAL_FAIR_VALUE")
        .collect()
    ]
    return summarise(rows)
