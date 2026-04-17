---
sidebar_position: 1
slug: /
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

## Purpose

The goal of the platform is to make school elections easier to prepare, safer to run, and easier to understand for both administrators and voters.

It is designed around a few practical ideas:

- admins should be guided through setup instead of filling large unstructured forms
- voting should adapt to the selected election type
- backend and frontend should share the same election contract
- documentation should explain both usage and implementation, not only installation

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
- validate election constraints before publishing
- manage candidates
- review results
- manage student and teacher accounts
- onboard users through guided flows

### Voter area

- authenticate with a voting token
- open the assigned election
- cast a ballot that matches the election type
- confirm and submit the vote
- review success feedback after submission

## Documentation map

This documentation is split into a few main areas:

- **Getting started** for local setup and scripts
- **Admin guide** for election and user management workflows
- **Voting guide** for the voter-facing flow
- **Election types** for supported ballot models
- **Architecture** and **Development** for the technical structure
- **Roadmap** for what still needs to be built

## Planned documentation expansion

The next documentation additions are already expected to include:

- step-by-step wizard usage docs with screenshots
- voter-facing instructions with screenshots and examples
- more detailed admin operational guides
- visual explanations for election configuration options

## What comes next

The current roadmap focuses on:

1. class/group targeting and provisioning
2. richer user-management refinement
3. advanced election types such as runoff, dual-role, and score voting
