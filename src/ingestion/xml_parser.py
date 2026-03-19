"""XML parser for Apple Health data."""

import xml.etree.ElementTree as ET
from typing import Dict, List, Optional


def parse_step_count(xml_path: str) -> List[Dict[str, str]]:
    """Parse StepCount records from Apple Health export XML.

    Args:
        xml_path: Path to the Apple Health export.xml file

    Returns:
        List of dictionaries containing step count records with keys:
        - startDate: Start time of the record (required)
        - endDate: End time of the record (required)
        - value: Step count value (required)

    Raises:
        FileNotFoundError: If XML file doesn't exist
        ET.ParseError: If XML is malformed

    Note:
        Records with missing required fields are skipped to preserve
        data integrity (INV-1).
    """
    step_count_records = []

    # Parse XML (INV-1: we read but don't modify original file)
    tree = ET.parse(xml_path)
    root = tree.getroot()

    # Find all Record elements
    for record in root.findall(".//Record"):
        record_type = record.get("type")

        # Filter for StepCount records
        if record_type == "HKQuantityTypeIdentifierStepCount":
            # Extract required fields - do NOT use defaults (INV-1)
            start_date: Optional[str] = record.get("startDate")
            end_date: Optional[str] = record.get("endDate")
            value: Optional[str] = record.get("value")

            # Skip records with missing required fields (data integrity)
            if None in (start_date, end_date, value):
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

    return step_count_records
