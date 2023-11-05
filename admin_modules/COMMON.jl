#? common functions for different modules
module Common
    using MySQL
    using DBInterface
    
    include("../interface_library.jl"); using .Lib
    export table, view, all_views, enter_a_table, primary_key, confirm, flip_exec_db, execute

    #? table names
    tableNames = Dict(
        "plane"    => "Plane",
        "pilot"    => "Pilot",
        "crew"     => "Crew",
        "flight"   => "Flight",
        "airstaff" => "AirStaff"
    )

    #? view names for helpdesk
    helpdeskView = Dict(
        "plane"    => "HPlane",
        "pilot"    => "HPilot",
        "flight"   => "HFlight"
    )

    #? view names for associates
    associateView = Dict(
        "crew"     => "ACrew",
        "flight"   => "AFlight",
        "airstaff" => "AAirStaff",
    )

    #? defines views for different roles/accessLvl
    users = Dict(
        0 => helpdeskView,
        1 => associateView,
        2 => tableNames, # since manager has access to all
        3 => tableNames  # and so does the executive
    )

    #? returns exact table name from user input
    function table(title)
        if haskey(tableNames, title)
            return tableNames[title]
        end

        Lib.print_error("table not found")
        Lib.print_error("""type "table" to get a list of all tables""")
        return 1
    end

    #? returns exact view name for the specified role/accessLvl
    function view(tableTitle, accessLvl) 
        if haskey(users[accessLvl], tableTitle)
            return users[accessLvl][tableTitle]
        elseif haskey(tableNames, tableTitle)
            return tableNames[tableTitle]
        end

        Lib.print_error("table not found")
        Lib.print_error("""type "table" to get a list of all tables""")
        return 1
    end

    #? returns all views for the specified role/accessLvl
    function all_views(accessLvl)
        allViews = []

        for key in keys(tableNames)
            if haskey(users[accessLvl], key)
                push!(allViews, users[accessLvl][key])
            else
                push!(allViews, tableNames[key])
            end
        end

        return allViews
    end

    #? checks user input for table name
    function enter_a_table(userInput, action, prepositions)
        if length(userInput) == 1
            Lib.print_error("Please specify table to $action data $prepositions.")
            Lib.print_error("""type "? $action" for more information""")
            return 1;
        end
        
        return table(userInput[2])
    end

    #? returns primary key of a table
    function primary_key(table, connection)
        tableInfo = DBInterface.fetch(DBInterface.execute(connection, "DESCRIBE $table;"))

        primaryKey = ""
        for row in tableInfo
            if row[:Key] == "PRI"
                primaryKey = row[:Field]
                break
            end
        end

        return (tableInfo, primaryKey)
    end

    #? asks user for confirmation before executing their request
    function decline()
        printstyled("<!> Confirm Changes [Y/n] : "; color = :red)
        confirm = lowercase(chomp(readline()))

        return confirm == "n"
    end

    #? flips database for executive when required
    function flip_exec_db(control, connection)
        if control
            DBInterface.execute(connection, "SET ROLE rExecutive;");
            DBInterface.execute(connection, "USE control_db;");
        else
            DBInterface.execute(connection, "SET ROLE rManager;");
            DBInterface.execute(connection, "USE flight_db;");
        end
    end

    #? executes commands and handle errors
    function execute(connection, command, accessLvl, fetch)
        try
            result = DBInterface.execute(connection, command)
            
            if fetch 
                return DBInterface.fetch(result)
            end

            return result
            
        catch e
            println("An error occurred: ", e)
        end
    end
end
