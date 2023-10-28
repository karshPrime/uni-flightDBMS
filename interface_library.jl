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
    end
    
    #? generate SQL command for passed parameters
    function generate_sql(old_cmd, field, value)
    end
    
    #? get user input
    function take_input(identify)
    end
    
    function print_error(prompt)
    end
end