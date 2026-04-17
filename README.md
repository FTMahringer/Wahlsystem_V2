# Wahlsystem

School-focused election system with a Spring Boot backend, a Vue 3 frontend, and a Docusaurus documentation site.

## Documentation

Project documentation now lives in the Docusaurus site under `website/`.

```powershell
Set-Location .\website
npm install
npm start
```

The published target is GitHub Pages for `FTMahringer/Wahlsystem_V2`.

## Quick start

Use the repository startup script as the default development path:

```powershell
Copy-Item .\docker\dev\.env.example .\docker\dev\.env
.\scripts\start-dev.ps1
```

This starts the Docker-based development stack, including frontend, backend, database, and Redis.

<details>
<summary>Alternative: run frontend and backend directly on the host</summary>

### Frontend

```powershell
Set-Location .\frontend
npm install
npm run dev
```

### Backend

```powershell
Set-Location .\backend
java -classpath .mvn\wrapper\maven-wrapper.jar "-Dmaven.multiModuleProjectDirectory=F:\projects\Wahl\backend" org.apache.maven.wrapper.MavenWrapperMain spring-boot:run
```

</details>

## Current implementation

- election creation/edit wizard
- token-based voter login
- single-choice, binary, approval, limited-vote, and Borda-count elections
- admin user management
- student/teacher onboarding wizard

## Planning

- rollout and remaining work: `udpate-plan.txt`
- election-idea backlog: `types-and-ideas.txt`
