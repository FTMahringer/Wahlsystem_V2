---
sidebar_position: 5
---

# Development

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

## Notes

- The Maven wrapper batch file can fail when `JAVA_HOME` is missing, even if Java is installed globally.
- The backend test setup uses H2 for the test profile.
- `types-and-ideas.txt` is still kept as a backlog/reference document because it contains future election types that are not implemented yet.
