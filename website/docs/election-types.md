---
sidebar_position: 3
---

# Election types

## Implemented now

### Single choice

- voter selects exactly one candidate
- winner is the candidate with the highest vote count

### Binary choice

- special case with exactly two candidates or options
- winner is the option with more votes

### Approval voting

- voter can select any number of acceptable candidates
- each selected candidate receives one vote

### Limited vote

- voter can select up to a configured number of candidates
- each selected candidate receives one vote
- election configuration stores `maxSelections`

### Borda count

- voter ranks all candidates
- higher ranks receive more points
- results are displayed as points instead of plain votes

## Planned later

- candidate pair voting
- dual-role elections
- two-round runoff
- instant runoff voting
- score voting

## Result display

The result views already distinguish between:

- **votes** for single, binary, approval, and limited-vote elections
- **points** for Borda-count elections
