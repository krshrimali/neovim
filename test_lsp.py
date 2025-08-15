#!/usr/bin/env python3
"""Test file for LSP configuration."""

import os
import sys
from typing import List, Optional


def greet(name: str) -> str:
    """Greet a person by name."""
    return f"Hello, {name}!"


def process_numbers(numbers: List[int]) -> Optional[float]:
    """Process a list of numbers and return their average."""
    if not numbers:
        return None
    
    # This line has a deliberate error for testing diagnostics
    total = sum(numbers)
    average = total / len(numbers)
    return average


def main() -> None:
    """Main function."""
    name = "World"
    greeting = greet(name)
    print(greeting)
    
    # Test with some numbers
    test_numbers = [1, 2, 3, 4, 5]
    avg = process_numbers(test_numbers)
    
    if avg is not None:
        print(f"Average: {avg:.2f}")
    
    # This will cause a type error for testing
    result = process_numbers("not a list")  # Type error here
    print(f"Result: {result}")


if __name__ == "__main__":
    main()