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

### What admins should check before publishing

- election title and description are clear to voters
- the election type matches the intended voting model
- the candidate list is complete and ordered correctly
- dates are valid and reflect the real voting window
- binary elections only contain two options

### Current limitation

The current docs describe the wizard conceptually. A later documentation pass can add screenshots and a field-by-field walkthrough for each step.

## Candidate management

Admins and teachers can:

- create candidates
- update candidates
- remove candidates
- assign class and description fields

Binary-choice elections are validated so they only allow two candidates.

### Good candidate data practices

- use short, recognizable names
- keep descriptions neutral and factual
- use consistent class labels if candidate grouping matters later
- review ordering before publishing Borda-count elections

## User management

The users area now supports:

- listing students and teachers
- filtering by role and active state
- searching by username, email, or name
- activating and deactivating accounts

### Typical admin tasks

1. search for an existing account
2. check whether the role is correct
3. activate or deactivate the account if needed
4. use onboarding only when the account does not exist yet

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

### Bulk onboarding recommendations

- import one class or teacher group at a time
- review duplicates before confirming large imports
- use CSV when data already exists in another system
- use bulk paste when copying structured data from a spreadsheet or school tool

## Planned future wizard documentation

This documentation site is prepared for a later, more visual wizard guide.

Planned later:

- screenshots for each wizard step
- examples of valid input
- examples of common mistakes
- explanations for branching or optional steps

## Still missing in admin flows

- edit/update flow for existing student and teacher profiles
- richer duplicate/conflict resolution during bulk import
- class/group targeting integrated into election assignment
- token/access provisioning from the user-management flow
