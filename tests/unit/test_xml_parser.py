"""Unit tests for XML parser."""

import pytest
from src.ingestion.xml_parser import parse_step_count


def test_parse_step_count_returns_list():
    """Test that parse_step_count returns a list."""
    result = parse_step_count("data/raw/export.xml")
    assert isinstance(result, list)


def test_parse_step_count_has_required_fields():
    """Test that each record has required fields."""
    result = parse_step_count("data/raw/export.xml")

    if len(result) > 0:
        record = result[0]
        assert "startDate" in record
        assert "endDate" in record
        assert "value" in record


def test_parse_step_count_extracts_at_least_one_record():
    """Test that at least one StepCount record is extracted."""
    result = parse_step_count("data/raw/export.xml")
    assert len(result) >= 1


def test_parse_step_count_no_empty_values():
    """Test that no records have empty string values (data integrity)."""
    result = parse_step_count("data/raw/export.xml")

    for record in result:
        # All required fields must be non-empty strings
        assert record["startDate"] != ""
        assert record["endDate"] != ""
        assert record["value"] != ""


def test_parse_step_count_all_fields_present():
    """Test that all records have all required fields present."""
    result = parse_step_count("data/raw/export.xml")

    for record in result:
        # Check that values are not None
        assert record["startDate"] is not None
        assert record["endDate"] is not None
        assert record["value"] is not None
