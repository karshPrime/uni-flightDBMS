#! program interface for the general public.
#* public should only have view access for certain attributes.

using MySQL
using DBInterface
using Printf

include("authenticator.jl")
using .Auth

include("interface_library.jl")
using .Lib

#? print help menu showing all possible commands
function help_menu()
    prompt = """
    Available Commands:
    
    1. `flights`: Show all available flights.
       Example: `flights`
    
    2. `flights on yyyy-mm-dd`: Show all flights on a specific date.
       Example: `flights on 2023-10-15`
    
    3. `flights to "location"`: Show all flights going to a specified location.
       Example: `flights to Paris`
    
    4. `flights from "location"`: Show all flights departing from a specified location.
       Example: `flights from New York`
    
    5. `flights with Food`: Show all flights serving food.
       Example: `flights with Food`
    
    6. `flights without Food`: Show all flights not serving food.
       Example: `flights without Food`
    
    7. `planes` : Show the list of all planes.
       Example: `planes`
    
    8. `plane {id}`: Show details of a specific plane by its ID.
       Example: `plane 123`

    
    You can combine commands for more specific queries:
    
    - To find flights on a specific date to a particular location that serve food:
      Example: `flights on 2023-10-15 to "Paris" with Food`
    """

    printstyled(prompt; color = :light_green)
end

#? Understand user command
function understand_input(userInput)
    if userInput[1] == "flights"
        sqlCmd = "SELECT departure, destination, takeOffTime, takeOffDate, duration, hasFood FROM Flight"

        for i in 1:length(userInput)
            if userInput[i] == "from"
                sqlCmd = Lib.generate_sql(sqlCmd, "departure", userInput[i + 1], 86)
            elseif userInput[i] == "to"
                sqlCmd = Lib.generate_sql(sqlCmd, "destination", userInput[i + 1], 86)
            elseif userInput[i] == "on"
                sqlCmd = Lib.generate_sql(sqlCmd, "takeOffDate", userInput[i + 1], 86)
            elseif userInput[i] == "with" && userInput[i + 1] == "food"
                sqlCmd = Lib.generate_sql(sqlCmd, "hasFood", "1", 86)
            elseif userInput[i] == "without" && userInput[i + 1] == "food"
                sqlCmd = Lib.generate_sql(sqlCmd, "hasFood", "0", 86)
            end
        end

        sqlCmd = sqlCmd * ';'
        return sqlCmd

    elseif userInput[1] == "planes"
        sqlCmd = "SELECT ID, airlines, model FROM Plane"
        if length(userInput) > 1
            sqlCmd = sqlCmd * " WHERE ID='" * userInput[1+1] * "';"
        end

        return sqlCmd

    else
        return 1
    end
end

#? Execute the corresponding user command
function run_cmd(command, connection, fTable)
    #! FOR DEBUGING
    #printstyled(command; color = :green)
    #println("\n\n") # blank line
    
    result = DBInterface.fetch(DBInterface.execute(connection, command))
    
    if fTable == true
        Lib.draw_border([17,17,10,12,10,7])
        Lib.table_head(["Departure","Destination","Take Off","Date","Duration","Food"],[14,14,7,9,7,4])
        Lib.draw_border([17,17,10,12,10,7])

        for row in result
            departure = row[:departure]
            destination = row[:destination]
            takeOffTime = row[:takeOffTime]
            takeOffDate = row[:takeOffDate]
            duration = row[:duration]
            hasFood = row[:hasFood] == 1 ? true : false

            formatted_row = @sprintf("| %-15s | %-15s | %-8s | %-10s | %-8s | %-5s |", 
                departure, 
                destination, 
                takeOffTime, 
                takeOffDate, 
                duration, 
                hasFood ? "True" : "False"
            )

            printstyled(formatted_row, color = :light_cyan)
            println("")  # New line after each row
        end
        Lib.draw_border([17,17,10,12,10,7])
    else
        Lib.draw_border([7,22,25])
        Lib.table_head(["ID","Airlines","Model"],[4,19,22])
        Lib.draw_border([7,22,25])

        for row in result
            planeid = row[:ID]
            airlines = row[:airlines]
            model = row[:model]

            formatted_row = @sprintf("| %-5s | %-20s | %-23s |", planeid, airlines, model)
            printstyled(formatted_row, color = :light_cyan)
            println("")
        end
        Lib.draw_border([7,22,25])
    end
end

#? the main function
function main()
    connection = Auth.public()
    
    Lib.banner("Public")
    printstyled("\nPress [?] for Help and [X] to Quit.\n"; color = :red)

    while true
        userInput = Lib.take_input('$')

        if length(userInput) > 0
            if userInput[1] == "x"
                printstyled("Goodbye~\n"; color = :light_blue)
                break
            end

            if userInput[1] == "?"
                help_menu()
                continue
            end

            sqlCmd = understand_input(userInput)

            if sqlCmd == 1
                Lib.print_error("invalid input")
            else
                run_cmd(sqlCmd, connection, userInput[1]=="flights")
            end
        end
    end
end

main()
