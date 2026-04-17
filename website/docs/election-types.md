---
sidebar_position: 3
---

# Election types

## Implemented now

### Single choice

- voter selects exactly one candidate
- winner is the candidate with the highest vote count
- best used when exactly one seat or one winner is needed

### Binary choice

- special case with exactly two candidates or options
- winner is the option with more votes
- useful for yes/no or two-option decisions

### Approval voting

- voter can select any number of acceptable candidates
- each selected candidate receives one vote
- useful when voters should support all acceptable options instead of only one

### Limited vote

- voter can select up to a configured number of candidates
- each selected candidate receives one vote
- election configuration stores `maxSelections`
- useful when several seats exist but voters should not select every candidate

### Borda count

- voter ranks all candidates
- higher ranks receive more points
- results are displayed as points instead of plain votes
- useful when overall preference order matters more than only the first choice

## Ballot behavior

The voting UI adapts to the election type:

- single and binary elections expect one selected candidate
- approval and limited-vote elections expect a list of selected candidates
- Borda count expects a ranked list of candidates

The confirm step uses the same stored ballot object and submits a type-specific payload to the backend.

## Validation rules

Important examples:

- binary elections should only have two options
- limited-vote elections should not allow more than `maxSelections`
- Borda elections require a complete ranking of candidates
- all vote submissions are validated again on the backend

## Result display

The result views already distinguish between:

- **votes** for single, binary, approval, and limited-vote elections
- **points** for Borda-count elections

## Selection guidance

If you are choosing an election type:

1. use **single choice** for a single winner
2. use **binary choice** for yes/no or two-option decisions
3. use **approval voting** when several acceptable candidates may exist
4. use **limited vote** when each voter should support only a fixed number of candidates
5. use **Borda count** when ranking matters

## Planned later

- candidate pair voting
- dual-role elections
- two-round runoff
- instant runoff voting
- score voting
