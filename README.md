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

### Dev-only login helper

When the backend is running in the `dev` profile, you can log in without a password through the dev helper endpoint:

```http
POST http://localhost:8080/api/v1/auth/dev-login
Content-Type: application/json

{
  "username": "admin"
}
```

This returns a normal auth response with access and refresh tokens for the existing user.

You can also use it directly in the browser:

```text
http://localhost:8080/api/v1/auth/dev-login?username=admin
```

The admin login page also shows dev-only buttons to:

- sign in directly as `admin`
- reset the default admin back to `admin / admin123` and sign in immediately

The reset endpoint is:

```http
POST http://localhost:8080/api/v1/auth/dev-reset-admin
```

Use it only for local development and testing.

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
