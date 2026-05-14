# ThatCookiesMine — project helpers

# ── Private helpers ───────────────────────────────────────────────────────────

function _tcm_exec
    dcinfrastructure exec $argv[1] $argv[2..-1]
end

function _tcm_logs
    dcinfrastructure logs -f $argv[1] $argv[2..-1]
end

function _tcm_npm
    _tcm_exec $argv[1] npm $argv[2..-1]
end

function _tcm_core
    make -C ~/work/core-api $argv[1]
end

function _tcm_notification
    make -C ~/work/notification-service $argv[1]
end

# argv[1]=title, argv[2..-1]="N|cmd|description" items
function _tcm_draw_menu
    set -l title $argv[1]
    set -l items $argv[2..-1]

    set -l c '#5ef1ff'  # cyan   — numbers
    set -l p '#bd5eff'  # purple — command names
    set -l w '#ffffff'  # white  — descriptions
    set -l b '#5ea1ff'  # blue   — title
    set -l g '#545862'  # grey   — separators
    set -l sep "  ──────────────────────────────────────────"

    echo ""
    set_color --bold $b; echo "  $title"; set_color normal
    set_color $g; echo $sep; set_color normal
    for row in $items
        set -l parts (string split '|' $row)
        printf "  "
        set_color $c;  printf "%s. " $parts[1]
        set_color $p;  printf "%-24s" $parts[2]
        set_color $w;  printf "%s\n" $parts[3]
        set_color normal
    end
    set_color $g; echo $sep; set_color normal
    echo ""
end

# argv[1]=title, argv[2..-1]="N|cmd|description" items
function _tcm_menu
    set -l title $argv[1]
    set -l items $argv[2..-1]

    set -l y '#f1ff5e'  # yellow — prompt
    set -l r '#ff6e5e'  # red    — error

    _tcm_draw_menu $title $items

    while true
        set_color $y; read -P "  Select [q=quit]: " _choice; set_color normal

        switch $_choice
            case q Q
                break
            case '*'
                set -l choice_parts (string split ' ' $_choice)
                set -l choice_num (string trim $choice_parts[1])
                set -l choice_args $choice_parts[2..-1]
                set -l matched 0
                for item in $items
                    set -l parts (string split '|' $item)
                    if test (string trim $parts[1]) = "$choice_num"
                        set -l cmd (string trim $parts[2])
                        $cmd $choice_args
                        set matched 1
                        break
                    end
                end
                if test $matched -eq 0
                    set_color $r; echo "  Invalid: $_choice"; set_color normal
                    continue
                end
                _tcm_draw_menu $title $items
        end
    end
end

# ── Infrastructure ────────────────────────────────────────────────────────────

function dcinfrastructure
    docker compose -f ~/work/infrastructure/docker-compose.yml $argv
end

function tcm-start
    ~/work/infrastructure/start-all.sh
end

function tcm-stop
    ~/work/infrastructure/stop-all.sh
end

function tcm-status
    dcinfrastructure ps
end

# ── Auth API ──────────────────────────────────────────────────────────────────

function auth-exec;         _tcm_exec auth-api $argv; end
function auth-rspec;        auth-exec env RAILS_ENV=test bundle exec rspec $argv; end
function auth-rubocop;      auth-exec bundle exec rubocop $argv; end
function auth-rails;        auth-exec bundle exec rails $argv; end
function auth-rswag;        auth-exec bundle exec rake rswag:specs:swaggerize; end
function auth-outbox-relay; auth-exec bundle exec rake outbox:relay; end
function auth-logs;         _tcm_logs auth-api $argv; end

function auth-menu
    _tcm_menu "Auth API" \
        "1|auth-exec        |exec command in auth-api container" \
        "2|auth-rspec       |run rspec tests" \
        "3|auth-rubocop     |run rubocop linter" \
        "4|auth-rails       |run rails command" \
        "5|auth-rswag       |generate swagger docs" \
        "6|auth-outbox-relay|run outbox relay" \
        "7|auth-logs        |follow auth-api logs"
end

# ── Notification / Nginx ──────────────────────────────────────────────────────

function notification-exec;  _tcm_exec notification-service $argv; end
function notification-logs;  _tcm_logs notification-service $argv; end
function notification-test;  _tcm_notification test; end
function notification-lint;  _tcm_notification lint; end
function notification-fmt;   _tcm_notification fmt; end
function notification-vet;   _tcm_notification vet; end
function notification-build; _tcm_notification build; end
function nginx-logs;         _tcm_logs nginx $argv; end

function notification-menu
    _tcm_menu "Notification / Nginx" \
        "1|notification-exec  |exec command in notification-service container" \
        "2|notification-logs  |follow notification-service logs" \
        "3|notification-test  |run tests" \
        "4|notification-lint  |run linter" \
        "5|notification-fmt   |format code" \
        "6|notification-vet   |run vet" \
        "7|notification-build |build" \
        "8|nginx-logs         |follow nginx logs"
end

# ── Admin ─────────────────────────────────────────────────────────────────────

function admin-exec;          _tcm_exec admin $argv; end
function admin-test;          _tcm_npm admin run test $argv; end
function admin-test-run;      _tcm_npm admin run test:run $argv; end
function admin-test-coverage; _tcm_npm admin run test:coverage; end
function admin-test-all
    _tcm_npm admin run test:run
    and _tcm_npm admin run test:coverage
end
function admin-typecheck;     _tcm_npm admin run typecheck; end
function admin-lint;          _tcm_npm admin run lint; end
function admin-format;        _tcm_npm admin run format; end
function admin-format-check;  _tcm_npm admin run format:check; end
function admin-logs;          _tcm_logs admin $argv; end

function admin-menu
    _tcm_menu "Admin" \
        "1|admin-exec          |exec command in admin container" \
        "2|admin-test          |run tests (watch mode)" \
        "3|admin-test-run      |run tests once (no watch)" \
        "4|admin-test-coverage |run test coverage report" \
        "5|admin-test-all      |run tests + coverage" \
        "6|admin-typecheck     |run svelte-check type checking" \
        "7|admin-lint          |run linter" \
        "8|admin-format        |format code" \
        "9|admin-format-check  |check formatting without writing" \
        "10|admin-logs         |follow admin logs"
end

# ── Frontend ──────────────────────────────────────────────────────────────────

function frontend-exec;          _tcm_exec frontend $argv; end
function frontend-test;          _tcm_npm frontend run test $argv; end
function frontend-test-run;      _tcm_npm frontend run test:run $argv; end
function frontend-test-coverage; _tcm_npm frontend run test:coverage; end
function frontend-test-all
    _tcm_npm frontend run test:run
    and _tcm_npm frontend run test:coverage
end
function frontend-typecheck;     _tcm_npm frontend run typecheck; end
function frontend-lint;          _tcm_npm frontend run lint; end
function frontend-format;        _tcm_npm frontend run format; end
function frontend-format-check;  _tcm_npm frontend run format:check; end
function frontend-logs;          _tcm_logs frontend $argv; end

function frontend-menu
    _tcm_menu "Frontend" \
        "1|frontend-exec          |exec command in frontend container" \
        "2|frontend-test          |run tests (watch mode)" \
        "3|frontend-test-run      |run tests once (no watch)" \
        "4|frontend-test-coverage |run test coverage report" \
        "5|frontend-test-all      |run tests + coverage" \
        "6|frontend-typecheck     |run svelte-check type checking" \
        "7|frontend-lint          |run linter" \
        "8|frontend-format        |format code" \
        "9|frontend-format-check  |check formatting without writing" \
        "10|frontend-logs         |follow frontend logs"
end

# ── Pro ───────────────────────────────────────────────────────────────────────

function pro-exec;          _tcm_exec pro $argv; end
function pro-test;          _tcm_npm pro run test $argv; end
function pro-test-run;      _tcm_npm pro run test:run $argv; end
function pro-test-coverage; _tcm_npm pro run test:coverage; end
function pro-test-all
    _tcm_npm pro run test:run
    and pro-test-coverage
end
function pro-typecheck;     _tcm_npm pro run typecheck; end
function pro-lint;          _tcm_npm pro run lint; end
function pro-format;        _tcm_npm pro run format; end
function pro-format-check;  _tcm_npm pro run format:check; end
function pro-logs;          _tcm_logs pro $argv; end

function pro-menu
    _tcm_menu "Pro" \
        "1|pro-exec          |exec command in pro container" \
        "2|pro-test          |run tests (watch mode)" \
        "3|pro-test-run      |run tests once (no watch)" \
        "4|pro-test-coverage |run test coverage report" \
        "5|pro-test-all      |run tests + coverage" \
        "6|pro-typecheck     |run svelte-check type checking" \
        "7|pro-lint          |run linter" \
        "8|pro-format        |format code" \
        "9|pro-format-check  |check formatting without writing" \
        "10|pro-logs         |follow pro logs"
end

# ── Core API ──────────────────────────────────────────────────────────────────

function core-exec;  _tcm_exec core-api $argv; end
function core-logs;  _tcm_logs core-api $argv; end
function core-test;  _tcm_core test; end
function core-lint;  _tcm_core lint; end
function core-fmt;   _tcm_core fmt; end
function core-vet;   _tcm_core vet; end
function core-build; _tcm_core build; end

function core-menu
    _tcm_menu "Core API" \
        "1|core-exec  |exec command in core-api container" \
        "2|core-logs  |follow core-api logs" \
        "3|core-test  |run tests" \
        "4|core-lint  |run linter" \
        "5|core-fmt   |format code" \
        "6|core-vet   |run vet" \
        "7|core-build |build"
end

# ── Dev workspace ─────────────────────────────────────────────────────────────

function dev-setup
    ~/work/dev-setup/tmux-repos.sh $argv
end
