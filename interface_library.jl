#! common functions for the two interfaces

#? module contains all methods to share to other files
module Lib
    export banner, break_input, generate_sql, take_input, print_error

    function banner(user)
        printstyled("  ___                      _    _      _ _                     \n"; color = :cyan)
        printstyled(" / _ \\ _ __   ___ _ __    / \\  (_)_ __| (_)_ __   ___ ___    \n"; color = :cyan)
        printstyled("| | | | '_ \\ / _ | '_ \\  / _ \\ | | '__| | | '_ \\ / _ / __| \n"; color = :cyan)
        printstyled("| |_| | |_) |  __| | | |/ ___ \\| | |  | | | | | |  __\\__ \\  \n"; color = :cyan)
        printstyled(" \\___/| .__/ \\___|_| |_/_/   \\_|_|_|  |_|_|_| |_|\\___|___/ \n"; color = :cyan)
        printstyled("      |_|                                               $user \n"; color = :cyan)
    end
    
    #? break user input into words and phrases
    #* using this over Julia's inbuilt split function to have multiworded cities like 'New York' as one element
    function break_input(input::AbstractString)
        in_quote = false
        current_word = ""
        result = []
    
        for char in input
            if char == ' ' && !in_quote
                if current_word != ""
                    push!(result, current_word)
                    current_word = ""
                end
            elseif char == '\''
                in_quote = !in_quote
                if current_word != ""
                    push!(result, current_word)
                    current_word = ""
                end
            else
                current_word *= string(char)
            end
        end
    
        if current_word != ""
            push!(result, current_word)
        end
    
        return result
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
    
    #? get user input
    function take_input(identify)
        printstyled("\n$identify "; color = :blue)
        user_input = readline()
    
        return lowercase(user_input)
    end
    
    function print_error(prompt)
        printstyled(prompt; color = :red)
        println("") # blank line
    end
end
