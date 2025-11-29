#!/usr/bin/env bash
set -e

errors=0
warnings=0

# Check for common hardcoded constants
if git diff --cached --name-only | grep '\.py$' | xargs grep -nE '"localhost"|"127\.0\.0\.1"|:8080|:3000|:5000' 2>/dev/null; then
  echo "❌ Found hardcoded network constant. Define in config or constants module"
  errors=1
fi

# Check for insecure subprocess calls with shell=True (security risk)
if git diff --cached --name-only | grep '\.py$' | xargs grep -nE '\bsubprocess\.(run|call|Popen)\([^)]*shell=True' 2>/dev/null; then
  echo "❌ Found subprocess call with shell=True (security risk)"
  echo "   Use subprocess.run() with argument list instead"
  echo "   shell=True is vulnerable to shell injection"
  errors=1
fi

# Check for insecure os.system() calls (should use subprocess)
if git diff --cached --name-only | grep '\.py$' | xargs grep -nE '\bos\.system\(' 2>/dev/null; then
  echo "❌ Found os.system() call (security risk)"
  echo "   Use subprocess.run() instead for proper error handling and output capture"
  echo "   os.system() vulnerable to shell injection"
  errors=1
fi

# File size check (warning at 400, error at 500 lines)
for file in $(git diff --cached --name-only | grep '\.py$' | grep -v '^tests/'); do
  if [ -f "$file" ]; then
    lines=$(wc -l < "$file")
    if [ "$lines" -ge 500 ]; then
      echo "❌ File too large: $file ($lines lines, max 500)"
      echo "   Split into smaller modules (<400 lines)"
      errors=1
    elif [ "$lines" -ge 400 ]; then
      echo "⚠️  File approaching size limit: $file ($lines lines, recommend <400)"
      warnings=1
    fi
  fi
done

# Async naming convention
for file in $(git diff --cached --name-only | grep '\.py$' | grep -v '^tests/'); do
  if [ -f "$file" ]; then
    # Check if file contains async def but is not named async_*.py
    if grep -q 'async def' "$file" && ! echo "$file" | grep -q '/async_.*\.py$'; then
      echo "❌ Async code in non-async file: $file"
      echo "   Files with 'async def' must be named async_*.py"
      errors=1
    fi

    # Check if async_*.py file uses requests library
    if echo "$file" | grep -q '/async_.*\.py$' && grep -q 'import requests\|from requests' "$file"; then
      echo "❌ Sync library in async file: $file"
      echo "   async_*.py files must not use requests library"
      errors=1
    fi
  fi
done

# Exception hierarchy (block bare raise Exception, require re-raise in except Exception)
for file in $(git diff --cached --name-only | grep '\.py$' | grep -v '^tests/'); do
  if [ -f "$file" ]; then
    # Check for bare raise Exception()
    if grep -qE 'raise Exception\(' "$file"; then
      echo "❌ Bare raise Exception() in: $file"
      echo "   Use custom exception classes instead"
      errors=1
    fi

    # Check for except Exception: without re-raise
    if grep -n 'except Exception:' "$file" >/dev/null 2>&1; then
      if ! python3 <<EOF
import sys
import re

with open("$file", "r") as f:
    lines = f.readlines()

for i, line in enumerate(lines, 1):
    if "except Exception:" in line and not line.strip().startswith("#"):
        # Check if line has intentional suppression comment
        if "Intentional exception suppression" in line:
            continue

        # Get indentation level
        indent = len(line) - len(line.lstrip())
        # Check next 15 lines for raise at same or deeper indent
        has_raise = False
        for j in range(i, min(i+15, len(lines))):
            next_line = lines[j]
            next_indent = len(next_line) - len(next_line.lstrip())
            # If we're back to same or lower indent (end of except block), stop
            if j > i and next_indent <= indent and next_line.strip():
                break
            if "raise" in next_line and next_indent > indent and not next_line.strip().startswith("#"):
                has_raise = True
                break
        if not has_raise:
            print(f"❌ except Exception: without re-raise at line {i}: $file")
            print("   Must include 'raise' to re-raise exception after handling")
            sys.exit(1)
EOF
      then
        errors=1
      fi
    fi
  fi
done

if [ "$warnings" -eq 1 ]; then
  echo ""
  echo "⚠️  Warnings found (non-blocking)"
fi

exit $errors
