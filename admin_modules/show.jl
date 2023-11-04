#? all functions for Show command : MySQL's SELECT command
module Show
    using MySQL
    using DBInterface

    include("COMMON.jl"); using .Common
    include("help.jl"); using .Help
    include("../interface_library.jl"); using .Lib

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
        for i in 1:length(userInput)
            (perms, trigger, sql) = Help.showDetails[5][infoIndex][1:3]
            if perms <= accessLvl
                if userInput[i] == trigger
                    sqlCmd = Lib.generate_sql(sqlCmd, sql, userInput[i + 1])
                end
            end
        end

        return sqlCmd
    end

    function _print_result(result)
        #
    end

    function run(userInput, accessLvl, connection)
        if length(userInput) == 1
            Lib.print_error("Please specify table to select data from.")
            Lib.print_error("""type "? show" for more information""")
            return 1
        end

        view = Common.view(userInput[2], accessLvl)
        if view == 1 return 1; end

        sqlCmd = _decode(userInput, accessLvl)
        if sqlCmd == 1 return 1; end

        sqlCmd = "SELECT * FROM $view $sqlCmd ;"
        println(sqlCmd)
        result = DBInterface.fetch(DBInterface.execute(connection, sqlCmd))
        _print_result(result)
    end
end
