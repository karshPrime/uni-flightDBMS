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
end

#? Understand user command
function understand_input(input)
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
