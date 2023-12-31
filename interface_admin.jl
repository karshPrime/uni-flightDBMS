#! program interface for airline admins
#* admins should only be able to view and edit data that they're permitted to.

include("admin_modules/add.jl");    using .Add
include("authenticator.jl");        using .Auth
include("admin_modules/edit.jl");   using .Edit
include("admin_modules/help.jl");   using .Help
include("interface_library.jl");    using .Lib
include("admin_modules/logs.jl");   using .Logs
include("admin_modules/remove.jl"); using .Remove
include("admin_modules/show.jl");   using .Show
include("admin_modules/staff.jl");  using .Staff
include("admin_modules/table.jl");  using .Table

using MySQL
using DBInterface
using Printf

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
        "show"   => Show,
        "staff"  => Staff,
        "logs"   => Logs
    )

    accessID = Dict(
        "helpdesk"  => 0,
        "associate" => 1,
        "manager"   => 2,
        "executive" => 3
    )

    #* initialising variables
    (connection, username, accessLvl) = ("", "", "")
    userid = ""

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
        userInput = Lib.take_input("$accessLvl : $(lowercase(username)) ➤ ") #* [Bob Dayne | Manager] $ 

        if length(userInput) > 0
            if userInput[1] == "x" #* quit
                Auth.logout(userid)
                DBInterface.close!
                printstyled("\nGoodbye $username...\n"; color = :light_blue)
                println("logged out\n")
                break
            end

            if userInput[1] == "?" #* help
                Help.run(accessID[accessLvl], userInput)
                continue
            end

            if haskey(modules, userInput[1])
                status = modules[userInput[1]].run(userInput, accessID[accessLvl], connection)
                Auth.log(userid, status)
            else
                Lib.print_error("command not found")
            end
        else
            #? clear the screen if user enters nothing and presses enter
            print("\x1b[2J\x1b[H") 
        end
    end
end

main()
