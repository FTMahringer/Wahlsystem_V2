---
sidebar_position: 5
---

# Voting guide

## Current voter flow

The current voter-facing flow is designed to be simple:

1. enter or submit the assigned voting token
2. open the election tied to that token
3. review the election title, timing, and candidates
4. make the ballot selection for the configured election type
5. confirm the ballot
6. submit the vote
7. see the success screen

## Ballot behavior by election type

### Single choice

- choose one candidate
- only one selection is allowed

### Binary choice

- choose one of two options
- this is commonly used for yes/no or two-option decisions

### Approval voting

- choose all candidates you approve of
- several selections are allowed

### Limited vote

- choose up to the configured maximum number of candidates
- the UI should prevent extra selections and the backend validates them again

### Borda count

- rank the candidates in order
- the final result is based on points, not only raw vote totals

## Confirm step

The confirm step exists so voters can review the ballot before final submission.

This is especially important for:

- limited-vote elections where too many or too few selections may matter
- Borda-count elections where the order of candidates changes the final score

## Planned future voter documentation

Later documentation can add:

- screenshots of each step
- examples for each election type
- accessibility and classroom usage guidance
- instructions for first-time voters
