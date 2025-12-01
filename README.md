# server-inspector

Hardware detection and inventory tool.

## Purpose

Automatically detects and inventories  hardware:

- CPU information
- Memory configuration
- Storage devices (disks, NVMe, etc.)
- Network interfaces
- System capabilities

## Features

- Complete hardware inventory
- YAML output format
- Works well with [live-usb-helper](https://github.com/casaeureka/live-usb-helper)

## Usage

```bash
# Basic inspection (outputs to stdout)
sudo python3 server_inspector.py

# Save to file
sudo python3 server_inspector.py --output hardware.yml
```

## Requirements

- Must run as root for full hardware access
- Python 3.10+

## License

GPLv3 - See [LICENSE](LICENSE)
