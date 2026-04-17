---
sidebar_position: 1
---

# Overview

Wahlsystem is a school-focused election platform with a Spring Boot backend and a Vue 3 frontend.

The current implementation covers:

- aligned backend/frontend election contracts
- shared admin wizard infrastructure
- election creation and editing wizard
- token-based voter login
- type-specific ballots and results
- admin user management for students and teachers
- onboarding with single create, bulk paste, and CSV import

## Implemented election types

- `SINGLE_CHOICE`
- `BINARY_CHOICE`
- `APPROVAL_VOTING`
- `LIMITED_VOTE`
- `BORDA_COUNT`

## Main areas

### Admin and teacher area

- create and update elections
- define election type and schedule
- manage candidates
- review results
- manage student and teacher accounts

### Voter area

- authenticate with a voting token
- open the assigned election
- cast a ballot that matches the election type
- confirm and submit the vote

## What comes next

The current roadmap focuses on:

1. class/group targeting and provisioning
2. richer user-management refinement
3. advanced election types such as runoff, dual-role, and score voting
