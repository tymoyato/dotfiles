# Plan: Admin Seed Rake Task

## Context
No mechanism exists to create the first admin in production without console access. Need an idempotent rake task that reads credentials from ENV vars — safe to call in deploy pipeline, no hardcoded creds.

## Files to Create/Modify

| File | Action |
|------|--------|
| `auth-api/lib/tasks/admin.rake` | Create |
| `auth-api/spec/tasks/admin_rake_spec.rb` | Create |
| `auth-api/.env.example` | Update — add new ENV vars |

## Implementation

### 1. `lib/tasks/admin.rake`

Follow pattern from `lib/tasks/tokens.rake`.

```ruby
namespace :admin do
  desc 'Seed first admin account from ENV vars ADMIN_EMAIL and ADMIN_PASSWORD'
  task seed: :environment do
    email    = ENV.fetch('ADMIN_EMAIL')    { abort 'ADMIN_EMAIL is required' }
    password = ENV.fetch('ADMIN_PASSWORD') { abort 'ADMIN_PASSWORD is required' }

    credential = AuthCredential.find_or_initialize_by(email: email)

    if credential.persisted? && credential.admin?
      puts "Admin already exists: #{email}"
      next
    end

    credential.assign_attributes(
      password: password,
      role: 'admin',
      email_verified_at: Time.current
    )

    if credential.save
      puts "Admin created: #{email}"
    else
      abort "Failed to create admin: #{credential.errors.full_messages.join(', ')}"
    end
  end
end
```

Key decisions:
- `abort` (not raise) on missing ENV — clean exit code 1, readable in CI logs
- `find_or_initialize_by` — idempotent, safe to re-run
- Skip if admin already exists with that email (no silent password overwrite)
- `abort` on save failure with validation messages

### 2. `spec/tasks/admin_rake_spec.rb`

Follow pattern from `spec/tasks/tokens_rake_spec.rb`.

Tests:
- Creates admin when ENV vars set and email not taken
- Skips (no-op) when admin already exists
- Aborts with message when `ADMIN_EMAIL` missing
- Aborts with message when `ADMIN_PASSWORD` missing
- Aborts with validation error on invalid password (too short, breached, etc.)

### 3. `.env.example`

Add two lines:
```
ADMIN_EMAIL=admin@yourapp.com        # Required for admin:seed task
ADMIN_PASSWORD=                      # Required for admin:seed task (min 14 chars)
```

## Usage in Production

```bash
ADMIN_EMAIL=ops@yourapp.com ADMIN_PASSWORD=strongpass14chars \
  docker-compose exec auth-api bundle exec rake admin:seed
```

## Verification

```bash
# Run tests
docker-compose exec auth-api bundle exec rspec spec/tasks/admin_rake_spec.rb

# Smoke test locally
docker-compose exec auth-api \
  ADMIN_EMAIL=test@example.com ADMIN_PASSWORD=testpass14chars \
  bundle exec rake admin:seed

# Verify in Rails console
docker-compose exec auth-api bundle exec rails runner \
  "puts AuthCredential.find_by(email: 'test@example.com').admin?"
```
