#? all functions for Show command : MySQL's SELECT command
module Show
    using Dates

    include("COMMON.jl"); using .Common
    include("help.jl"); using .Help
    include("../interface_library.jl"); using .Lib

    export run

    #? understand user input and generate corresponding sql
    function _decode(userInput, accessLvl)
        tableIDs = Dict(
            "plane"    => 2,
            "pilot"    => 4,
            "crew"     => 6,
            "flight"   => 8,
            "airstaff" => 10
        )

        if haskey(tableIDs, userInput[2])
            infoIndex = tableIDs[userInput[2]]
        else
            return 1
        end

        sqlCmd = ""
        for i in 1:(length(userInput)-1)
            for cmdRow in Help.showDetails[5][infoIndex]
                (perms, trigger, sql) = cmdRow[1:3]
                if perms <= accessLvl
                    if userInput[i] == trigger
                        sqlCmd = Lib.generate_sql(sqlCmd, sql, userInput[i + 1])
                    end
                end
            end
        end

        return sqlCmd
    end

    #? add spaces to the text making it of same len
    function _add_space(text, count)
        if text isa Dates.Time
            text = Dates.format(text, "HH:MM:SS")
        elseif text isa Dates.Date
            text = Dates.format(text, "yyyy-mm-dd")
        elseif text isa Missing
            text = "N/A" 
        end

        while count > length(text)
            text = "$text "
        end

        return " $text |"
    end

    #? spaces and heading for attributes
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
        "takeOffDate"     => (12, "Date"),
        "duration"        => (10, "Duration"),
        "routeType"       => (15, "Route"),
        "hasVIP"          => (5,  "VIP"),
        "hasFood"         => (6,  "Food"),
        "nativeLanguage"  => (15, "Language")
    )

    #? get all columums from the raw attributes result
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

    #? display formatted result
    function _print_result(result, titles, titleSpace, border)
        Lib.draw_border(border)
        Lib.table_head(titles, titleSpace)
        Lib.draw_border(border)

        for data in result
            row = "|"
            for i in 1:length(data)
                row *= _add_space(data[i], titleSpace[i]+1)
            end
            printstyled("$row\n"; color = :light_cyan)
        end

        Lib.draw_border(border)
    end

    #? command run
    function run(userInput, accessLvl, connection)
        if length(userInput) == 1
            Lib.print_error("Please specify table to select data from.")
            Lib.print_error("""type "? show" for more information""")
            return 1
        end

        view = Common.view(userInput[2], accessLvl)
        if view == 1 return 1; end

        conditions = _decode(userInput, accessLvl)
        if conditions == 1 return 1; end

        sqlCmd = "SELECT * FROM $view $conditions ;"

        attributes = Common.execute(connection, "DESCRIBE $view;", accessLvl)
        (titles, titleSpace, border) = _title_details(attributes)

        result = Common.execute(connection, sqlCmd, accessLvl)
        if result == 1 return 1; end

        _print_result(result, titles, titleSpace, border)
        return ["View", view, conditions=="" ? "ALL" : replace(conditions[8:end], "'" => "")]
    end
end
