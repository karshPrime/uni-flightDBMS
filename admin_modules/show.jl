#? all functions for Show command : MySQL's SELECT command
module Show
    export run

    function _decode(userInput, accessLvl)
        tableIDs = Dict(
            "plane"    => 2,
            "pilot"    => 4,
            "crew"     => 6,
            "light"    => 8,
            "airstaff" => 10
        )

        if haskey(tableIDs, userInput[1])
            infoIndex = tableIDs[userInput[1]]
        else
            return 1
        end

        sqlCmd = ""
        for prompt in userInput[2:end]
            (perms, trigger, sql) = Help.showDetails[5][infoIndex][1:3]
            if perms <= accessLvl
                if prompt == trigger
                    sqlCmd = Lib.generate_sql(sqlCmd, sql, userInput[i + 1])
                end
            end
        end

        return sqlCmd
    end

    function run(userInput, accessLvl, connection)
        if length(userInput) == 1
            Lib.print_error("Please specify table to select data from.")
            Lib.print_error("""type "? show" for more information""")
            return 1
        end

        view = Scrape.view(userInput[2], accessLvl)
        if view == 1 return 1; end

        sqlCmd = _decode(userInput[2:end], accessLvl)
        if sqlCmd == 1 return 1; end

        sqlCmd = "SELECT * FROM $view" * sqlCmd
        result = DBInterface.fetch(DBInterface.execute(connection, sqlCmd))

    end
end
