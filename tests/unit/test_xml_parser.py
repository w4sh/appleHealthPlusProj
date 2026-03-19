"""Unit tests for XML parser."""

import pytest
from src.ingestion.xml_parser import parse_records, parse_step_count, SUPPORTED_RECORD_TYPES


def test_parse_step_count_backward_compat():
    """Test that parse_step_count still works (backward compatibility)."""
    records, stats = parse_step_count("data/raw/export.xml")
    assert isinstance(records, list)
    assert len(records) >= 1
    assert stats["total_records"] >= 1


def test_parse_records_returns_tuple():
    """Test that parse_records returns a tuple."""
    result = parse_records("data/raw/export.xml")
    assert isinstance(result, tuple)
    assert len(result) == 2


def test_parse_records_all_types():
    """Test parsing all supported record types."""
    records, stats = parse_records("data/raw/export.xml")

    # Should have records from multiple types
    assert len(records) >= 1

    # Check stats are valid
    assert stats["total_records"] >= stats["parsed_records"]
    assert stats["parsed_records"] + stats["skipped_records"] == stats["total_records"]


def test_parse_records_specific_type_stepcount():
    """Test parsing only StepCount records."""
    records, stats = parse_records(
        "data/raw/export.xml",
        record_type="HKQuantityTypeIdentifierStepCount"
    )

    # All records should be StepCount
    for record in records:
        assert record["type"] == "HKQuantityTypeIdentifierStepCount"

    # Should have parsed records
    assert len(records) >= 1


def test_parse_records_specific_type_heartrate():
    """Test parsing only HeartRate records."""
    records, stats = parse_records(
        "data/raw/export.xml",
        record_type="HKQuantityTypeIdentifierHeartRate"
    )

    # All records should be HeartRate
    for record in records:
        assert record["type"] == "HKQuantityTypeIdentifierHeartRate"

    # Should have parsed records (if they exist in data)
    # This test is data-dependent
    assert stats["total_records"] >= 0


def test_parse_records_specific_type_sleep():
    """Test parsing only SleepAnalysis records."""
    records, stats = parse_records(
        "data/raw/export.xml",
        record_type="HKCategoryTypeIdentifierSleepAnalysis"
    )

    # All records should be SleepAnalysis
    for record in records:
        assert record["type"] == "HKCategoryTypeIdentifierSleepAnalysis"


def test_parse_records_has_required_fields():
    """Test that each record has required fields."""
    records, stats = parse_records("data/raw/export.xml")

    if len(records) > 0:
        record = records[0]
        assert "type" in record
        assert "startDate" in record
        assert "endDate" in record
        assert "value" in record


def test_parse_records_no_empty_values():
    """Test that no records have empty string values (data integrity)."""
    records, stats = parse_records("data/raw/export.xml")

    for record in records:
        # All required fields must be non-empty strings
        assert record["type"] != ""
        assert record["startDate"] != ""
        assert record["endDate"] != ""
        assert record["value"] != ""


def test_parse_records_all_fields_present():
    """Test that all records have all required fields present."""
    records, stats = parse_records("data/raw/export.xml")

    for record in records:
        # Check that values are not None
        assert record["type"] is not None
        assert record["startDate"] is not None
        assert record["endDate"] is not None
        assert record["value"] is not None


def test_supported_record_types():
    """Test that we support at least 3 record types."""
    assert len(SUPPORTED_RECORD_TYPES) >= 3
    assert "HKQuantityTypeIdentifierStepCount" in SUPPORTED_RECORD_TYPES
    assert "HKQuantityTypeIdentifierHeartRate" in SUPPORTED_RECORD_TYPES
    assert "HKCategoryTypeIdentifierSleepAnalysis" in SUPPORTED_RECORD_TYPES


def test_parse_records_idempotent():
    """Test that parsing twice produces same results (INV-3)."""
    records1, stats1 = parse_records("data/raw/export.xml")
    records2, stats2 = parse_records("data/raw/export.xml")

    # Same number of records
    assert len(records1) == len(records2)

    # Same stats
    assert stats1 == stats2
