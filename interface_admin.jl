#! program interface for airline admins
#* admins should only be able to view and edit data that they're permitted to.

include("authenticator.jl")
using .Auth

include("interface_library.jl") # functions with "Lib." prefix
using .Lib

#? login prompt
function login()
    printstyled("User ID  > "; color = :green)
    username = readline()
    printstyled("Password > "; color = :green)
    password = readline()

    return (username, password)
end

#? print help menu showing all possible commands for the loggedin user
function help_menu(user)
    #* helpdesk = 0 | associate = 1 | manager = 2 | executive = 3
    helpDetails = (
        0, "?", "{OPTION}", 
        [   
            "View program manual.", 
            "Enter Option for more comprehensive guide."
        ],
        [
            (0, "about", "Get general information"),
            (1, "add", "Add entry to a table"),
            (2, "edit", "Modify existing entry in a table"),
            (2, "remove", "Remove entries from a table"),
            (0, "count", "Get entry count"),
            (0, "show", "View specific entries")
        ]
    )

    aboutDetails = (
        0, "about", "{TABLE NAME} {cmd}", 
        [
            "Lists all information about the specified table.", 
            "If no table is specified, it lists information for all tables."
        ], []
    )

    addDetails = (
        1, "add", "[table]", 
        [
            "Prompts to add an entry to the specified table."
        ], []
    )

    editDetails = (
        1, "edit", "[table] for [condition] with [changes] {FORCE}",
        [
            "Edits the table with the specified changes for entries that match the condition.",
            "Use FORCE to skip confirmation."
        ], []
    )

    removeDetails = (
        2, "remove", "[table] for [condition|ALL] {FORCE}", 
        [
            "Deletes either all entries in the specified table or entries that match the specified conditions.",
            "Use FORCE to skip confirmation."
        ], []
    )

    countDetails = (
        0, "count", "{table}", 
        [
            "Lists the number of entries in the specified table.",
            "If no table is specified, it lists the number of entries in each table."
        ], []
    )

    showDetails = (
        0, "show", "[table] {OPTION [ARGUMENT]}", 
        "Displays all entries in a table based on the stated conditions.",
        "Plane",
        [
            (0, "ID", "Plane ID"),
            (0, "airlines", "Airline to which the plane belongs"),
            (0, "model", "Plane model"),
            (0, "seats", "Total number of seats in the plane"),
            (0, "capacity", "Luggage capacity of the plane"),
            (1, "makeyear", "Year the plane was launched"),
            (1, "journeys", "Total number of journeys the plane has taken")
        ],
        "Pilot",
        [
            (0, "ID", "Pilot ID"),
            (0, "fname", "Pilot's first name"),
            (0, "lname", "Pilot's last name"),
            (0, "age", "Pilot's age"),
            (0, "gender", "Pilot's gender"),
            (1, "nation", "Pilot's nationality"),
            (1, "count", "Number of flights the pilot has conducted")
        ],
        "Crew",
        [
            (0, "ID", "Crew ID"),
            (0, "pilot", "ID of the Pilot leading the crew"),
            (0, "copilot", "ID of the Co-Pilot in the crew"),
            (0, "count", "Total number of staff members on the flight")
        ],
        "Flight",
        [
            (0, "ID", "Flight ID"),
            (0, "planeID", "ID of the plane for this flight"),
            (0, "crewID", "ID of the crew assisting the flight"),
            (0, "departure", "Departure location"),
            (0, "destination", "Destination location"),
            (0, "takeOffTime", "Departure time"),
            (0, "takeOffDate", "Departure date"),
            (0, "duration", "Journey duration"),
            (1, "route", "Indicates whether it is a domestic or international flight"),
            (1, "hasvip", "Indicates whether a VIP is taking this flight"),
            (0, "hasfood", "Indicates whether the flight serves food")
        ],
        "AirStaff",
        [
            (0, "ID", "Staff ID"),
            (0, "crewID", "Crew to which they belong"),
            (0, "fname", "Staff's first name"),
            (0, "lname", "Staff's last name"),
            (0, "age", "Staff's age"),
            (0, "gender", "Staff's gender"),
            (0, "language", "Staff's native language")
        ],
        "Without providing an option, all entries will be displayed."
    )
end


#? Understand user command
function understand_input(input, user)
    words = break_input(input)
end

#? execute the requested MySQL command
function run_cmd(command, connection)
    printstyled(command; color = :green)
    println("") # blank line
    #println(connection)
end

#? the main function
function main()
    Lib.banner("Admin") # print program banner

    while true # user cannot continue without successful login
        credentials = login()
        status = Auth.authenticate(credentials)
        
        if status == 1
            printstyled("< ! AUTHENTICATION FAIL ! >\n\n"; color = :red)
        else
            (connection, username, accessLvl) = Auth.connect(credentials[1], status)
            printstyled("Welcome $usernname!"; color = :yellow)
            break # stop loop if login was successful
        end
    end

    while true
        user_input = Lib.take_input("[$username | $accessLvl]") # [Bob Dayne|Manager]

        if user_input == "x"
            printstyled("Goodbye~\n"; color = :light_blue)
            break
        end

        if user_input == "?"
            help_menu(accessLvl)
            continue
        end

        sql_cmd = understand_input(user_input, accessLvl)
        
        if sql_cmd[1] == true
            run_cmd(sql_cmd[2], "connection")
        else
            Lib.print_error(sql_cmd[2])
        end
    end
end

main()
