#? all functions for Add command : MySQL's INSERT command
module Add
    include("COMMON.jl"); using .Common
    
    export run

    #? command run
    function run(userInput, accessLvl, connection)
        table = Common.enter_a_table(userInput, "add", "to")
        if table == 1 return 1; end

        attributes = Common.execute(connection, "DESCRIBE $table;", accessLvl, true)
        
        data = Dict{String, String}()
        
        for column in attributes
            columnName = column[:Field]
            
            #* this information is auto generated
            if columnName == "staffCount" continue; end

            printstyled("> $columnName : "; color = :yellow)
            value = chomp(readline())
            data[columnName] = value
        end

        if Common.decline() return 2; end
        
        columns = join(keys(data), ", ")
        info = join(values(data), "','")
        
        sqlCmd = """INSERT INTO $table ($columns) VALUES ('$info');"""
        result = Common.execute(connection, sqlCmd, accessLvl, false)
    end
end
