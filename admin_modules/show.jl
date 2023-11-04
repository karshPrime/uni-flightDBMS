#? all functions for Show command : MySQL's SELECT command
module Show
    using MySQL
    using DBInterface

    include("COMMON.jl"); using .Common
    include("help.jl"); using .Help
    include("../interface_library.jl"); using .Lib

    export run

    function _decode(userInput, accessLvl)
        tableIDs = Dict(
            "plane"    => 2,
            "pilot"    => 4,
            "crew"     => 6,
            "light"    => 8,
            "airstaff" => 10
        )

        if haskey(tableIDs, userInput[1])
            infoIndex = tableIDs[userInput[1]]
        else
            return 1
        end

        sqlCmd = ""
        for i in 1:length(userInput)
            (perms, trigger, sql) = Help.showDetails[5][infoIndex][1:3]
            if perms <= accessLvl
                if userInput[i] == trigger
                    sqlCmd = Lib.generate_sql(sqlCmd, sql, userInput[i + 1])
                end
            end
        end

        return sqlCmd
    end

    function _add_space(text, count)
        while count > length(text)
            text = "$text "
        end

        return " $text |"
    end

    _nameSpace = Dict(
        "ID"              => (9,  "ID"),
        "airlines"        => (20, "Airlines"),
        "model"           => (25, "Model"),
        "seats"           => (7,  "Seats"),
        "capacity"        => (10, "Capacity"),
        "manufactureYear" => (10, "MadeYear"),
        "journeys"        => (10, "Journeys"),
        "fName"           => (15, "Name"),
        "lName"           => (15, "Surname"),
        "age"             => (5,  "Age"),
        "gender"          => (8,  "Gender"),
        "nationality"     => (17, "Nationality"),
        "flightCount"     => (9,  "Flights"),
        "pilotID"         => (9,  "Pilot"),
        "coPilotID"       => (9,  "CoPilot"),
        "staffCount"      => (10, "StaffNo."),
        "planeID"         => (9,  "Plane"),
        "crewID"          => (9,  "Crew"),
        "departure"       => (17, "Departure"),
        "destination"     => (17, "Destination"),
        "takeOffTime"     => (10, "Time"),
        "takeOffDate"     => (10, "Date"),
        "duration"        => (10, "Duration"),
        "routeType"       => (12, "Route"),
        "hasVIP"          => (5,  "VIP"),
        "hasFood"         => (6,  "Food"),
        "nativeLanguage"  => (15, "Language")
    )

    function _title_details(attributes)
        titles = []
        titleSpace = []
        border = []

        for column in attributes
            info = _nameSpace[column[:Field]]
            push!(titles, info[2])
            push!(border, info[1])
            push!(titleSpace, info[1]-3)
        end

        return (titles, titleSpace, border)
    end

    function _print_result(result, titles, titleSpace, border)
        Lib.draw_border(border)
        Lib.table_head(titles, titleSpace)
        Lib.draw_border(border)

        #println(result)

        for data in result
            row = "|"
            for i in 1:length(data)
                row *= _add_space(data[i], titleSpace[i]+1)
            end
            printstyled("$row\n"; color = :light_cyan)
        end

        Lib.draw_border(border)
    end

    function run(userInput, accessLvl, connection)
        if length(userInput) == 1
            Lib.print_error("Please specify table to select data from.")
            Lib.print_error("""type "? show" for more information""")
            return 1
        end

        view = Common.view(userInput[2], accessLvl)
        if view == 1 return 1; end

        sqlCmd = _decode(userInput, accessLvl)
        if sqlCmd == 1 return 1; end

        sqlCmd = "SELECT * FROM $view $sqlCmd ;"

        attributes = DBInterface.fetch(DBInterface.execute(connection, "DESCRIBE $view;"))
        (titles, titleSpace, border) = _title_details(attributes)

        result = DBInterface.execute(connection, sqlCmd)
        _print_result(result, titles, titleSpace, border)
    end
end
