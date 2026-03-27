# Wahlsystem Frontend Plan

## Goal
The frontend should be modern, simple, and easy to use.

It should provide:
- a clean admin interface
- a very simple voter interface
- clear navigation
- responsive layout
- fast interaction with the Spring backend API

---

## Main Tech Stack
- **Vue 3**
- **TypeScript**
- **Vite**
- **Vue Router**
- **Pinia**
- **Axios**
- maybe later: **PrimeVue** or custom UI components
- **Docker**

---

## Main Frontend Areas

### 1. Public / Voter Area
This area should be as simple as possible.

Goal:
A student or voter should be able to:
- open the page
- enter token or access code
- see the election
- select a candidate
- submit the vote
- get a clear success or error message

Important:
The voter UI should have as few steps as possible.

Possible pages:
- token login page
- election overview
- candidate selection
- vote confirmation
- success / error page

---

### 2. Admin Area
This is the bigger part of the frontend.

The admin should be able to:
- log in
- create and edit elections
- manage candidates
- generate or manage tokens
- monitor status
- view results
- maybe export data later

Possible pages:
- login
- dashboard
- elections list
- election create / edit
- candidates management
- token management
- results page
- settings page maybe later

---

## Suggested Project Structure

```text
src/
├── api/
├── assets/
├── components/
├── composables/
├── layouts/
├── router/
├── stores/
├── types/
├── utils/
├── views/
└── App.vue
```

More detailed:

```text
src/
├── api/
│   ├── axios.ts
│   ├── authApi.ts
│   ├── electionApi.ts
│   ├── candidateApi.ts
│   └── voteApi.ts
├── components/
│   ├── common/
│   ├── admin/
│   └── voter/
├── layouts/
│   ├── AdminLayout.vue
│   └── VoterLayout.vue
├── stores/
│   ├── authStore.ts
│   ├── electionStore.ts
│   └── uiStore.ts
├── types/
│   ├── auth.ts
│   ├── election.ts
│   ├── candidate.ts
│   └── vote.ts
├── views/
│   ├── admin/
│   └── voter/
└── router/
    └── index.ts
```

---

## Routing Plan

### Voter Routes
- `/`
- `/vote/login`
- `/vote/election/:id`
- `/vote/confirm`
- `/vote/result`

### Admin Routes
- `/admin/login`
- `/admin/dashboard`
- `/admin/elections`
- `/admin/elections/create`
- `/admin/elections/:id/edit`
- `/admin/elections/:id/candidates`
- `/admin/elections/:id/tokens`
- `/admin/elections/:id/results`

---

## State Management Plan

### Pinia Stores
Suggested stores:

#### authStore
Handles:
- admin login state
- token / session handling
- logout
- current user

#### electionStore
Handles:
- elections
- current election
- candidates
- results

#### uiStore
Handles:
- loading states
- notifications
- dialogs
- general UI state

---

## API Communication Plan
Use a central Axios instance.

Important features:
- base URL from env file
- request interceptor
- response interceptor
- automatic auth header for admin requests
- central error handling

Example files:
- `axios.ts`
- `authApi.ts`
- `electionApi.ts`
- `candidateApi.ts`
- `voteApi.ts`

This makes the frontend cleaner and easier to maintain.

---

## Main Views

### Voter Views

#### Token Login View
- input for token
- validation
- error handling
- continue button

#### Election View
- election title
- description
- candidate list
- simple design
- one clear vote button

#### Vote Confirmation View
- selected candidate
- warning before final submit
- submit action

#### Vote Result View
- success message
- maybe simple info like election finished / vote stored

---

### Admin Views

#### Admin Login View
- username/email
- password
- login button
- error message

#### Dashboard View
- active elections
- quick stats
- shortcuts to important pages

#### Elections List View
- table or cards
- filter by status
- create button
- edit button
- archive button

#### Election Form View
- title
- description
- type
- start date
- end date
- status
- validation messages

#### Candidate Management View
- list of candidates
- add candidate
- edit candidate
- remove candidate
- sort order maybe later

#### Token Management View
- generate tokens
- view token status
- maybe export tokens later

#### Results View
- vote counts
- ranking
- charts maybe later

---

## Component Plan

### Common Components
- button
- input field
- card
- modal
- alert / notification
- loading spinner
- page header

### Admin Components
- sidebar
- topbar
- election form
- candidate table
- token table
- result card

### Voter Components
- candidate card
- vote summary
- token form
- success message

---

## UI / UX Direction
The frontend should be:
- modern
- simple
- not overloaded
- easy to understand
- very clear for students and teachers

### Voter UI
Needs to be:
- minimal
- fast
- obvious
- mobile friendly

### Admin UI
Needs to be:
- structured
- clean
- easy to maintain
- good for larger forms and tables

---

## Styling Plan
Possible options:
- custom CSS with variables
- SCSS
- PrimeVue later if needed
- Tailwind only if really wanted, but not required

Recommendation for now:
Start with simple scoped CSS or SCSS and clean reusable components.
Do not overcomplicate styling too early.

---

## Validation Plan
Frontend validation should help the user, but not replace backend validation.

Examples:
- required fields
- valid date ranges
- token input not empty
- candidate selection required
- clear error messages from API responses

---

## Error Handling Plan
The frontend should handle errors cleanly.

Examples:
- invalid token
- election not active
- vote already submitted
- network error
- unauthorized admin request

Show:
- readable error text
- no technical stack traces
- retry options where useful

---

## Development Phases

### Phase 1 – Base Setup
- create Vue project
- add TypeScript
- add router
- add Pinia
- add Axios
- create folder structure

### Phase 2 – Layout & Routing
- create admin layout
- create voter layout
- define routes
- route guards for admin area

### Phase 3 – API Layer
- create Axios instance
- create API service files
- create basic types

### Phase 4 – Voter Flow
- token login view
- election view
- vote confirm
- success / error flow

### Phase 5 – Admin Auth
- admin login
- auth store
- protected routes

### Phase 6 – Admin Features
- elections CRUD views
- candidate management
- token management
- result page

### Phase 7 – Cleanup
- loading states
- notifications
- validation improvements
- component cleanup
- responsive fixes

---

## Environment Plan
Use `.env` files.

Examples:
- `.env.development`
- `.env.production`

Main variables:
- `VITE_API_BASE_URL`
- maybe later other feature flags

---

## Testing Plan
Later useful:
- unit tests for stores and helpers
- component tests
- maybe E2E tests again later if needed

For now:
Focus first on structure and clean components.

---

## Nice Extras for Later
- dark mode
- charts for results
- multilingual UI
- QR-based token entry
- printable token sheets
- improved dashboard
- bulk candidate import
- admin activity log view

---

## First Concrete To-Do
1. Create Vue 3 + TypeScript + Vite project  
2. Setup router, Pinia, Axios  
3. Build folder structure  
4. Create layouts for voter and admin  
5. Create API layer and type files  
6. Implement voter flow first  
7. Implement admin login  
8. Implement election management pages  
9. Implement candidate and token management  
10. Clean up styling and state handling

---

## General Direction
The frontend should be split clearly into:
- **simple voter frontend**
- **structured admin frontend**

The main focus should be clarity, maintainability, and a clean connection to the Spring backend API.
