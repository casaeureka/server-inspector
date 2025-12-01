# Release Process

## Creating a Release

Releases are automated via GitHub Actions. To create a new release:

1. **Make changes and commit:**

   ```bash
   git add .
   git commit -m "feat: your changes"
   git push
   ```

2. **Create and push a version tag:**

   ```bash
   git tag v0.1.1  # Increment version number
   git push origin v0.1.1
   ```

3. **GitHub Actions will automatically:**
   - Package scripts with LICENSE and README.md in a tarball
   - Create a GitHub release
   - Upload `server-inspector-v0.1.1-linux.tar.gz` as release asset

## Updating Consumer Projects

After releasing, update version in projects that use this tool.

## Release Asset Format

Each release includes:

- `server-inspector-{version}-linux.tar.gz`
  - Script: `server_inspector.py`
  - `LICENSE`
  - `README.md`
