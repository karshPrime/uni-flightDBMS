#? all functions for Staff management
module Staff
    using MySQL
    using DBInterface

    include("../interface_library.jl"); using .Lib
    include("COMMON.jl"); using .Common
    export run

    function _decode(userInput)
        options = Dict(
            "search"     => "P.ID",
            "department" => "accessLvl"
        )

        conditions = ""
        showPass = 1

        for i in 2:length(userInput)
            if haskey(options, userInput[i])
                conditions = Lib.generate_sql(conditions, options[userInput[i]], userInput[i + 1])
            end

            if userInput[i] == "password"
                showPass = 2
            end
        end

        return (showPass, conditions)
    end

    function _print_result(result)
        #
    end

    function run(userInput, accessLvl, connection)
        if accessLvl != 3 return; end
        flip_exec_db(true, connection)

        password = (("", ""), ("AU.password, ", "JOIN Authentication AS AU ON P.ID = AU.ID"))

        (passCondition, conditions) = _decode(userInput)

        sqlCmd = """ 
            SELECT  P.ID, A.accessLvl, $(password[passCondition][1]) P.fName, P.lName, P.gender, P.phone
            FROM Profile AS P JOIN 
            Access AS A ON P.ID = A.ID
            $(password[passCondition][2])
            $conditions ;
        """ 
        println(sqlCmd)
        result = DBInterface.execute(connection, sqlCmd)

        flip_exec_db(false, connection) # switch back to flight_db

        _print_result(result)
    end
end
