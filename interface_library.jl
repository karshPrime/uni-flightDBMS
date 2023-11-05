#! common functions for the two interfaces

#? module contains all methods to share to other files
module Lib
    export banner, generate_sql, take_input, print_error, border

    #? program banner for the interfaces
    function banner(user)
        print("\x1b[2J\x1b[H") #? clear the screen with starting the application
        printstyled("  ___                      _    _      _ _                     \n"; color = :cyan)
        printstyled(" / _ \\ _ __   ___ _ __    / \\  (_)_ __| (_)_ __   ___ ___    \n"; color = :cyan)
        printstyled("| | | | '_ \\ / _ | '_ \\  / _ \\ | | '__| | | '_ \\ / _ / __| \n"; color = :cyan)
        printstyled("| |_| | |_) |  __| | | |/ ___ \\| | |  | | | | | |  __\\__ \\  \n"; color = :cyan)
        printstyled(" \\___/| .__/ \\___|_| |_/_/   \\_|_|_|  |_|_|_| |_|\\___|___/ \n"; color = :cyan)
        printstyled("      |_|                                            $user     \n"; color = :cyan)
    end
 
    #? generate SQL command for passed parameters
    function generate_sql(oldCmd, field, value)
        if length(oldCmd) == 0
            newCmd = oldCmd * " WHERE " * field * "=\'" * value * "'"
        else
            newCmd = oldCmd * " AND " * field * "=\'" * value * "'"
        end
    
        return newCmd
    end

    #? draw border line for tables
    function draw_border(sections)
        borderString = "+"
        for i in 1:length(sections)
            for j in 1:sections[i]
                borderString *= "-"
            end
            borderString *= "+"
        end
        printstyled("$borderString\n"; color = :yellow)
    end

    #? print table heading
    function table_head(titles, spaces)
        headString = "| "
        for i in 1:length(titles)
            headString *= titles[i]
            for j in length(titles[i]):spaces[i]
                headString *= " "
            end
            headString *= " | "
        end
        printstyled("$headString\n"; color = :yellow)
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
    
    #? prints prompt as error
    function print_error(prompt)
        printstyled("\n<!> $prompt <!>\n"; color = :red)
    end
end
