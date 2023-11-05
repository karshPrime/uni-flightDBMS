#? all functions for Remove command : MySQL's DELETE command
module Remove
    include("COMMON.jl"); using .Common
    export run

    #? command run
    function run(userInput, accessLvl, connection)
        table = Common.enter_a_table(userInput, "remove", "from")
        if table == 1 return 1; end
        
        (~, primaryKey) = Common.primary_key(table, connection)
        printstyled("Enter $primaryKey for entry you wish to delete: "; color = :yellow)
        id = chomp(readline())
        
        if Common.decline() return 2; end

        sqlCmd = "DELETE FROM $table WHERE $primaryKey = $id;"

        result = Common.execute(connection, sqlCmd, accessLvl, false)

        return result == 1 ? 1 : ["Remove",table,"FOR ID=$id"]
    end
end
