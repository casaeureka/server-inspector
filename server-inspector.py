#!/usr/bin/env python3
"""
Server Inspector
Automatically detects and inventories hardware for server

Usage:
  sudo python3 server-inspector.py [--output FILE]

Requirements:
  - Must run as root for full hardware access
"""

# Import and run from the src package
from src.main import main

if __name__ == "__main__":
    main()
