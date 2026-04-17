---
sidebar_position: 10
---

# Deployment

## Documentation deployment

The documentation site is deployed through GitHub Actions and GitHub Pages.

Repository workflow:

- `.github/workflows/docs-pages.yml`

The workflow:

1. checks out the repository
2. installs website dependencies
3. builds the Docusaurus site
4. uploads the static site artifact
5. deploys it to GitHub Pages

## Application deployment areas

The repository already contains deployment-related directories:

- `docker/`
- `nginx/`
- `scripts/`

These are the main starting points for local and container-based startup.

## Local development deployment

For local development, the recommended path is:

```powershell
Copy-Item .\docker\dev\.env.example .\docker\dev\.env
.\scripts\start-dev.ps1
```

## Notes

- the backend Docker startup now uses the Maven wrapper JAR directly inside the container
- this avoids fragile script execution behavior on fresh Windows clones
- GitHub Pages still needs to be enabled in repository settings if it is not already active
