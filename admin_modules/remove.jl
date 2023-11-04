#? all functions for Remove command : MySQL's DELETE command
module Remove
    using MySQL
    using DBInterface
    
    include("COMMON.jl"); using .Common
    export run

    function _print_result(data, access)
        #TODO error handle prompt
    end

    function run(userInput, accessLvl, connection)
        table = Common.enter_a_table(userInput, "remove", "from")
        if table == 1 return 1; end
        
        (~, primaryKey) = Common.primary_key(table, connection)
        printstyled("Enter $primaryKey for entry you wish to delete: "; color = :yellow)
        id = chomp(readline())
        
        if Common.decline() return 2; end

        sqlCmd = "DELETE FROM $table WHERE $primaryKey = $id;"

        action = DBInterface.execute(connection, sqlCmd)

        _print_result(action, accessLvl)
    end
end
