---
sidebar_position: 8
---

# Architecture

## High-level structure

The project is organized into three main layers:

### Backend

The backend is a Spring Boot application responsible for:

- authentication and authorization
- election, candidate, and user-management APIs
- vote validation and submission
- result calculation
- database access and persistence

### Frontend

The frontend is a Vue 3 application responsible for:

- admin workflows
- election and onboarding wizards
- voter-facing ballot screens
- result views
- API integration with the backend

### Documentation site

The Docusaurus site is responsible for:

- project overview and onboarding docs
- admin, voting, and technical documentation
- GitHub Pages publishing

## Important backend areas

- `controller/` exposes admin, auth, election, candidate, vote, and user-management endpoints
- `service/` contains the core business logic
- `dto/` defines request and response contracts
- `entity/` and `repository/` support persistence

## Important frontend areas

- `views/admin/` contains admin-facing screens
- `views/voter/` contains voter-facing screens
- `components/common/wizard/` contains shared wizard UI parts
- `composables/useWizard.ts` contains shared wizard state and navigation logic
- `api/` contains HTTP client modules
- `types/` contains shared frontend data models

## Contract alignment

One of the main recent improvements was aligning the election contract between frontend and backend.

That includes:

- shared election types
- consistent vote payload expectations
- consistent result display behavior

## Future architecture topics

Later docs can expand this area with:

- diagrams
- data-flow explanations
- wizard component architecture
- deployment topology
