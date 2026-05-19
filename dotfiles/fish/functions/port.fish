function port --description "show process using port"
    if test -z "$argv[1]"
        echo "usage: port <number>"
        return 1
    end
    lsof -i :$argv[1]
end
