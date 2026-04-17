# Plan: Fix rack-attack dev rate limiting bypassed by Docker/Nginx

## Context

Registration is limited to 3/IP/hour. In development, the safelist whitelists `127.0.0.1`/`::1` — but Bruno requests route through Nginx reverse proxy, so Rails sees the Nginx container IP (`172.x.x.x`). The safelist never fires, and the 3-registration limit blocks testing after 3 attempts.

## Immediate fix (unblock now, no code change)

Flush rack-attack counters in Redis:
```bash
docker-compose exec redis redis-cli KEYS "rack::attack:*" | xargs docker-compose exec -T redis redis-cli DEL
```

## Permanent fix

**File:** `config/initializers/rack_attack.rb`

Extend the `Rails.env.local?` safelist to also whitelist the Docker internal network range (`172.16.0.0/12`). This covers all Docker bridge network IPs in development only.

```ruby
if Rails.env.local?
  safelist('allow-localhost') do |req|
    ['127.0.0.1', '::1'].include?(req.ip) ||
      req.ip.start_with?('172.') # Docker internal network
  end
end
```

> Security note: `172.*` check is intentionally broad but safe — it only applies in `Rails.env.local?` (dev/test), never production.

## Verification

1. Run immediate Redis flush
2. Apply code change
3. Restart auth-api: `docker-compose restart auth-api`
4. Register >3 times in Bruno — no 429 returned
5. Confirm production behavior unaffected (`Rails.env.local?` guard)
