function __work_status --on-event fish_prompt
    test "$PWD" = "$HOME/work" || return

    # Refresh at most once every 10 seconds
    set -l now (date +%s)
    if set -q __work_status_cache_time && test (math $now - $__work_status_cache_time) -lt 10
        printf '%s\n' $__work_status_cache
        return
    end

    set -l session_info (tmux list-sessions -F "#{session_name} #{session_id}" 2>/dev/null)
    set -l output

    for dir in $HOME/work/*/
        test -d "$dir/.git" || continue
        set -l repo (basename $dir)
        set -l session_num "–"

        for entry in $session_info
            set -l parts (string split " " $entry)
            if test "$parts[1]" = "$repo"
                set session_num (string replace '$' '' $parts[2])
                break
            end
        end

        set -l changes (git -C $dir status --porcelain 2>/dev/null)
        if test -n "$changes"
            set output $output (string join "" (set_color cyan)"[$session_num]"(set_color normal)" "(set_color --bold white)$repo(set_color normal)": "(set_color yellow)"changes not staged"(set_color normal))
        else
            set output $output (string join "" (set_color cyan)"[$session_num]"(set_color normal)" "(set_color --bold white)$repo(set_color normal)": "(set_color green)"up to date with main"(set_color normal))
        end
    end

    set -g __work_status_cache $output
    set -g __work_status_cache_time $now
    printf '%s\n' $output
end
