#! program interface for airline admins
#* admins should only be able to view and edit data that they're permitted to.

include("authenticator.jl")
using .Auth

include("interface_library.jl") # functions with "Lib." prefix
using .Lib

#? all functions for Help command
module Help
    export run

    #? beautify help dialogue
    function _syntax(cmd, access)
        printstyled("Usage: "; color = :yellow)
        print(cmd[2])
        extra = cmd[3]
        printstyled(" $extra \n"; color = :light_cyan)

        printstyled("\nDescription:\n"; color = :yellow)
        for description in cmd[4]
            println("  $description")
        end

        if length(cmd[5]) < 1; println(""); return; end

        printstyled("Options:\n"; color = :yellow)
        for (allowed, title, info) in cmd[5]
            if allowed <= access
                print("  $title")
                spaceCounter = length(title)
                while spaceCounter < 15
                    spaceCounter +=1
                    print(" ")
                end
                printstyled(" $info\n"; color = :light_cyan)
            end
        end
        println("")
    end

    #? narrowed down _syntax update for show command
    function _syntax_show(access)
        showDetails = (
            0, "show", "[table] {OPTION [ARGUMENT]}", 
            ["Displays all entries in a table based on the stated conditions."],
            [
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
                    (0, "time", "Departure time"),
                    (0, "date", "Departure date"),
                    (0, "duration", "Journey duration"),
                    (1, "route", "Indicates whether it is a domestic or international flight"),
                    (1, "vip", "Indicates whether a VIP is taking this flight"),
                    (0, "food", "Indicates whether the flight serves food")
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
                ]
            ],
            "Without providing an option, all entries will be displayed."
        )
        print_help(showDetails[1:4], access)

        for i in 1:5
            table = showDetails[5][(i*2)-1]
            printstyled("Options for $table table:\n"; color = :yellow)
            for (allowed, title, info) in showDetails[5][i*2]
                if allowed <= access
                    print("  $title")
                    spaceCounter = length(title)
                    while spaceCounter < 15
                        spaceCounter +=1
                        print(" ")
                    end
                    printstyled(" $info\n"; color = :light_cyan)
                end
            end
            println("")
        end
        printstyled("Note: "; color = :yellow)
        println(showDetails[6])
    end

    #? print help menu showing all possible commands for the loggedin user
    function run(access, option)
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
            1, "edit", "[table] for [condition] with [changes] {FORCE}",
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

        countDetails = (
            0, "count", "{TABLE}", 
            [
                "Lists the number of entries in the specified table.",
                "If no table is specified, it lists the number of entries in each table."
            ]
        )

        #* print help for only the section user specified
        option_map = Dict(
            "table" => tableDetails,
            "add" => addDetails,
            "edit" => editDetails,
            "remove" => removeDetails,
            "count" => countDetails,
            "show" => showDetails,
        )

        if haskey(option_map, option)
            _syntax(option_map[option], access)
        else
            #* same as help without args
            _syntax(helpDetails, access)
        end
    end
end

#? all functions for Table command : MySQL's DESCRIBE TABLE command + count
module Table
    export run

    _flightTables = ["AirStaff","Crew","Flight","Pilot","Plane"]
    _controlTables = ["Access","Authentication","Logs","Profil"]

    function _decode(rawInput, accessLvl)
        cmds = []
        
        if length(rawInput) == 1
            printstyled("All Flight Tables:\n"; color = :yellow)
            for table in _flightTables
                printstyled("  $table\n"; color = :light_cyan)
            end

            if accessLvl == 3 #* also show control tables if exec
                printstyled("All Control Tables:\n"; color = :yellow)
                for table in _controlTables
                    printstyled("  $table\n"; color = :light_cyan)
                end
            end

            cmds = [0]
        else
            if length(rawInput) > 1
                for (index, element) in enumerate(_flightTables)
                    if rawInput[2] == lowercase(element)
                        return [index]
                    end
                end

                for (index, element) in enumerate(_controlTables)
                    if rawInput[2] == lowercase(element)
                        return [index+length(_flightTables)]
                    end
                end

                Lib.print_error("invalid table")
                lib.print_error("""just type "table" to get a list of all tables""")
                return [0]
            else
                cmds = [1,2,3,4,5,6,7,8,9]
            end
        end

        return cmds
    end

    function _print_result_about(data)
        Lib.draw_border([27,5,9,12])
        Lib.table_head(["Field","Null","Key","Default"],[24,4,6,9])
        Lib.draw_border([27,5,9,12])
        for row in data
            field = row[:Field]
            null = coalesce(row[:Null], "Missing") == "NO" ?  " x " : " ✔ "

            default = coalesce(row[:Default], "missing")
            default = default == "missing" ? "null" : join(Char.(default))

            key = if row[:Key] == "PRI"
                "Primary"
            elseif row[:Key] == "MUL"
                "Foreign"
            else
                 "   -"
            end
        
            formatted_row = @sprintf("| %-25s | %-3s | %-7s | %-10s |", 
                field, 
                null, 
                key, 
                default
            )
        
            printstyled(formatted_row, color = :light_cyan)
            println("")  # New line after each row
        end
        Lib.draw_border([27,5,9,12])
    end

    function _print_result_count(data)
        for row in data
            printstyled("Count of Crew: "; color = :yellow)
            count = row[1]
            printstyled("$count\n\n"; color = :light_cyan)
        end
    end

    function _table_title(i)
        if i > 5
            executive_flight(false)
            return _controlTables[cmd]
        end
        
        executive_flight(true)
        return _flightTables[cmd]
    end

    function run(userInput, accessLvl, connection)
        sqlCmds = _decode(userInput, accessLvl)

        if sqlCmds[1] == 0 return; end;

        if userInput[2] == "count"
            for cmd in sqlCmds
                fullCmd = "SELECT COUNT(*) FROM " * _table_title(cmd)
                result = DBInterface.fetch(DBInterface.execute(connection, fullCmd))
                _print_result_count(result)
            end

        elseif userInput[2] == "about"
            cmdHead = "DESCRIBE "
            for cmd in sqlCmds
                fullCmd = "DESCRIBE " * _table_title(cmd)
                result = DBInterface.fetch(DBInterface.execute(connection, fullCmd))
            
                _print_result_about(result)
            end
        else
            Lib.print_error("invalid parameters")
            Lib.print_error("""type "? table" for more information.""")
            return
        end
    end
end

#? all functions for Add command : MySQL's INSERT command
module Add
    export run

    function _attributes(accessLvl)
        @switch accessLvl begin
            0 => return [""]
            1 => return [""]
            2 => return [""]
        end
    end
    
    function _decode(rawInput)
        #
    end

    function _print_result(data, access)
        #
    end

    function run(userInput, accessLvl, connection)
        sqlCmd = _decode(userInput)
        result = DBInterface.fetch(DBInterface.execute(connection, sqlCmd))
        _print_result(result, accessLvl)
    end
end

#? all functions for Edit command : MySQL's UDPATE command
module Edit
    export run

    function _attributes(accessLvl)
        @switch accessLvl begin
            0 => return [""]
            1 => return [""]
            2 => return [""]
        end
    end
    
    function _decode(rawInput)
        #
    end

    function _print_result(data, access)
        #
    end

    function run(userInput, accessLvl, connection)
        sqlCmd = _decode(userInput)
        result = DBInterface.fetch(DBInterface.execute(connection, sqlCmd))
        _print_result(result, accessLvl)
    end
end

#? all functions for Remove command : MySQL's DELETE command
module Remove
    export run

    function _attributes(accessLvl)
        @switch accessLvl begin
            0 => return [""]
            1 => return [""]
            2 => return [""]
        end
    end
    
    function _decode(rawInput)
        #
    end

    function _print_result(data, access)
        #
    end

    function run(userInput, accessLvl, connection)
        sqlCmd = _decode(userInput)
        result = DBInterface.fetch(DBInterface.execute(connection, sqlCmd))
        _print_result(result, accessLvl)
    end
end

function executive_flight(motetoflight)
    if motetoflight
        DBInterface.execute(wire, "SET ROLE rManager;");
        DBInterface.execute(wire, "USE flight_db;");
    else
        DBInterface.execute(wire, "SET ROLE rExecutive;");
        DBInterface.execute(wire, "USE control_db;");
    end
end

#? login prompt
function login()
    printstyled("User ID  > "; color = :green)
    userid = readline()
    printstyled("Password > "; color = :red)
    userpass = readline()

    return (userid, userpass)
end

#? the main function
function main()
    Lib.banner("Admin") #* print program banner

    #? define dictionary for all sql command modules
    modules = Dict(
        "about"  => About,
        "add"    => Add,
        "edit"   => Edit,
        "remove" => Remove,
        "count"  => Count
    )

    #* initialising variables
    (connection, username, accessLvl) = ("", "", "")

    while true #! user cannot continue without successful login
        (userid, userpass) = login()
        token = Auth.authenticate(userid, userpass) #* session token
        
        if token == 1
            print_error("AUTHENTICATION FAIL")
        else
            (connection, username, accessLvl) = Auth.connect(userid, token)
            printstyled("Welcome $username"; color = :yellow)
            break #! stop loop if login is successful
        end
    end

    while true
        userInput = Lib.take_input("[$username | $accessLvl]") #* [Bob Dayne | Manager] 

        if length(userInput) > 0 #* ignore blank input
            if userInput[1] == "x" #* quit
                printstyled("Goodbye $username...\n"; color = :light_blue)
                println("logged out")
                break
            end

            if userInput[1] == "?" #* help
                Help.run(accessLvl, length(userInput) > 1 ? userInput[2] : " ")
                continue
            end

            if haskey(modules, userInput[1])
                modules[userInput].run(userInput, accessLvl, connection)
            else
                Lib.print_error("command not found")
            end
        end
    end
end

main()
