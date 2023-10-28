#! program interface for airline admins
#* admins should only be able to view and edit data that they're permitted to.

include("authenticator.jl")
using .Auth

include("interface_library.jl") # functions with "Lib." prefix
using .Lib

#? login prompt
function login()
    printstyled("User ID  > "; color = :green)
    username = readline()
    printstyled("Password > "; color = :green)
    password = readline()

    return (username, password)
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
    Lib.banner("Admin") # print program banner

    while true # user cannot continue without successful login
        credentials = login()
        status = Auth.authenticate(credentials)
        
        if status == 1
            printstyled("< ! AUTHENTICATION FAIL ! >\n\n"; color = :red)
        else
            (connection, username, accessLvl) = Auth.connect(credentials[1], status)
            printstyled("Welcome $usernname!"; color = :yellow)
            break # stop loop if login was successful
        end
    end

    while true
        user_input = Lib.take_input("[$username | $accessLvl]") # [Bob Dayne|Manager]

        if user_input == "x"
            printstyled("Goodbye~\n"; color = :light_blue)
            break
        end

        if user_input == "?"
            help_menu(accessLvl)
            continue
        end

        sql_cmd = understand_input(user_input, accessLvl)
        
        if sql_cmd[1] == true
            run_cmd(sql_cmd[2], "connection")
        else
            Lib.print_error(sql_cmd[2])
        end
    end
end

main()
