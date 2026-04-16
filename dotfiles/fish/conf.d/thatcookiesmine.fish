# ThatCookiesMine — project helpers
# Infrastructure docker-compose wrapper
function dcinfrastructure
    docker compose -f ~/work/infrastructure/docker-compose.yml $argv
end

# Exec into a service container
function auth-exec
    dcinfrastructure exec auth-api $argv
end

# Auth API shortcuts
function auth-rspec
    auth-exec bundle exec rspec $argv
end

function auth-rubocop
    auth-exec bundle exec rubocop $argv
end

function auth-rails
    auth-exec bundle exec rails $argv
end

function auth-rswag
    auth-exec bundle exec rake rswag:specs:swaggerize
end

function auth-logs
    dcinfrastructure logs -f auth-api $argv
end

# Notification Service shortcuts
function notification-logs
    dcinfrastructure logs -f notification-service $argv
end
