#? all functions for Edit command : MySQL's UDPATE command
module Edit
    using MySQL
    using DBInterface

    include("COMMON.jl"); using .Common
    export run

    function _print_result(data, access)
        #TODO error handle prompt
    end

    function run(userInput, accessLvl, connection)
        table = Common.enter_a_table(userInput, "edit", "in")
        if table == 1 return 1; end

        (tableInfo, primaryKey) = Common.primary_key(table, connection)

        # Prompt for the entry ID to modify
        printstyled("Enter $primaryKey for entry you wish to modify: "; color = :yellow)
        id = chomp(readline())

        printstyled("Enter == to leave the field unchanged\n"; color = :red)
        
        # Prompt for changes
        for row in tableInfo
            printstyled("> $(row[:Field]): "; color = :yellow)
            newData = chomp(readline())

            if newData == "==" continue; end

            sqlCmd = "UPDATE $table SET $row[:Field]=   '$newData' WHERE $primaryKey = $id;"
            
            result = DBInterface.execute(connection, sqlCmd)

            _print_result(result, accessLvl)
        end
    end
end
