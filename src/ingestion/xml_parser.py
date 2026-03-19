"""XML parser for Apple Health data."""

import logging
import xml.etree.ElementTree as ET
from typing import Dict, List, Optional, Tuple

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Record types we support
SUPPORTED_RECORD_TYPES = {
    "HKQuantityTypeIdentifierStepCount",
    "HKQuantityTypeIdentifierHeartRate",
    "HKCategoryTypeIdentifierSleepAnalysis",
}


def parse_step_count(
    xml_path: str,
) -> Tuple[List[Dict[str, str]], Dict[str, int]]:
    """Parse StepCount records from Apple Health export XML.

    Args:
        xml_path: Path to the Apple Health export.xml file

    Returns:
        A tuple of:
        - List of dictionaries containing step count records
        - Statistics dictionary

    Note:
        Deprecated: Use parse_records() instead for multi-type support.
    """
    return parse_records(xml_path, record_type="HKQuantityTypeIdentifierStepCount")


def parse_records(
    xml_path: str,
    record_type: Optional[str] = None,
) -> Tuple[List[Dict[str, str]], Dict[str, int]]:
    """Parse health records from Apple Health export XML.

    Args:
        xml_path: Path to the Apple Health export.xml file
        record_type: Optional filter for specific record type.
                     If None, parses all supported types.

    Returns:
        A tuple of:
        - List of dictionaries containing health records with keys:
          - type: Record type (e.g., "HKQuantityTypeIdentifierStepCount")
          - startDate: Start time (required)
          - endDate: End time (required)
          - value: Value (required)
        - Statistics dictionary with keys:
          - total_records: Total records encountered
          - parsed_records: Records successfully parsed
          - skipped_records: Records skipped due to missing fields

    Raises:
        FileNotFoundError: If XML file doesn't exist
        ET.ParseError: If XML is malformed

    Note:
        Records with missing required fields are skipped to preserve
        data integrity (INV-1). Skip statistics are logged for observability.
    """
    records = []
    total_records = 0
    skipped_records = 0

    # Parse XML (INV-1: we read but don't modify original file)
    tree = ET.parse(xml_path)
    root = tree.getroot()

    # Determine which types to parse
    types_to_parse = (
        [record_type] if record_type else SUPPORTED_RECORD_TYPES
    )

    # Find all Record elements
    for record_elem in root.findall(".//Record"):
        elem_type = record_elem.get("type")

        # Filter for desired record types
        if elem_type not in types_to_parse:
            continue

        total_records += 1

        # Extract required fields - do NOT use defaults (INV-1)
        rec_type: Optional[str] = elem_type
        start_date: Optional[str] = record_elem.get("startDate")
        end_date: Optional[str] = record_elem.get("endDate")
        value: Optional[str] = record_elem.get("value")

        # Skip records with missing required fields (data integrity)
        if None in (rec_type, start_date, end_date, value):
            skipped_records += 1
            continue

        # Type narrowing
        assert rec_type is not None
        assert start_date is not None
        assert end_date is not None
        assert value is not None

        # All fields present - create record with definite str types
        record: Dict[str, str] = {
            "type": rec_type,
            "startDate": start_date,
            "endDate": end_date,
            "value": value,
        }
        records.append(record)

    # Log statistics for observability (no silent data loss)
    stats = {
        "total_records": total_records,
        "parsed_records": len(records),
        "skipped_records": skipped_records,
    }

    type_filter = f" ({record_type})" if record_type else ""
    logger.info(
        f"Record parsing{type_filter} complete: "
        f"{stats['parsed_records']}/{stats['total_records']} records parsed, "
        f"{stats['skipped_records']} skipped"
    )

    return records, stats
