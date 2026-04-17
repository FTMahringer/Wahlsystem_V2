---
sidebar_position: 2
---

# Getting started

## Repository structure

```text
.
├── backend/
├── frontend/
├── website/
├── docker/
├── nginx/
├── scripts/
└── udpate-plan.txt
```

## Standard development startup

```powershell
Copy-Item .\docker\dev\.env.example .\docker\dev\.env
.\scripts\start-dev.ps1
```

This is the default path for local development. It starts the Docker-based stack from the repository scripts.

### What the script does

`.\scripts\start-dev.ps1`:

- checks that backend and frontend directories exist
- checks that `docker\dev\.env` exists
- starts the development Docker Compose stack
- brings up frontend, backend, MariaDB, phpMyAdmin, Redis, and Redis Commander

Default local URLs:

- `http://localhost:5173`
- `http://localhost:8080/api/v1`
- `http://localhost:8081`
- `http://localhost:8082`

### Recommended stop command

Use the repository stop script when you want to shut the stack down.

```powershell
.\scripts\stop.ps1
```

<details>
<summary>Alternative: run frontend and backend directly on the host</summary>

## Frontend

```powershell
Set-Location .\frontend
npm install
npm run dev
```

Default local URL:

- `http://localhost:5173`

## Backend

```powershell
Set-Location .\backend
java -classpath .mvn\wrapper\maven-wrapper.jar "-Dmaven.multiModuleProjectDirectory=F:\projects\Wahl\backend" org.apache.maven.wrapper.MavenWrapperMain spring-boot:run
```

Default local API base:

- `http://localhost:8080/api/v1`

If `mvnw.cmd` does not work, set `JAVA_HOME` or invoke the Maven wrapper JAR directly.

</details>

## Documentation site

```powershell
Set-Location .\website
npm install
npm start
```

This runs the Docusaurus site locally so you can preview documentation changes before pushing them.

## Environment notes

- the default workflow is Docker-first
- direct host startup is mainly useful for debugging or development without containers
- backend Maven wrapper calls are more reliable through the wrapper JAR when `JAVA_HOME` is missing on Windows
- GitHub Pages deployment is handled by repository workflow automation

## Dev-only login helper

When the backend runs with the `dev` profile, a dev-only helper endpoint is available:

```text
POST /api/v1/auth/dev-login
```

Example body:

```json
{
  "username": "admin"
}
```

This issues a normal auth token for an existing user without requiring a password.

Browser-friendly variant:

```text
/api/v1/auth/dev-login?username=admin
```

The admin login page also shows dev-only helper buttons for:

- signing in directly as `admin`
- resetting the default admin back to `admin / admin123`

The reset endpoint is:

```text
POST /api/v1/auth/dev-reset-admin
```

Important notes:

- this endpoint exists only in the `dev` profile
- it is intended only for local development and testing
- it does not replace the normal production login flow

## Validation

### Frontend

```powershell
Set-Location .\frontend
npm run build
```

### Backend

```powershell
Set-Location .\backend
java -classpath .mvn\wrapper\maven-wrapper.jar "-Dmaven.multiModuleProjectDirectory=F:\projects\Wahl\backend" org.apache.maven.wrapper.MavenWrapperMain test
```

### Docs

```powershell
Set-Location .\website
npm run build
```
