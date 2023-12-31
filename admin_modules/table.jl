#? all functions for Table command : MySQL's DESCRIBE TABLE command + count
module Table
    using Printf    
    include("COMMON.jl"); using .Common
    include("../interface_library.jl"); using .Lib
    
    export run

    #? understand user input and return corresponding sql
    function _decode(rawInput, accessLvl)
        flightTables = ["AirStaff","Crew","Flight","Pilot","Plane"]
        cmds = []
        
        if length(rawInput) == 1
            printstyled("\nAll Flight Tables:\n"; color = :yellow)
            for table in flightTables
                printstyled("  $table\n"; color = :light_cyan)
            end

            cmds = [1]
        else
            if length(rawInput) > 2
                tableName = Common.view(rawInput[3], accessLvl)
                cmds = [tableName]
            else
                cmds = all_views(accessLvl)
            end
        end

        return cmds
    end

    #? display function for about option
    function _print_result_about(data)
        Lib.draw_border([27,7,9,12])
        Lib.table_head(["Field","Null","Key","Default"],[24,4,6,9])
        Lib.draw_border([27,7,9,12])
        for row in data
            field = row[:Field]
            null = coalesce(row[:Null], "Missing") == "NO" ?  " x " : " ✔ "

            default = coalesce(row[:Default], "missing")
            default = default == "missing" ? "null" : join(Char.(default))

            if length(default) > 10 && default[1:7] == "_latin1"
                default = default[10:end-2]
            end

            key = if row[:Key] == "PRI"
                "Primary"
            elseif row[:Key] == "MUL"
                "Foreign"
            else
                 "   -"
            end
        
            formattedRow = @sprintf("| %-25s | %-5s | %-7s | %-10s |", 
                field, 
                null, 
                key, 
                default
            )
        
            printstyled("$formattedRow\n", color = :light_cyan)
        end
        Lib.draw_border([27,7,9,12])
    end

    #? print function for count option
    function _print_result_count(data, tableName)
        for row in data
            printstyled("Count of $tableName Entries: "; color = :yellow)
            count = row[1]
            printstyled("$count\n"; color = :light_cyan)
        end
    end

    #? table name from view name
    function _table_name(title)
        if title in ["HFlight","HPilot","HPlane"]
            return title[2:end]
        end

        return title
    end

    #? command run
    function run(userInput, accessLvl, connection)
        tableTitles = _decode(userInput, accessLvl)

        if tableTitles[1] == 1 return 1; end

        tableLog = length(tableTitles) > 1 ? "-All-" : tableTitles[1]

        if userInput[2] == "count"
            for title in tableTitles
                fullCmd = "SELECT COUNT(*) FROM " * title
                result = Common.execute(connection, fullCmd, accessLvl)
                _print_result_count(result, _table_name(title))
            end
        elseif userInput[2] == "about"
            for title in tableTitles
                fullCmd = "DESCRIBE " * title
                result = Common.execute(connection, fullCmd, accessLvl)

                #? print table name only when multiple tables are printed; otherwise redundant
                if length(tableTitles) > 1 
                    printstyled("\n$(_table_name(title))\n"; color = :light_yellow)
                end

                _print_result_about(result)
            end
        else
            Lib.print_error("invalid parameters")
            Lib.print_error("""type "? table" for more information.""")
            return 1
        end
        return ["Table", tableLog, userInput[2]]
    end
end
