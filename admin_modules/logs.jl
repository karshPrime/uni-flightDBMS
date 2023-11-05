#? all functions to access Logs
module Logs
    using Printf
    include("../interface_library.jl"); using .Lib
    include("COMMON.jl"); using .Common
    
    export run

    #? understand user input and generate corresponding sql
    function _decode(userInput)
        options = Dict(
            "on"     => "date",
            "at"     => "time",
            "by"     => "authorID",
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
        Lib.draw_border([12,10,10,8,8,31,12])
        Lib.table_head(
            ["Date","Time","Author","Action","Target","Details","Record"],
            [9,7,7,5,5,28,9]
        )
        Lib.draw_border([12,10,10,8,8,31,12])
        for row in result
            formattedRow = @sprintf("| %-10s | %-8s | %-8s | %-6s | %-6s | %-29s | %-10s |", 
                row[:date],
                row[:time],
                row[:authorID],
                row[:action],
                row[:table],
                row[:details],
                row[:record]
            )
            printstyled("$formattedRow\n", color = :light_cyan)
        end
        Lib.draw_border([12,10,10,8,8,31,12])
    end

    #? command run
    function run(userInput, accessLvl, connection)
        if accessLvl != 3 return; end
        flip_exec_db(true, connection) # switch to control_db

        conditions = _decode(userInput)

        sqlCmd = "SELECT * FROM Logs $conditions ;"
        result = Common.execute(connection, sqlCmd, accessLvl, true)
        if result == 1 return 1; end
        
        _print_result(result)

        flip_exec_db(false, connection) # switch back to flight_db
        return ["Logs", "View", conditions=="" ? "ALL" : replace(conditions[8:end], "'" => ""), "control_db"]
    end
end
