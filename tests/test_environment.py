import sys

import credit_intelligence


def test_project_uses_python_312() -> None:
    assert sys.version_info[:2] == (3, 12)


def test_package_is_importable() -> None:
    assert credit_intelligence.__name__ == "credit_intelligence"
