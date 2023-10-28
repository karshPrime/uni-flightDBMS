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
end
