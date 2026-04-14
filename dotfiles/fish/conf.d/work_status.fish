function __work_status --on-event fish_prompt
    if test "$PWD" != "$HOME/work"
        return
    end

    for dir in $HOME/work/*/
        test -d "$dir/.git" || continue
        set repo (basename $dir)

        set changes (git -C $dir status --porcelain 2>/dev/null)
        if test -n "$changes"
            echo (set_color --bold white)$repo(set_color normal)": "(set_color yellow)"changes not staged"(set_color normal)
        else
            echo (set_color --bold white)$repo(set_color normal)": "(set_color green)"up to date with main"(set_color normal)
        end
    end
end
