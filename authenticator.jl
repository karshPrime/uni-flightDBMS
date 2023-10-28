#! authenticate admin login
#* return MySQL connection type.

## https://mysql.juliadatabases.org/stable/

using MySQL
using DBInterface

module Auth
    _host = "172.17.0.2" #* host IP

    #? only allowing these functions to be accessiable from other files
    export authenticate, connect, log

    #? connect with the admin database as system
    #! private function; can be accessed only from within this file
    function _connect_as_app() 
        connection = DBInterface.connect(MySQL.Connection,
            _host,
            "app",
            "secretfornoonetoknow", 
            db = "control_db"
        )

        return connection
    end

    #? generate random 10 digit alphanumeric token
    function _token_gen()
        charset = ['0':'9' ; 'a':'z' ; 'A':'Z']
        return join([charset[rand(1:end)] for _ in 1:10])
    end

    #? scrape MySQL output to extract relevant part
    function _readSQL(rawReturn)
        table = DBInterface.fetch(rawReturn)
        
        content = ""
        for row in table
            content = row[1]
        end
        
        return content
    end

    #? check if entered password is infact right
    function authenticate(userID, userPass)
        appConnect = _connect_as_app()

        getPass = """SELECT password from Authentication WHERE id="$userID";"""
        realPass = _readSQL(DBInterface.execute(appConnect, getPass))

        if realPass == userPass
            session_token = _token_gen()

            buffer_token_cmd = """INSERT INTO Session VALUES ("$userID", "$session_token");"""
            DBInterface.execute(appConnect, buffer_token_cmd)
            DBInterface.close!

            return session_token
        end

        DBInterface.close!
        return 1 # failed to authenticate
    end

    #? generate connection with database as stated user
    function connect(userid, token)
    end

    function log(authorID, action, record)
    end
end
