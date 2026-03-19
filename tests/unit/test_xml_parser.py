"""Unit tests for XML parser."""

import pytest
from src.ingestion.xml_parser import parse_step_count


def test_parse_step_count_returns_tuple():
    """Test that parse_step_count returns a tuple."""
    result = parse_step_count("data/raw/export.xml")
    assert isinstance(result, tuple)
    assert len(result) == 2


def test_parse_step_count_returns_list():
    """Test that parse_step_count returns a list as first element."""
    records, stats = parse_step_count("data/raw/export.xml")
    assert isinstance(records, list)


def test_parse_step_count_returns_stats():
    """Test that parse_step_count returns statistics."""
    records, stats = parse_step_count("data/raw/export.xml")
    assert isinstance(stats, dict)
    assert "total_records" in stats
    assert "parsed_records" in stats
    assert "skipped_records" in stats


def test_parse_step_count_stats_are_integers():
    """Test that statistics are integers."""
    records, stats = parse_step_count("data/raw/export.xml")
    assert isinstance(stats["total_records"], int)
    assert isinstance(stats["parsed_records"], int)
    assert isinstance(stats["skipped_records"], int)


def test_parse_step_count_stats_sum_correctly():
    """Test that parsed + skipped = total."""
    records, stats = parse_step_count("data/raw/export.xml")
    assert stats["parsed_records"] + stats["skipped_records"] == stats["total_records"]


def test_parse_step_count_has_required_fields():
    """Test that each record has required fields."""
    records, stats = parse_step_count("data/raw/export.xml")

    if len(records) > 0:
        record = records[0]
        assert "startDate" in record
        assert "endDate" in record
        assert "value" in record


def test_parse_step_count_extracts_at_least_one_record():
    """Test that at least one StepCount record is extracted."""
    records, stats = parse_step_count("data/raw/export.xml")
    assert len(records) >= 1


def test_parse_step_count_no_empty_values():
    """Test that no records have empty string values (data integrity)."""
    records, stats = parse_step_count("data/raw/export.xml")

    for record in records:
        # All required fields must be non-empty strings
        assert record["startDate"] != ""
        assert record["endDate"] != ""
        assert record["value"] != ""


def test_parse_step_count_all_fields_present():
    """Test that all records have all required fields present."""
    records, stats = parse_step_count("data/raw/export.xml")

    for record in records:
        # Check that values are not None
        assert record["startDate"] is not None
        assert record["endDate"] is not None
        assert record["value"] is not None
