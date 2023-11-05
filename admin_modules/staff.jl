#? all functions for Staff management
module Staff
    using Printf
    include("../interface_library.jl"); using .Lib
    include("COMMON.jl"); using .Common

    export run

    #? understand user input and generate corresponding sql
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

    #? display formatted result
    function _print_result(result, showPass)
        Lib.draw_border([5,20,11,15,15,8,11])
        Lib.table_head(
            ["ID","Password","Role","Name","Surname", "Gender","Phone"],
            [2,17,8,12,12,5,8]
        )
        Lib.draw_border([5,20,11,15,15,8,11])
        
        for row in result
            pass = showPass ? row[:password] : "***************"
            
                formattedRow = @sprintf("| %-3s | %-18s | %-9s | %-13s | %-13s | %-6s | %-9s |", 
                row[:ID],
                pass,
                row[:accessLvl],
                row[:fName],
                row[:lName],
                row[:gender],
                row[:phone]
            )

            printstyled("$formattedRow\n", color = :light_cyan)
        end
        Lib.draw_border([5,20,11,15,15,8,11])
    end

    #? command run
    function run(userInput, accessLvl, connection)
        if accessLvl != 3 return; end
        Common.flip_exec_db(true, connection)

        prompts = Dict(
            "ID"     => "",
            "Name"  => "",
            "Surname"  => "",
            "Gender" => "",
            "Phone"  => "",
            "AccessLvl" => "",
            "Password"  => "",
        )

        conditions = ""
        if length(userInput) > 1 && userInput[2] == "add"
            action = "Add"

            for field in ["ID","Name","Surname","Gender","Phone","AccessLvl","Password"]
                printstyled("> $field : "; color = :yellow)
                prompts[field] = chomp(readline())
            end

            if Common.decline() return 1; end
            
            conditions = "FOR ID=$(prompts["ID"])"

            sqlCmd = """
                INSERT INTO Profile VALUES 
                ('$(prompts["ID"])','$(prompts["Name"])','$(prompts["Surname"])','$(prompts["Gender"])','$(prompts["Phone"])');
            """
            result = Common.execute(connection, sqlCmd, accessLvl, false)
            if result == 1 return 1; end

            sqlCmd = """
                INSERT INTO Access VALUES 
                ('$(prompts["ID"])','$(prompts["AccessLvl"])');
            """
            result = Common.execute(connection, sqlCmd, accessLvl, false)
            if result == 1 return 1; end

            sqlCmd = """
                INSERT INTO Authentication VALUES 
                ('$(prompts["ID"])','$(prompts["Password"])');
            """
            result = Common.execute(connection, sqlCmd, accessLvl, false)
            if result == 1 return 1; end

        elseif length(userInput) > 1 && userInput[2] == "edit"
            action = "Edit"
            printstyled("Enter Employee ID you want to edit: "; color = :yellow)
            id = chomp(readline())
            printstyled("Enter == to leave the field unchanged\n"; color = :red)

            prompts = ["Name","Surname","Gender","Phone","AccessLvl","Password"]
            attributes = ["fName","lName","gender","phone","accessLvl","password"]
            values = Dict()

            for i in 1:length(prompts)
                printstyled("> $(prompts[i]) : "; color = :yellow)
                data = chomp(readline())
                if data in ["==", ""] continue; end

                values[attributes[i]] = data
            end

            if Common.decline() return 1; end

            sqlProfile = "UPDATE Profile SET "
            updateProfile = false
            for key in keys(values)
                if key in ["fName","lName","gender","phone"]
                    sqlProfile *= "$key = '$(values[key])', "
                    updateProfile = true
                end
            end
            sqlProfile = sqlProfile[1:end-2] * " WHERE ID=$id"
            if updateProfile
                result = Common.execute(connection, sqlProfile, accessLvl, false)
                if result == 1 return 1; end
            end

            if "accessLvl" in keys(values)
                sqlCmd = "UPDATE Access SET accessLvl = '$(values["accessLvl"])' WHERE ID = $id ;"
                result = Common.execute(connection, sqlCmd, accessLvl, false)
                if result == 1 return 1; end
            end

            if "password" in keys(values)
                sqlCmd = "UPDATE Authentication SET password = '$(values["password"])' WHERE ID = $id ;"
                result = Common.execute(connection, sqlCmd, accessLvl, false)
                if result == 1 return 1; end
            end

            conditions = "FOR ID=$id"

        elseif length(userInput) > 1 && userInput[2] == "remove"
            action = "Remove"
            printstyled("Enter Emplyee ID to delete: "; color = :yellow)
            id = chomp(readline())

            if Common.decline() return 2; end
            
            sqlCmd = "DELETE FROM Authentication WHERE ID = $id;"
            result = Common.execute(connection, sqlCmd, accessLvl, false)
            if result == 1 return 1; end

            sqlCmd = "DELETE FROM Access WHERE ID = $id;"
            result = Common.execute(connection, sqlCmd, accessLvl, false)
            if result == 1 return 1; end

            sqlCmd = "DELETE FROM Profile WHERE ID = $id;"
            result = Common.execute(connection, sqlCmd, accessLvl, false)'
            if result == 1 return 1; end

            conditions = "FOR ID=$id"
            
        else
            action = "View"

            password = (("", ""), ("AU.password, ", "JOIN Authentication AS AU ON P.ID = AU.ID"))

            (passCondition, conditions) = _decode(userInput)

            sqlCmd = """SELECT  P.ID, A.accessLvl, $(password[passCondition][1]) P.fName, P.lName, P.gender, P.phone
                FROM Profile AS P JOIN Access AS A ON P.ID = A.ID
                $(password[passCondition][2]) $conditions ;
            """ 
            result = Common.execute(connection, sqlCmd, accessLvl, false)
            if result == 1 return 1; end

            conditions = conditions == "" ? "ALL" : conditions

            _print_result(result, passCondition==2)
        end
        Common.flip_exec_db(false, connection) # switch back to flight_db

        return ["staff", action, conditions]
    end
end
