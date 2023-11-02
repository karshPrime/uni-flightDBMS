#? all functions for Remove command : MySQL's DELETE command
module Remove
    export run

    function _print_result(data, access)
        #TODO error handle prompt
    end

    function run(userInput, accessLvl, connection)
        table = Scrape.enter_a_table(userInput, "remove", "from", accessLvl)
        if table == 1 return 1; end
        
        (~, primaryKey) = Scrape.primary_key(table, connection)
        println("Enter $primaryKey for entry you wish to delete: ")
        id = chomp(readline())
        sqlCmd = "DELETE FROM $tableName WHERE $primaryKey = $id;"

        action = DBInterface.execute(connection, sqlCmd)

        _print_result(action, accessLvl)
    end
end
