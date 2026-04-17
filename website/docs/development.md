---
sidebar_position: 5
---

# Development

## Development workflow

The default development path is script-driven and Docker-based:

1. copy `docker\dev\.env.example` to `docker\dev\.env`
2. run `.\scripts\start-dev.ps1`
3. make code or docs changes
4. run the relevant build or test command
5. stop the environment with the repository stop script

## Dev-only auth helper

For faster local testing, the backend now exposes a dev-profile-only helper endpoint:

```text
POST /api/v1/auth/dev-login
```

Send a username in the request body and the backend returns a normal auth response with access and refresh tokens.

Example:

```json
{
  "username": "admin"
}
```

For quick browser testing, you can also open:

```text
/api/v1/auth/dev-login?username=admin
```

The admin login page also exposes dev-only helper buttons so you can sign in as the default admin or reset that admin account without using the browser console.

The backend reset endpoint is:

```text
POST /api/v1/auth/dev-reset-admin
```

This is intentionally limited to the `dev` profile so password storage and the normal login flow stay unchanged.

## Frontend stack

- Vue 3
- TypeScript
- Vite
- Vue Router
- Pinia
- Axios

## Backend stack

- Java 25
- Spring Boot 4.0.5
- Spring Security
- Spring Data JPA
- MariaDB
- Redis
- Flyway

## Main code areas

The current codebase is split into three main working areas:

- `backend\` for Spring Boot APIs, security, entities, services, and persistence
- `frontend\` for the Vue admin and voter application
- `website\` for Docusaurus documentation

## Key implementation areas

### Frontend

- `frontend/src/components/common/wizard/`
- `frontend/src/composables/useWizard.ts`
- `frontend/src/views/admin/AdminElectionFormView.vue`
- `frontend/src/views/admin/AdminUsersView.vue`
- `frontend/src/views/voter/VoterElectionView.vue`
- `frontend/src/views/voter/VoteConfirmView.vue`

### Backend

- `backend/src/main/java/at/ftmahringer/wahlsystem/controller/`
- `backend/src/main/java/at/ftmahringer/wahlsystem/service/ElectionService.java`
- `backend/src/main/java/at/ftmahringer/wahlsystem/service/VotingService.java`
- `backend/src/main/java/at/ftmahringer/wahlsystem/service/UserManagementService.java`

## Validation commands

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

## Notes

- The Maven wrapper batch file can fail when `JAVA_HOME` is missing, even if Java is installed globally.
- The Docker backend startup was hardened to call the wrapper JAR directly inside the container instead of relying on shell execution of `mvnw`.
- The backend test setup uses H2 for the test profile.
- `types-and-ideas.txt` is still kept as a backlog/reference document because it contains future election types that are not implemented yet.
