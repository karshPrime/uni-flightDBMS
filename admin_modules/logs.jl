#? all functions to access Logs
module Logs
    using MySQL
    using DBInterface

    include("../interface_library.jl"); using .Lib
    include("COMMON.jl"); using .Common
    export run

    #? understand user input and generate corresponding sql
    function _decode(userInput)
        options = Dict(
            "on"     => "date",
            "at"   => "time",
            "by"   => "authorID",
            "action" => "action",
            "record" => "record"
        )
        conditions = ""

        for i in 1:length(userInput)
            if haskey(options, userInput[i])
                conditions = Lib.generate_sql(conditions, options[userInput[i]], userInput[i + 1])
            end
        end

        return conditions
    end

    #? display formatted result
    function _print_result(result)
        #
    end

    #? command run
    function run(userInput, accessLvl, connection)
        if accessLvl != 3 return; end
        flip_exec_db(true, connection) # switch to control_db

        conditions = _decode(userInput)

        sqlCmd = "SELECT * FROM Logs $conditions ;"
        println(sqlCmd)
        result = DBInterface.execute(connection, sqlCmd)

        flip_exec_db(false, connection) # switch back to flight_db

        _print_result(result)
    end
end
