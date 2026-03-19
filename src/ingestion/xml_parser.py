"""XML parser for Apple Health data."""

import xml.etree.ElementTree as ET
from typing import Dict, List


def parse_step_count(xml_path: str) -> List[Dict[str, str]]:
    """Parse StepCount records from Apple Health export XML.

    Args:
        xml_path: Path to the Apple Health export.xml file

    Returns:
        List of dictionaries containing step count records with keys:
        - startDate: Start time of the record
        - endDate: End time of the record
        - value: Step count value

    Raises:
        FileNotFoundError: If XML file doesn't exist
        ET.ParseError: If XML is malformed
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
            step_record = {
                "startDate": record.get("startDate", ""),
                "endDate": record.get("endDate", ""),
                "value": record.get("value", ""),
            }
            step_count_records.append(step_record)

    return step_count_records
