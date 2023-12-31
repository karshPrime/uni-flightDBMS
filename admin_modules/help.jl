#? all functions for Help command
module Help
    include("COMMON.jl"); using .Common
    
    export run, showDetails

    #? beautify help dialogue
    function _syntax(cmd, accessLvl)
        printstyled("\nUsage: "; color = :yellow)
        print(cmd[2])
        extra = cmd[3]
        printstyled(" $extra \n"; color = :light_cyan)

        printstyled("\nDescription:\n"; color = :yellow)
        for description in cmd[4]
            println("  $description")
        end

        if length(cmd) < 5; println(""); return; end

        printstyled("\nOptions:\n"; color = :yellow)
        for (allowed, title, info) in cmd[5]
            if allowed <= accessLvl
                print("  $title")
                for i in length(title):10
                    print(" ")
                end
                printstyled(" $info\n"; color = :light_cyan)
            end
        end
        println("")
    end

    showDetails = (
        0, "show", "[table] {OPTION [ARGUMENT]}", 
        ["Displays all entries in a table based on the stated conditions."],
        [
            "Plane",
            [
                (0, "-id", "ID", "Plane ID"),
                (0, "-a", "airlines", "Airline to which the plane belongs"),
                (0, "-m", "model", "Plane model"),
                (0, "-s", "seats", "Total number of seats in the plane"),
                (0, "-c", "capacity", "Luggage capacity of the plane"),
                (1, "-y", "manufactureYear", "Year the plane was launched"),
                (1, "-j", "journeys", "Total number of journeys the plane has taken")
            ],
            "Pilot",
            [
                (0, "-id", "ID", "Pilot ID"),
                (0, "-fn", "fName", "Pilot's first name"),
                (0, "-ln", "lName", "Pilot's last name"),
                (0, "-a", "age", "Pilot's age"),
                (0, "-g", "gender", "Pilot's gender"),
                (1, "-n", "nationality", "Pilot's nationality"),
                (1, "-c", "flightCount", "Number of flights the pilot has conducted")
            ],
            "Crew",
            [
                (0, "-id", "ID", "Crew ID"),
                (0, "-p", "pilotID", "ID of the Pilot leading the crew"),
                (0, "-c", "coPilotID", "ID of the Co-Pilot in the crew"),
                (0, "-s", "staffCount", "Total number of staff members on the flight")
            ],
            "Flight",
            [
                (0, "-id", "ID", "Flight ID"),
                (0, "-p", "planeID", "ID of the plane for this flight"),
                (0, "-c", "crewID", "ID of the crew assisting the flight"),
                (0, "-s", "departure", "Departure/Start location"),
                (0, "-g", "destination", "Destination/Goal location"),
                (0, "-t", "takeOffTime", "Departure time"),
                (0, "-d", "takeOffDate", "Departure date"),
                (0, "-j", "duration", "Journey duration"),
                (1, "-r", "routeType", "Indicates whether it is a domestic or international flight"),
                (1, "-vip", "hasVIP", "Indicates whether a VIP is taking this flight"),
                (0, "-f", "hasFood", "Indicates whether the flight serves food")
            ],
            "AirStaff",
            [
                (0, "-id", "ID", "Staff ID"),
                (0, "-c", "crewID", "Crew to which they belong"),
                (0, "-fn", "fName", "Staff's first name"),
                (0, "-ln", "lName", "Staff's last name"),
                (0, "-a", "age", "Staff's age"),
                (0, "-g", "gender", "Staff's gender"),
                (0, "-l", "nativeLanguage", "Staff's native language")
            ]            
        ],
        "Without providing an option, all entries will be displayed."
    )

    #? narrowed down _syntax update for show command
    function _syntax_show(accessLvl, toPrint)
        _syntax(showDetails[1:4], accessLvl)
    
        for i in 1:2:length(showDetails[5])
            table = showDetails[5][i]
            if toPrint != "all" && table != toPrint
                continue
            end
    
            printstyled("Options for $table table:\n"; color = :yellow)
            for (allowed, cmdName, ~, info) in showDetails[5][i+1]
                if allowed > accessLvl
                    continue
                end
                
                print("  $cmdName")
                for i in length(cmdName):10
                    print(" ")
                end

                printstyled(" $info\n"; color = :light_cyan)
            end
            println("")
        end
        if toPrint == "all"
            printstyled("Note: "; color = :yellow)
            println(showDetails[6])
        end 
    end

    #? print help menu showing all possible commands for the loggedin user
    function run(accessLvl, userInput)
        #* helpdesk = 0 | associate = 1 | manager = 2 | executive = 3
        helpDetails = (
            0, "?", "{OPTION}", 
            [   
                "View program manual.", 
                "Enter Option for more comprehensive guide."
            ],
            [
                (0, "table", "Get general information"),
                (1, "add", "Add entry to a table"),
                (1, "edit", "Modify existing entry in a table"),
                (2, "remove", "Remove entries from a table"),
                (0, "show", "View specific entries"),
                (3, "staff", "Manage employeed staff"),
                (3, "logs", "View system logs")
            ]
        )

        tableDetails = (
            0, "table", "(about|count) {TABLE NAME}", 
            [
                "Displays information about either all tables or a specific table.",
                "With no argument it lists all tables in the database."
            ],
            [
                (0, "about", "Get general description of a table"),
                (0, "count", "Get a count of number of entries in a table")
            ]
        )

        addDetails = (
            1, "add", "[table]", 
            [
                "Prompts to add an entry to the specified table."
            ]
        )

        editDetails = (
            1, "edit", "[table]",
            [
                "Edits the table with the specified changes for entries that match the condition.",
                "Use FORCE to skip confirmation."
            ]
        )

        removeDetails = (
            2, "remove", "[table] for [condition|ALL] {FORCE}", 
            [
                "Deletes either all entries in the specified table or entries that match the specified conditions.",
                "Use FORCE to skip confirmation."
            ]
        )

        staffDetails = (
            3, "staff", "{OPTION}",
            [
                "Displays employed staff members' records.",
                "With no argument it lists all records."
            ],
            [
                (3, "search", "Look for a specific employee with their ID"),
                (3, "department", "Look for all employees from a department"),
                (3, "password", "Get a user's password.")
            ]
        )

        logsDetails = (
            3, "logs", "{OPTION}",
            [
                "Prints all system logs.",
                "Use options to filter data."
            ],
            [
                (3, "on", "Actions performed on a specific date [yyyy-mm-dd]"),
                (3, "at", "Actions executed at a specific time [hh:rr]"),
                (3, "by", "logs of a certain employee"),
                (3, "action", "logs for a certain action"),
                (3, "record", "logs for actions in a specific record")
            ]
        )

        #* print help for only the section user specified
        option_map = Dict(
            "table"  => tableDetails,
            "add"    => addDetails,
            "edit"   => editDetails,
            "remove" => removeDetails,
            "show"   => showDetails,
            "staff"  => staffDetails,
            "logs"   => logsDetails
        )

        option = length(userInput) > 1 ? userInput[2] : " "

        if option == "show"
            table = "all"

            if length(userInput) > 2
                table = Common.table(userInput[3])
                if table == 1 return 1; end;
            end
            _syntax_show(accessLvl, table)

        elseif haskey(option_map, option)
            _syntax(option_map[option], accessLvl)

        else
            #* same as help without args
            _syntax(helpDetails, accessLvl)
        end
    end
end
