#! authenticate admin login
#* return MySQL connection type.

## https://mysql.juliadatabases.org/stable/

using MySQL
using DBInterface

    #? only allowing these functions to be accessiable from other files
    export authenticate, connect, log
    #? connect with the admin database as system
    #! private function; can be accessed only from within this file
    function _connect_as_sys() 
    end

    function _token_gen()
    end

    #? check if entered password is infact right
    function authenticate(creds)
    end

    #? generate connection with database as stated user
    function connect(userid, token)
    end

    function log(authorID, action, record)
    end
end
