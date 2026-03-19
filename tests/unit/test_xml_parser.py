"""Unit tests for XML parser."""

import pytest

from src.ingestion.xml_parser import parse_step_count


def test_parse_step_count_returns_list():
    """Test that parse_step_count returns a list."""
    # Using real data file for minimal test
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
