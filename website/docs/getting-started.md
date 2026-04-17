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

## Documentation site

```powershell
Set-Location .\website
npm install
npm start
```

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
