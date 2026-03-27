# Wahlsystem Backend Plan

## Goal

The backend should provide a clean, secure, and easy to maintain API for the election system.

It should:

- manage elections
- manage candidates
- manage voters / tokens / authentication
- store and validate votes
- provide results
- separate public, voter, and admin features clearly

---

## Main Tech Stack

- **Java 25**
- **Spring Boot**
- **Spring Web**
- **Spring Data JPA**
- **Spring Security**
- **MariaDB** or **PostgreSQL**
- **Flyway** for database migrations
- **Lombok**
- **Validation**
- **OpenAPI / Swagger**
- **Docker**

---

## Main Backend Modules

### 1. Authentication & Authorization

This part controls who is allowed to do what.

Planned roles:

- **ADMIN**
- **TEACHER**
- **STUDENT** or **VOTER**
- maybe later: **ELECTION_MANAGER**

Possible login types:

- fixed accounts for teachers / admins
- token-based login for students
- maybe later JWT or session-based auth

Important tasks:

- secure login
- role checks
- token validation
- prevent duplicate voting
- audit important actions

---

### 2. Election Management

This module should handle the elections themselves.

Features:

- create election
- edit election
- archive election
- define start and end date
- define election status
- assign candidates
- assign allowed voters or voter groups
- configure if election is public, internal, single-choice, multiple-choice, etc.

Important election states:

- DRAFT
- PLANNED
- ACTIVE
- ENDED
- ARCHIVED

---

### 3. Candidate Management

This module handles all candidates inside an election.

Possible fields:

- first name
- last name
- class
- short description
- image (later)
- election assignment
- active / inactive

Features:

- add candidate
- update candidate
- remove candidate
- sort candidate order
- validate candidate count

---

### 4. Voting Logic

This is the core of the whole system.

Main tasks:

- allow only valid voters
- allow only one vote if required
- support single-choice and maybe later multiple-choice
- validate active election period
- securely save the vote
- make manipulation harder
- separate voter identity from final vote if anonymous voting is needed

Important:
The vote flow should be simple, but the validation behind it must be strict.

---

### 5. Results & Statistics

This module should handle evaluation and result output.

Features:

- live results maybe later
- results only after election end
- ranking of candidates
- total votes
- invalid / blocked attempts
- export results as PDF or CSV later

---

### 6. Audit & Logging

Very important for admin actions and security.

Should log:

- election creation
- election changes
- candidate changes
- token creation / usage
- vote attempts
- failed login attempts
- result publication

---

## Suggested Package Structure

```text
src/main/java/.../wahlsystem
├── config
├── controller
├── dto
├── entity
├── enums
├── exception
├── mapper
├── repository
├── security
├── service
├── validation
└── util
```

---

## Suggested Entities

### User

For admins / teachers / students.
Maybe create a parent User class and then have the three types as subclasses if needed.

Fields:

- id
- username
- email
- password
- role
- active
- createdAt

### VoterToken

For student voting access.

Fields:

- id
- token
- used
- expiresAt
- electionId
- maybe class/group
- createdAt

### Election

Fields:

- id
- title
- description
- type
- status
- startAt
- endAt
- createdBy
- createdAt
- updatedAt

### Candidate

Fields:

- id
- firstName
- lastName
- className
- description
- election
- active
- sortOrder

### Vote

Fields:

- id
- election
- candidate
- timestamp

Depending on anonymity:

- no direct voter reference in final vote table
- or a separated vote-authorization table

### VoteAccess / VoteSession

Optional extra table for controlling if a token already voted.

---

## API Planning

### Public / Voter Endpoints

- `POST /api/v1/auth/token-login`
- `GET /api/v1/elections/{id}`
- `GET /api/v1/elections/{id}/candidates`
- `POST /api/v1/elections/{id}/vote`

### Admin Endpoints

- `POST /api/v1/admin/elections`
- `PUT /api/v1/admin/elections/{id}`
- `DELETE /api/v1/admin/elections/{id}`
- `POST /api/v1/admin/elections/{id}/candidates`
- `PUT /api/v1/admin/candidates/{id}`
- `DELETE /api/v1/admin/candidates/{id}`
- `POST /api/v1/admin/tokens/generate`
- `GET /api/v1/admin/elections/{id}/results`

---

## DTO Plan

Use DTOs early, not entities directly in controllers.

Planned DTO groups:

- auth DTOs
- election DTOs
- candidate DTOs
- vote DTOs
- result DTOs
- admin request / response DTOs

This keeps the API cleaner and safer.

---

## Validation Rules

Examples:

- election title must not be empty
- end date must be after start date
- election must be active before voting
- token must exist and not be used
- candidate must belong to the selected election
- one token can only vote once
- admin-only endpoints must require role check

---

## Security Plan

Important points:

- Spring Security from the beginning
- password hashing with BCrypt
- proper role-based access control
- rate limiting later maybe
- never trust frontend validation alone
- hide internal errors from public API responses
- structured exception handling

---

## Database Plan

Recommended approach:

- start simple
- use migrations from day one
- seed dev data for faster testing

Suggested setup:

- dev database
- test database
- production database
- Flyway migration scripts inside the project

---

## Development Phases

### Phase 1 – Base Project

- create Spring Boot project
- setup dependencies
- setup Docker
- setup database connection
- setup Flyway
- create base package structure

### Phase 2 – Core Models

- create entities
- create repositories
- create enums
- create first DTOs
- create service interfaces

### Phase 3 – Security

- admin login
- token-based voter access
- role checks
- protected routes

### Phase 4 – Election Features

- create election CRUD
- create candidate CRUD
- election activation / ending

### Phase 5 – Voting

- vote endpoint
- token validation
- duplicate prevention
- transaction safety

### Phase 6 – Results

- result calculation
- result endpoints
- admin statistics

### Phase 7 – Cleanup

- exception handling
- logging
- tests
- Swagger docs
- final refactoring

---

## Testing Plan

Needed tests:

- service tests
- repository tests
- controller / API tests
- security tests
- vote validation tests

Important cases:

- valid vote
- duplicate vote
- expired token
- invalid candidate
- inactive election
- admin endpoint access denied

---

## Nice Extras for Later

- anonymous vote mode
- image upload for candidates
- class-based election assignment
- QR code tokens
- PDF exports
- dashboard statistics
- email support
- multilingual API messages if needed

---

## First Concrete To-Do

1. Create Spring Boot project with needed dependencies  
2. Setup database + Flyway  
3. Create basic package structure  
4. Define entities and enums  
5. Implement admin auth  
6. Implement election and candidate CRUD  
7. Implement voter token flow  
8. Implement vote endpoint  
9. Add tests and Swagger  
10. Clean up and refactor

---

## General Direction

The backend should be:

- modular
- secure
- strict in validation
- easy to extend later
- clearly separated between voter and admin logic

The main idea is to build a strong backend first, so the frontend can later use a stable and clean API.
