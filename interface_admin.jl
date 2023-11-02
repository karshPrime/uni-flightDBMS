#! program interface for airline admins
#* admins should only be able to view and edit data that they're permitted to.

include("authenticator.jl");        using .Auth
include("interface_library.jl");    using .Lib
include("admin_modules/add.jl");    using .Add
include("admin_modules/edit.jl");   using .Edit
include("admin_modules/help.jl");   using .Help
include("admin_modules/remove.jl"); using .Remove
include("admin_modules/scrape.jl"); using .Scrape
include("admin_modules/show.jl");   using .Show
include("admin_modules/table.jl");  using .Table

using MySQL
using DBInterface
using Printf

#? login prompt
function login()
    return ("101","sunshine2023") #! debug HELPDESK
    #return ("103", "secret1234")  #! debug ASSOCIATE
    #return ("109","happyDays42")  #! debug MANAGER
    #return ("105","soccerFan#1")  #! debug EXECUTIVE
    
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
        "show"   => Show
    )

    accessID = Dict(
        "helpdesk"  => 0,
        "associate" => 1,
        "manager"   => 2,
        "executive" => 3
    )

    #* initialising variables
    (connection, username, accessLvl) = ("", "", "")

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
        userInput = Lib.take_input("[$username | $accessLvl] \$") #* [Bob Dayne | Manager] $ 

        if length(userInput) > 0 #* ignore blank input
            if userInput[1] == "x" #* quit
                DBInterface.close!
                printstyled("\nGoodbye $username...\n"; color = :light_blue)
                println("logged out\n")
                break
            end

            if userInput[1] == "?" #* help
                Help.run(accessID[accessLvl], length(userInput) > 1 ? userInput[2] : " ")
                continue
            end

            if haskey(modules, userInput[1])
                modules[userInput[1]].run(userInput, accessID[accessLvl], connection)
            else
                Lib.print_error("command not found")
            end
        end
    end
end

main()
