#? common functions for different modules
module Common
    using MySQL
    using DBInterface
    
    include("../interface_library.jl"); using .Lib
    export table, view, all_views, enter_a_table, primary_key

    tableNames = Dict(
        "plane"    => "Plane",
        "pilot"    => "Pilot",
        "crew"     => "Crew",
        "flight"   => "Flight",
        "airstaff" => "AirStaff"
    )

    helpdeskView = Dict(
        "plane"    => "HPlane",
        "pilot"    => "HPilot",
        "flight"   => "HFlight"
    )

    associateView = Dict(
        "crew"     => "ACrew",
        "flight"   => "AFlight",
        "airstaff" => "AAirStaff",

    )

    executiveView = Dict(
        "crew"     => "Plane",
        "flight"   => "Pilot",
        "airstaff" => "Crew",
        "plane"    => "Flight",
        "pilot"    => "AirStaff",
        "logs"     => "Logs",
        "profile"  => "Profile",
        "access"   => "Access",
        "authentication"     => "Authentication"
    )

    users = Dict(
        0 => helpdeskView,
        1 => associateView,
        2 => tableNames, # since manager has access to all
        3 => executiveView,
    )

    function table(title)
        if haskey(tableNames, title)
            return tableNames[title]
        end

        Lib.print_error("table not found")
        Lib.print_error("""type "table" to get a list of all tables""")
        return 1
    end

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

    function all_views(accessLvl)
        allViews = []

        for key in keys(tableNames)
            if haskey(users[accessLvl], key)
                push!(allViews, users[accessLvl][key])
            else
                push!(allViews, tableNames[key])
            end
        end

        if accessLvl == 3
            for key in keys(executiveView)
                push!(allViews, executiveView[key])
            end
        end

        return allViews
    end

    function enter_a_table(userInput, action, prepositions)
        if length(userInput) == 1
            Lib.print_error("Please specify table to $action data $prepositions.")
            Lib.print_error("""type "? $action" for more information""")
            return 1;
        end
        
        return table(userInput[2])
    end

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
end
