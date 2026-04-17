---
sidebar_position: 4
---

# Admin guide

## Election wizard

The election wizard currently walks through:

1. basics
2. election type
3. candidates
4. schedule
5. review

The wizard is backed by a shared frontend wizard system so the same interaction model can be reused for other admin flows.

## Candidate management

Admins and teachers can:

- create candidates
- update candidates
- remove candidates
- assign class and description fields

Binary-choice elections are validated so they only allow two candidates.

## User management

The users area now supports:

- listing students and teachers
- filtering by role and active state
- searching by username, email, or name
- activating and deactivating accounts

## User onboarding wizard

The onboarding flow supports:

- **single create**
- **bulk paste**
- **CSV import**

Each flow lets the admin choose:

- whether they are creating **students** or **teachers**
- the input mode
- the final preview before creation

### Student fields

- username
- email
- password
- first name
- last name
- student ID
- class name
- optional grade level

### Teacher fields

- username
- email
- password
- first name
- last name
- employee ID
- optional department
- optional subjects

## Still missing in admin flows

- edit/update flow for existing student and teacher profiles
- richer duplicate/conflict resolution during bulk import
- class/group targeting integrated into election assignment
- token/access provisioning from the user-management flow
