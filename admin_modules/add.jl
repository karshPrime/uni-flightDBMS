#? all functions for Add command : MySQL's INSERT command
module Add
    using MySQL
    using DBInterface

    include("COMMON.jl"); using .Common
    
    export run

    function _print_result(data, access)
        #TODO error handling
    end

    function run(userInput, accessLvl, connection)
        table = Common.enter_a_table(userInput, "add", "to")
        if table == 1 return 1; end

        attributes = DBInterface.fetch(DBInterface.execute(connection, "DESCRIBE $table;"))
        
        data = Dict{String, String}()
        
        for column in attributes
            columnName = column[:Field]
            
            #* this information is auto generated
            if columnName == "staffCount" continue; end

            printstyled("> $columnName : "; color = :yellow)
            value = chomp(readline())
            data[columnName] = value
        end
        
        columns = join(keys(data), ", ")
        info = join(values(data), """ "," """)
        
        sqlCmd = """INSERT INTO $table ($columns) VALUES ("$info");"""
        result = DBInterface.execute(connection, sqlCmd)
        _print_result(result, accessLvl)
    end
end
