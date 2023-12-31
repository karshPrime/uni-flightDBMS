#? all functions for Edit command : MySQL's UDPATE command
module Edit
    include("COMMON.jl"); using .Common
    export run

    #? command run
    function run(userInput, accessLvl, connection)
        table = Common.enter_a_table(userInput, "edit", "in")
        if table == 1 return 1; end

        (tableInfo, primaryKey) = Common.primary_key(table, connection)

        # Prompt for the entry ID to modify
        printstyled("Enter $primaryKey for entry you wish to modify: "; color = :yellow)
        id = chomp(readline())

        printstyled("Enter == to leave the field unchanged\n"; color = :red)

        conditions = ""
        
        # Prompt for changes
        for row in tableInfo
            printstyled("> $(row[:Field]): "; color = :yellow)
            newData = chomp(readline())
        
            if newData in ["==", ""] continue; end
        
            if occursin(r"^\d*$", newData)  # Check if newData is an integer
                conditions *= ", $(row[:Field]) = $newData"
            else
                conditions *= ", $(row[:Field]) = '$newData'"
            end
        end

        if Common.decline() return 1; end

        sqlCmd = "UPDATE $table SET $(conditions[3:end]) WHERE $primaryKey = $id ;"
        result = Common.execute(connection, sqlCmd, accessLvl)

        return result == 1 ? 1 : ["Edit",table,"FOR ID=$id"]
    end
end
