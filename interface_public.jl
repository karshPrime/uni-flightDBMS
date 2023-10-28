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
function understand_input(input)
    words = Lib.break_input(input)

    if length(words) == 0
        return (false, "") # print nothing for blank input but accept that as error
    end

    if words[1] == "flights"
        sql_cmd = "SELECT departure, destination, takeOffTime, takeOffDate, duration, hasFood FROM Flight"

        for i in 1:length(words)
            if words[i] == "from" && i < length(words)
                sql_cmd = Lib.generate_sql(sql_cmd, "departure", words[i + 1], 86)
            elseif words[i] == "to" && i < length(words)
                sql_cmd = Lib.generate_sql(sql_cmd, "destination", words[i + 1], 86)
            elseif words[i] == "on" && i < length(words)
                sql_cmd = Lib.generate_sql(sql_cmd, "takeOffDate", words[i + 1], 86)
            elseif words[i] == "with" && i < length(words) && words[i + 1] == "food"
                sql_cmd = Lib.generate_sql(sql_cmd, "hasFood", "1", 86)
            elseif words[i] == "without" && i < length(words) && words[i + 1] == "food"
                sql_cmd = Lib.generate_sql(sql_cmd, "hasFood", "0", 86)
            end
        end

        sql_cmd = sql_cmd * ';'
        return (true, sql_cmd, true)

    elseif words[1] == "planes"
        sql_cmd = "SELECT ID, airlines, model FROM Plane"
        if length(words) > 1
            sql_cmd = sql_cmd * " WHERE ID='" * words[1+1] * "';"
        end

        return (true, sql_cmd, false)

    else
        return (false, "invalid input")
    end
end

#? Understand user command
function run_cmd(command, connection, fTable)
end

#? the main function
function main()
    connection = Auth.public()
    
    Lib.banner("Public")
    printstyled("\nPress [?] for Help and [X] to Quit.\n"; color = :red)

    while true
        user_input = Lib.take_input('$')
        
        if user_input == "x"
            printstyled("Goodbye~\n"; color = :light_blue)
            break
        end

        if user_input == "?"
            help_menu()
            continue
        end

        sql_cmd = understand_input(user_input)

        if sql_cmd[1] == true
            run_cmd(sql_cmd[2], connection, sql_cmd[3])
        else
            Lib.print_error(sql_cmd[2])
        end
    end
end

main()
