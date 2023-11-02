#? all functions for Edit command : MySQL's UDPATE command
module Edit
    export run

    function _print_result(data, access)
        #TODO error handle prompt
    end

    function run(userInput, accessLvl, connection)
        table = Scrape.enter_a_table(userInput, "edit", "in", accessLvl)
        if table == 1 return 1; end

        (tableInfo, primaryKey) = Scrape.primary_key(table, connection)

        # Prompt for the entry ID to modify
        println("Enter $primaryKey for entry you wish to modify: ")
        id = chomp(readline())

        # Prompt for changes
        for row in tableInfo
            println("> $row[:Field]: ")
            newData = chomp(readline())
            sqlCmd = "UPDATE $table SET $row[:Field]=   '$newData' WHERE $primaryKey = $id;"
            
            actionLog = DBInterface.execute(connection, sqlCmd)

            _print_result(result, accessLvl)
        end
    end
end
