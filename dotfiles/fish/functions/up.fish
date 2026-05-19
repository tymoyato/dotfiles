function up --description "cd up N levels (default 1)"
    set -l n (test -n "$argv[1]" && echo $argv[1] || echo 1)
    set -l path ""
    for i in (seq $n)
        set path "$path../"
    end
    cd $path
end
