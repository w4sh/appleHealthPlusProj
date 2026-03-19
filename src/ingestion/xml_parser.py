"""XML parser for Apple Health data."""

import logging
import xml.etree.ElementTree as ET
from typing import Dict, List, Optional, Tuple

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def parse_step_count(
    xml_path: str,
) -> Tuple[List[Dict[str, str]], Dict[str, int]]:
    """Parse StepCount records from Apple Health export XML.

    Args:
        xml_path: Path to the Apple Health export.xml file

    Returns:
        A tuple of:
        - List of dictionaries containing step count records with keys:
          - startDate: Start time of the record (required)
          - endDate: End time of the record (required)
          - value: Step count value (required)
        - Statistics dictionary with keys:
          - total_records: Total StepCount records encountered
          - parsed_records: Records successfully parsed
          - skipped_records: Records skipped due to missing fields

    Raises:
        FileNotFoundError: If XML file doesn't exist
        ET.ParseError: If XML is malformed

    Note:
        Records with missing required fields are skipped to preserve
        data integrity (INV-1). Skip statistics are logged for observability.
    """
    step_count_records = []
    total_records = 0
    skipped_records = 0

    # Parse XML (INV-1: we read but don't modify original file)
    tree = ET.parse(xml_path)
    root = tree.getroot()

    # Find all Record elements
    for record in root.findall(".//Record"):
        record_type = record.get("type")

        # Filter for StepCount records
        if record_type == "HKQuantityTypeIdentifierStepCount":
            total_records += 1

            # Extract required fields - do NOT use defaults (INV-1)
            start_date: Optional[str] = record.get("startDate")
            end_date: Optional[str] = record.get("endDate")
            value: Optional[str] = record.get("value")

            # Skip records with missing required fields (data integrity)
            if None in (start_date, end_date, value):
                skipped_records += 1
                # Skip invalid records rather than inserting fake data
                continue

            # Type narrowing: we know all values are non-None here
            # Use assert to help mypy understand the type narrowing
            assert start_date is not None
            assert end_date is not None
            assert value is not None

            # All fields present - create record with definite str types
            step_record: Dict[str, str] = {
                "startDate": start_date,
                "endDate": end_date,
                "value": value,
            }
            step_count_records.append(step_record)

    # Log statistics for observability (no silent data loss)
    stats = {
        "total_records": total_records,
        "parsed_records": len(step_count_records),
        "skipped_records": skipped_records,
    }

    logger.info(
        f"StepCount parsing complete: "
        f"{stats['parsed_records']}/{stats['total_records']} records parsed, "
        f"{stats['skipped_records']} skipped"
    )

    return step_count_records, stats
