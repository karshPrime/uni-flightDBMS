#? all functions for Add command : MySQL's INSERT command
module Add
    export run

    function _print_result(data, access)
        #TODO error handling
    end

    function run(userInput, accessLvl, connection)
        table = Scrape.enter_a_table(userInput, "add", "to", accessLvl)
        if table == 1 return 1; end

        attributes = DBInterface.fetch(DBInterface.execute(connection, "DESCRIBE $table;"))
        
        data = Dict{String, String}()
        
        for column in attributes
            column_name = column[:Field]
            print("> $column_name : ")
            value = chomp(readline())
            data[column_name] = value
        end
        
        columns = join(keys(data), ", ")
        values = join(values(data), ", ")
        
        sqlCmd = """INSERT INTO $table_name ($columns) VALUES ("$values");"""
        DBInterface.execute(connection, sqlCmd)

        _print_result(result, accessLvl)
    end
end
