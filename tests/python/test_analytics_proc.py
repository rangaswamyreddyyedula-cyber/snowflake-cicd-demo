"""Unit tests for snowflake/procedures/analytics_proc.py (run in the pull request checks)."""
import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[2] / "snowflake" / "procedures"))

from analytics_proc import summarise  # noqa: E402

ROWS = [
    {"FUND_NAME": "Fund A", "CURRENCY": "GBP", "INVESTMENTS": 3, "TOTAL_INVESTED": 100.0, "TOTAL_FAIR_VALUE": 150.0},
    {"FUND_NAME": "Fund B", "CURRENCY": "GBP", "INVESTMENTS": 2, "TOTAL_INVESTED": 100.0, "TOTAL_FAIR_VALUE": 90.0},
    {"FUND_NAME": "Fund C", "CURRENCY": "EUR", "INVESTMENTS": 1, "TOTAL_INVESTED": 50.0, "TOTAL_FAIR_VALUE": 75.0},
]


def test_totals():
    result = summarise(ROWS)
    assert result["funds"] == 3
    assert result["investments"] == 6


def test_moic_by_currency():
    result = summarise(ROWS)
    assert result["by_currency"]["GBP"]["moic"] == 1.2
    assert result["by_currency"]["EUR"]["moic"] == 1.5


def test_empty_input():
    assert summarise([]) == {"funds": 0, "investments": 0, "by_currency": {}}


def test_zero_invested_gives_no_moic():
    rows = [{"FUND_NAME": "X", "CURRENCY": "USD", "INVESTMENTS": 0, "TOTAL_INVESTED": 0, "TOTAL_FAIR_VALUE": 0}]
    assert summarise(rows)["by_currency"]["USD"]["moic"] is None
