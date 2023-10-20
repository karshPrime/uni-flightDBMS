#! program interface for airline admins
#* admins should only be able to view and edit data that they're permitted to.

using authenticate.jl
include("authenticator.jl")
using .Auth

include("interface_library.jl") # functions with "Lib." prefix
using .Lib

#? login prompt
function login()
end

#? print help menu showing all possible commands for the loggedin user
function help_menu(user)
    #* helpdesk = 0 | associate = 1 | manager = 2 | executive = 3
    if user == 0
        #
    elseif user == 1
        #
    elseif user == 2
        #
    else
        #
    end

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
end

main()
