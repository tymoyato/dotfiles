function __work_status --on-event fish_prompt
    if test "$PWD" != "$HOME/work"
        return
    end

    set session_info (tmux list-sessions -F "#{session_name} #{session_id}" 2>/dev/null)

    for dir in $HOME/work/*/
        test -d "$dir/.git" || continue
        set repo (basename $dir)

        set session_num "–"
        for entry in $session_info
            set name (string split " " $entry)[1]
            set sid (string split " " $entry)[2]
            if test "$name" = "$repo"
                set session_num (string replace '$' '' $sid)
                break
            end
        end

        set changes (git -C $dir status --porcelain 2>/dev/null)
        if test -n "$changes"
            echo (set_color cyan)"[$session_num]"(set_color normal)" "(set_color --bold white)$repo(set_color normal)": "(set_color yellow)"changes not staged"(set_color normal)
        else
            echo (set_color cyan)"[$session_num]"(set_color normal)" "(set_color --bold white)$repo(set_color normal)": "(set_color green)"up to date with main"(set_color normal)
        end
    end
end
