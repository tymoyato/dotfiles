# Improvement Plan: UX/DX/Code Quality

## Context
Audit of admin dashboard (React/TS) and auth API (Rails) surfaced UX gaps, API inconsistencies, and code quality issues. Grouped by area and priority.

---

## 1. Admin Dashboard — High Priority

### 1a. Confirmation dialog for destructive actions
- **File**: `admin/src/pages/users.tsx:127-145`
- Deactivate button fires immediately. Wrap in `<AlertDialog>` (shadcn already available) before calling API.

### 1b. Loading spinners replace plain "Loading..."
- **Files**: `admin/src/pages/users.tsx:64`, `admin/src/components/protected-route.tsx:10`
- Replace `<p>Loading...</p>` with a `<Spinner>` component or skeleton rows for the table.

### 1c. Error state UI for failed data fetches
- **File**: `admin/src/pages/users.tsx:17`
- Toast-only errors disappear. Add persistent inline error + retry button when user list fetch fails.

### 1d. Session expiry explanation before redirect
- **File**: `admin/src/api/client.ts:71`
- Show toast "Session expired, please log in again" before `window.location.href = '/login'`.

### 1e. Accessibility: aria-labels & aria-current
- **File**: `admin/src/pages/users.tsx` — action buttons need `aria-label="Deactivate {email}"`.
- **File**: `admin/src/components/app-sidebar.tsx:26` — add `aria-current="page"` to active NavLink.
- **File**: `admin/src/pages/users.tsx:64` — wrap loading text in `aria-live="polite"`.

---

## 2. Admin Dashboard — Medium Priority

### 2a. 404 page instead of silent redirect
- **File**: `admin/src/App.tsx:33`
- Replace `<Navigate to="/" replace />` catch-all with a proper `NotFound` page.

### 2b. Empty state for users table
- **File**: `admin/src/pages/users.tsx:79-84`
- Replace bare "No users found" cell with an illustrated empty state + optional CTA.

### 2c. Login form live validation
- **File**: `admin/src/pages/login.tsx:78-123`
- Trigger field-level validation `onBlur` not only `onSubmit`. Add `aria-invalid` and red border on invalid fields.

---

## 3. Auth API — High Priority

### 3a. Standardize error response shape
- **File**: `app/controllers/api/v1/authentication_controller.rb`
- All endpoints must return `{ "error": "string" }` (singular). Current: mix of `error`, `errors[]`, and `{ valid, error }`.
- Endpoints to fix: register (line 52 uses `errors[]`), validate (lines 113-122 use `valid`), change-password (line 233 uses `errors[]`), reset-password (line 237).
- Update rswag specs accordingly.

### 3b. Extract shared auth logic to ApplicationController
- **Files**: `app/controllers/api/v1/authentication_controller.rb:288-306`, `app/controllers/api/v1/admin/users_controller.rb:56-77`
- Both duplicate: token extraction, JWT decode, current user resolution.
- Extract to `ApplicationController` as `authenticate_user!` and `current_user` helper. Use `before_action`.

---

## 4. Auth API — Medium Priority

### 4a. Pagination on admin users list
- **File**: `app/controllers/api/v1/admin/users_controller.rb:12-14`
- Add `page`/`per_page` params (default 25). Return `{ users: [...], meta: { total, page, per_page } }`.

### 4b. Required field validation at controller level
- **File**: `app/controllers/api/v1/authentication_controller.rb:76, 91, 145, 159`
- Validate presence of `refresh_token`, `email`, `token`, `new_password` before hitting service layer. Return `{ error: "refresh_token is required" }` with 422.

### 4c. Improve JWT error logging
- **File**: `app/services/jwt_service.rb:79`
- Log request ID and hashed token fingerprint alongside error message for traceability.

---

## Verification

### Admin Dashboard
```bash
docker-compose exec admin npm run build   # type-check passes
# Manual: trigger deactivate — confirm dialog appears
# Manual: kill network — error state + retry visible
# Manual: visit /bad-route — 404 page shown
# Manual: tab through users table — aria-labels read correctly
```

### Auth API
```bash
docker-compose exec auth-api bundle exec rspec        # all specs green
docker-compose exec auth-api bundle exec rubocop      # no offenses
# Manual: POST /api/v1/auth/register with bad data — response is { "error": "..." }
# Manual: GET /api/v1/admin/users?page=1&per_page=5 — paginated response
```

---

## File Summary

| File | Changes |
|------|---------|
| `admin/src/pages/users.tsx` | Confirm dialog, spinner, error state, aria-labels |
| `admin/src/components/protected-route.tsx` | Spinner |
| `admin/src/api/client.ts` | Toast before redirect |
| `admin/src/components/app-sidebar.tsx` | aria-current |
| `admin/src/App.tsx` | 404 route |
| `admin/src/pages/login.tsx` | onBlur validation |
| `app/controllers/api/v1/authentication_controller.rb` | Standardize errors, extract auth, add validations |
| `app/controllers/api/v1/admin/users_controller.rb` | Pagination, extract auth |
| `app/controllers/application_controller.rb` | Add `authenticate_user!` |
| `app/services/jwt_service.rb` | Better logging |
| `spec/integration/authentication_spec.rb` | Update for new error shapes |
