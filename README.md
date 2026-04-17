# Wahlsystem

School-focused election system with a Spring Boot backend and a Vue 3 frontend.

## Current status

The project now includes a working first implementation milestone for the election flow:

- aligned backend/frontend election types
- shared frontend wizard system
- election creation and editing wizard
- token-based voter login
- adaptive voter ballots
- type-aware result views
- admin user-management foundation with onboarding wizard support

## Implemented election types

- `SINGLE_CHOICE`
- `BINARY_CHOICE`
- `APPROVAL_VOTING`
- `LIMITED_VOTE`
- `BORDA_COUNT`

## Main user flows

### Admin / teacher

- log in
- create and edit elections through the wizard
- manage candidates
- review election results
- manage students and teachers from the admin users area
- onboard users with:
  - single create
  - bulk paste
  - CSV import

### Voter

- log in with a voting token
- open the assigned election
- submit a ballot that matches the election type
- confirm the vote

## Tech stack

### Frontend

- Vue 3
- TypeScript
- Vite
- Vue Router
- Pinia
- Axios

### Backend

- Java 25
- Spring Boot 4.0.5
- Spring Web
- Spring Data JPA
- Spring Security
- MariaDB
- Redis
- Flyway

## Project structure

```text
.
├── backend/     # Spring Boot API
├── frontend/    # Vue application
├── docker/      # Dev/prod Docker Compose setup
├── nginx/       # Reverse proxy config
├── scripts/     # Helper scripts
└── udpate-plan.txt
```

## Local development

### Frontend

```powershell
Set-Location .\frontend
npm install
npm run dev
```

### Backend

```powershell
Set-Location .\backend
java -classpath .mvn\wrapper\maven-wrapper.jar "-Dmaven.multiModuleProjectDirectory=$PWD" org.apache.maven.wrapper.MavenWrapperMain spring-boot:run
```

If `mvnw.cmd` does not work locally, set `JAVA_HOME` first or invoke the Maven wrapper JAR directly as shown above.

## Validation commands

### Frontend

```powershell
Set-Location .\frontend
npm run build
```

### Backend

```powershell
Set-Location .\backend
java -classpath .mvn\wrapper\maven-wrapper.jar "-Dmaven.multiModuleProjectDirectory=$PWD" org.apache.maven.wrapper.MavenWrapperMain test
```

## Notes

- `udpate-plan.txt` tracks the rollout and remaining work.
- Advanced election types like candidate pairs, dual-role elections, runoff variants, and score voting are still planned, not implemented yet.
