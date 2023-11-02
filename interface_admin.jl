#! program interface for airline admins
#* admins should only be able to view and edit data that they're permitted to.

include("authenticator.jl")
using .Auth

include("interface_library.jl") # functions with "Lib." prefix
using .Lib

using MySQL
using DBInterface
using Printf

module Scrape
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
        "auth"     => "Authentication"
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
        
        return table(userInput[1])
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

#? all functions for Help command
module Help
    export run, showDetails

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
                (1, "-f", "routeType", "Indicates whether it is a domestic or international flight"),
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
    function _syntax_show(accessLvl)
        print_help(showDetails[1:4], accessLvl)

        listLen = length(showDetails[5])
        if accessLvl != 3
            listLen -= 10
        end

        for i in 1:listLen:2
            table = showDetails[5][i]
            printstyled("Options for $table table:\n"; color = :yellow)
            for (allowed,cmdName, ~, info) in showDetails[5][i+1]
                if allowed <= accessLvl
                    print("  $cmdName")
                    spaceCounter = length(cmdName)
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
    using Printf
    export run

    function _decode(rawInput, accessLvl)
        flightTables = ["AirStaff","Crew","Flight","Pilot","Plane"]
        controlTables = ["Access","Authentication","Logs","Profil"]
        cmds = []
        
        if length(rawInput) == 1
            printstyled("All Flight Tables:\n"; color = :yellow)
            for table in flightTables
                printstyled("  $table\n"; color = :light_cyan)
            end

            if accessLvl == 3 #* also show control tables if exec
                printstyled("All Control Tables:\n"; color = :yellow)
                for table in controlTables
                    printstyled("  $table\n"; color = :light_cyan)
                end
            end

            cmds = [1]
        else
            if length(rawInput) > 1
                tableName = Scrape.table(rawInput[2])
                cmds = [tableName]
            elseif accessLvl == 3
                cmds = vcat(flightTables, controlTables)
            else
                cmds = flightTables
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

    function run(userInput, accessLvl, connection)
        tableTitles = _decode(userInput, accessLvl)

        if tableTitles[1] == 1 return 1; end;

        if userInput[2] == "count"
            for title in tableTitles
                fullCmd = "SELECT COUNT(*) FROM " * title
                result = DBInterface.fetch(DBInterface.execute(connection, fullCmd))
                _print_result_count(result)
            end

        elseif userInput[2] == "about"
            cmdHead = "DESCRIBE "
            for title in tableTitles
                fullCmd = "DESCRIBE " * title
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

    function _print_result(data, access)
        #TODO error handling
    end

    function run(userInput, accessLvl, connection)
        table = Scrape.enter_a_table(userInput, "add", "to", accessLvl)
        if table == 1 return 1; end

        attributes = DBInterface.fetch(DBInterface.execute(connection, "DESCRIBE $table;"))
        
        data = Dict{String, String}()
        
        for column in attributes
            column_name = column[:Field]
            print("> $column_name : ")
            value = chomp(readline())
            data[column_name] = value
        end
        
        columns = join(keys(data), ", ")
        values = join(values(data), ", ")
        
        sqlCmd = """INSERT INTO $table_name ($columns) VALUES ("$values");"""
        DBInterface.execute(connection, sqlCmd)

        _print_result(result, accessLvl)
    end
end

#? all functions for Edit command : MySQL's UDPATE command
module Edit
    export run

    function _print_result(data, access)
        #TODO error handle prompt
    end

    function run(userInput, accessLvl, connection)
        table = Scrape.enter_a_table(userInput, "edit", "in", accessLvl)
        if table == 1 return 1; end

        (tableInfo, primaryKey) = Scrape.primary_key(table, connection)

        # Prompt for the entry ID to modify
        println("Enter $primaryKey for entry you wish to modify: ")
        id = chomp(readline())

        # Prompt for changes
        for row in tableInfo
            println("> $row[:Field]: ")
            newData = chomp(readline())
            sqlCmd = "UPDATE $table SET $row[:Field]=   '$newData' WHERE $primaryKey = $id;"
            
            actionLog = DBInterface.execute(connection, sqlCmd)

            _print_result(result, accessLvl)
        end
    end
end

#? all functions for Remove command : MySQL's DELETE command
module Remove
    export run

    function _print_result(data, access)
        #TODO error handle prompt
    end

    function run(userInput, accessLvl, connection)
        table = Scrape.enter_a_table(userInput, "remove", "from", accessLvl)
        if table == 1 return 1; end
        
        (~, primaryKey) = Scrape.primary_key(table, connection)
        println("Enter $primaryKey for entry you wish to delete: ")
        id = chomp(readline())
        sqlCmd = "DELETE FROM $tableName WHERE $primaryKey = $id;"

        action = DBInterface.execute(connection, sqlCmd)

        _print_result(action, accessLvl)
    end
end

#? all functions for Show command : MySQL's SELECT command
module Show
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
        for prompt in userInput[2:end]
            (perms, trigger, sql) = Help.showDetails[5][infoIndex][1:3]
            if perms <= accessLvl
                if prompt == trigger
                    sqlCmd = Lib.generate_sql(sqlCmd, sql, userInput[i + 1])
                end
            end
        end

        return sqlCmd
    end

    function run(userInput, accessLvl, connection)
        if length(userInput) == 1
            Lib.print_error("Please specify table to select data from.")
            Lib.print_error("""type "? show" for more information""")
            return 1
        end

        view = Scrape.view(userInput[2], accessLvl)
        if view == 1 return 1; end

        sqlCmd = _decode(userInput[2:end], accessLvl)
        if sqlCmd == 1 return 1; end

        sqlCmd = "SELECT * FROM $view" * sqlCmd
        result = DBInterface.fetch(DBInterface.execute(connection, sqlCmd))

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
    printstyled("\nUser ID  > "; color = :green)
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
        "table"  => Table,
        "add"    => Add,
        "edit"   => Edit,
        "remove" => Remove,
        "show"   => Show
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
            printstyled("\nWelcome $username :.:.:.:.:.:\n"; color = :yellow)
            break #! stop loop if login is successful
        end
    end

    while true
        userInput = Lib.take_input("[$username | $accessLvl] \$") #* [Bob Dayne | Manager] $ 

        if length(userInput) > 0 #* ignore blank input
            if userInput[1] == "x" #* quit
                DBInterface.close!
                printstyled("\nGoodbye $username...\n"; color = :light_blue)
                println("logged out\n")
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
