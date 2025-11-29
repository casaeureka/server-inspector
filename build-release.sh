#!/usr/bin/env bash
# Build script to create single-file executable using zipapp
set -euo pipefail

# Clean previous build
rm -rf build/
mkdir -p build

# Copy src/ to build directory
cp -r src build/

# Create __main__.py that imports and runs main()
cat > build/__main__.py << 'EOF'
#!/usr/bin/env python3
"""
Server Hardware Inspector
Automatically detects and inventories hardware for home server deployment

Usage:
  sudo python3 server-inspector.py [--output FILE]

Requirements:
  - Must run as root for full hardware access
  - Run in Proxmox installer environment (boot from USB created with live-usb-helper)
"""

from src.main import main

if __name__ == "__main__":
    main()
EOF

# Create the zipapp
python3 -m zipapp build -o server-inspector.pyz -p "/usr/bin/env python3"

# Make it executable
chmod +x server-inspector.pyz

echo "✅ Built: server-inspector.pyz"
ls -lh server-inspector.pyz
