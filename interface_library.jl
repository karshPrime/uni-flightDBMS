#! common functions for the two interfaces

#? module contains all methods to share to other files
module Lib
    export banner, generate_sql, take_input, print_error

    function banner(user)
        printstyled("  ___                      _    _      _ _                     \n"; color = :cyan)
        printstyled(" / _ \\ _ __   ___ _ __    / \\  (_)_ __| (_)_ __   ___ ___    \n"; color = :cyan)
        printstyled("| | | | '_ \\ / _ | '_ \\  / _ \\ | | '__| | | '_ \\ / _ / __| \n"; color = :cyan)
        printstyled("| |_| | |_) |  __| | | |/ ___ \\| | |  | | | | | |  __\\__ \\  \n"; color = :cyan)
        printstyled(" \\___/| .__/ \\___|_| |_/_/   \\_|_|_|  |_|_|_| |_|\\___|___/ \n"; color = :cyan)
        printstyled("      |_|                                               $user \n"; color = :cyan)
    end
 
    #? generate SQL command for passed parameters
    function generate_sql(old_cmd, field, value, cmdlen)
        if length(old_cmd) == cmdlen # length for SELECT statement without conditions
            new_cmd = old_cmd * " WHERE " * field * "=\'" * value * "'"
        else
            new_cmd = old_cmd * " AND " * field * "=\'" * value * "'"
        end
    
        return new_cmd
    end
    
    #? return user input as word array
    function take_input(identify)
        printstyled("\n$identify "; color = :blue)
        userInput = lowercase(readline())

        #? custom split command to have multiworded cities like 'New York' as one element
        inQuotes = false
        currentWord = ""
        result = []

        for char in userInput
            if char == ' ' && !inQuotes
                if currentWord != ""
                    push!(result, currentWord)
                    currentWord = ""
                end
            elseif char == '\''
                inQuotes = !inQuotes
                if currentWord != ""
                    push!(result, currentWord)
                    currentWord = ""
                end
            else
                currentWord *= string(char)
            end
        end
    
        if currentWord != ""
            push!(result, currentWord)
        end
    
        return result
    end
    
    function print_error(prompt)
        printstyled(prompt; color = :red)
        println("") # blank line
    end
end
