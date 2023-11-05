#! authenticate admin login
#* return MySQL connection type.

module Auth
    using MySQL
    using DBInterface
    using Dates
    
    _host = "172.17.0.2" #* host IP

    #? only allowing these functions to be accessiable from other files
    export authenticate, connect, log, public

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
        appConnect = _connect_as_app()

        getStoredToken = """SELECT token FROM Session WHERE userID="$userid";"""
        storedToken = _readSQL(DBInterface.execute(appConnect, getStoredToken))

        if storedToken == token
            token_expire = """DELETE FROM Session WHERE userID="$userid";"""
            DBInterface.execute(appConnect, token_expire)

            getAccess = """SELECT accessLvl from Access WHERE ID="$userid";"""
            accessLvl = _readSQL(DBInterface.execute(appConnect, getAccess))

            getfName = """SELECT fName from Profile WHERE ID="$userid";"""
            fname = _readSQL(DBInterface.execute(appConnect, getfName))
    
            getlName = """SELECT lName from Profile WHERE ID="$userid";"""
            lname = _readSQL(DBInterface.execute(appConnect, getlName))

            DBInterface.close!

            #? connect with the database with allowed access level to the user
            flightConnect = DBInterface.connect(MySQL.Connection, 
                _host, 
                accessLvl, 
                "secretfornoonetoknow", 
                db="flight_db"
            )

            return (flightConnect, fname * ' ' * lname, accessLvl)
        end

        DBInterface.close!

        printstyled("! AUTHENTICATION FAILED. MODIFIED INTERFACE DETECTED !\n"; color = :red)
        return "ERROR" # will break the interface program
    end

    #? log actions in the log table
    function log(authorID, status)
        if status[1] == 1 return 0; end  # no action was taken
        
        record = length(status) > 3 ? status[4] : "flight_db"
        (action, table, details) = status[1:3]

        details = length(details) > 30 ? (details[1:26] * "...") : details
        
        date = Dates.format(Dates.now(), "yyyy-mm-dd")
        time = Dates.format(Dates.Time(Dates.now()), "HH:MM:SS")

        command = """ INSERT INTO `Logs` VALUES 
            ('$date', '$time', '$authorID', '$action', '$table', "$details", '$record')
        """
        println(command)

        appConnect = _connect_as_app()
        DBInterface.execute(appConnect, command)
        DBInterface.close(appConnect)
    end

    #? connect to the database as public user
    function public()
        publicConnect = DBInterface.connect(MySQL.Connection, 
            _host, 
            "public", 
            "secretfornoonetoknow", 
            db="flight_db"
        )

        return publicConnect
    end
end
