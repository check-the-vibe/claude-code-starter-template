# CLAUDE.md - Python Project

This file provides guidance to Claude Code when working with Python code in this repository.

## Project Overview

This is a Python project following modern Python development practices including virtual environments, testing, type hints, and code formatting.

### Key Components

The following files in the .vibe directory guide development:
- **PERSONA.md**: Python developer expertise and approach
- **TASKS.md**: Python-specific development workflow
- **ERRORS.md**: Common Python errors and solutions
- **LINKS.csv**: Python documentation and resources
- **LOG.txt**: Development history
- **ENVIRONMENT.md**: Python environment setup
- **docs/**: Project documentation

## Python Development Guidelines

### 1. Environment Setup
- Always work within a virtual environment
- Check Python version compatibility
- Verify all dependencies are in requirements.txt
- Use requirements-dev.txt for development dependencies

### 2. Code Style
- Follow PEP 8 strictly
- Use black for automatic formatting
- Add type hints to all function signatures
- Write descriptive docstrings for all public functions/classes

### 3. Testing
- Write tests before or alongside implementation
- Use pytest for all testing
- Aim for >80% code coverage
- Use fixtures for test data
- Mock external dependencies

### 4. Project Structure
```
src/
├── __init__.py
├── module1/
│   ├── __init__.py
│   └── core.py
└── module2/
    ├── __init__.py
    └── utils.py

tests/
├── __init__.py
├── test_module1/
│   └── test_core.py
└── test_module2/
    └── test_utils.py
```

## Development Commands

```bash
# Virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows

# Install dependencies
pip install -r requirements.txt
pip install -r requirements-dev.txt

# Run tests
pytest
pytest --cov=src  # with coverage
pytest -v         # verbose

# Code quality
black .           # format code
ruff check .      # lint code
mypy src/         # type check

# Documentation
sphinx-build -b html docs/ docs/_build/
```

## Python-Specific Reminders

### Import Organization
```python
# Standard library imports
import os
import sys
from typing import List, Optional

# Third-party imports
import numpy as np
import pandas as pd
from flask import Flask

# Local imports
from .module1 import function1
from .module2 import Class2
```

### Error Handling
```python
try:
    result = risky_operation()
except SpecificError as e:
    logger.error(f"Operation failed: {e}")
    raise
except Exception as e:
    logger.exception("Unexpected error")
    # Handle gracefully
finally:
    cleanup()
```

### Type Hints Example
```python
from typing import List, Dict, Optional, Union

def process_data(
    items: List[Dict[str, Any]], 
    filter_key: Optional[str] = None
) -> Union[List[str], None]:
    """Process data items and return filtered results.
    
    Args:
        items: List of dictionaries containing data
        filter_key: Optional key to filter by
        
    Returns:
        List of processed strings or None if no results
    """
    pass
```

## Important Python Patterns

1. **Context Managers**: Use for resource management
2. **Generators**: Use for memory-efficient iteration
3. **Decorators**: Use for cross-cutting concerns
4. **Dataclasses**: Use for data structures
5. **Pathlib**: Use for file path operations

## Security Considerations

- Never hardcode secrets or API keys
- Use environment variables for configuration
- Validate all user inputs
- Use parameterized queries for databases
- Keep dependencies updated

## Getting Started

1. Set up virtual environment
2. Install dependencies
3. Run tests to verify setup
4. Review existing code structure
5. Check TASKS.md for current objectives