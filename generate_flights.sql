--! create flight database

CREATE DATABASE flight_db DEFAULT CHARACTER SET utf8mb4;
USE flight_db;
set autocommit=1;

--!-----------------------------------------------------!-- Users & Roles --!---------!--
DROP USER IF EXISTS 'public'@'%';
CREATE USER 'public'@'%' IDENTIFIED BY 'secretfornoonetoknow';

DROP USER IF EXISTS 'helpdesk'@'%';
CREATE USER 'helpdesk'@'%' IDENTIFIED BY 'secretfornoonetoknow';

DROP USER IF EXISTS 'associate'@'%';
CREATE USER 'associate'@'%' IDENTIFIED BY 'secretfornoonetoknow';

DROP USER IF EXISTS 'manager'@'%';
CREATE USER 'manager'@'%' IDENTIFIED BY 'secretfornoonetoknow';

DROP ROLE IF EXISTS rPublic, rHelpdesk, rAssociate, rManager;
CREATE ROLE rPublic, rHelpdesk, rAssociate, rManager;

--!-----------------------------------------------------!-- Create Table --!----------!--

CREATE TABLE `Plane` (
    `ID` INT NOT NULL AUTO_INCREMENT,
    `airlines` VARCHAR(50) NOT NULL,
    `model` VARCHAR(50) NOT NULL,
    `seats` INT NOT NULL DEFAULT 100,
    `capacity` INT NOT NULL DEFAULT 5000,
    `manufactureYear` INT NOT NULL,
    `journeys` INT NOT NULL,
    PRIMARY KEY (`ID`)
);

CREATE TABLE `Pilot` (
    `ID` INT NOT NULL AUTO_INCREMENT,
    `fName` VARCHAR(15) NOT NULL,
    `lName` VARCHAR(15) NOT NULL,
    `age` INT CHECK (age BETWEEN 18 AND 60),
    `gender` enum('Male', 'Female') NOT NULL DEFAULT 'Male',
    `nationality` VARCHAR(25) NOT NULL DEFAULT 'Australian',
    PRIMARY KEY (`ID`)
);

CREATE TABLE `Crew` (
    `ID` INT NOT NULL AUTO_INCREMENT,
    `pilotID` INT NOT NULL,
    `coPilotID` INT NOT NULL,
    `staffCount` INT,
    PRIMARY KEY (`ID`),
    FOREIGN KEY (`pilotID`) REFERENCES `Pilot`(`ID`),
    FOREIGN KEY (`coPilotID`) REFERENCES `Pilot`(`ID`)
);

CREATE TABLE `Flight` (
    `ID` INT NOT NULL AUTO_INCREMENT,
    `planeID` INT NOT NULL,
    `crewID` INT NOT NULL,
    `departure` VARCHAR(45) NOT NULL,
    `destination` VARCHAR(45) NOT NULL,
    `takeOffTime` TIME NOT NULL DEFAULT ('00:00:00'),
    `takeOffDate` DATE NOT NULL,
    `duration` TIME NOT NULL DEFAULT ('00:00:00'),
    `hasVIP` TINYINT(1) NOT NULL DEFAULT 0, -- TINYINT(1) is same as using boolean
    `hasFood` TINYINT(1) NOT NULL DEFAULT 1,-- but is apparently more effecient
    PRIMARY KEY (`ID`),
    FOREIGN KEY (`planeID`) REFERENCES `Plane`(`ID`),
    FOREIGN KEY (`crewID`) REFERENCES `Crew`(`ID`)
);

CREATE TABLE `AirStaff` (
    `ID` INT NOT NULL AUTO_INCREMENT,
    `crewID` INT NOT NULL,
    `fName` VARCHAR(20) NOT NULL,
    `lName` VARCHAR(20) NOT NULL,
    `age` INT CHECK (age BETWEEN 18 AND 60),
    `gender` enum('Male', 'Female') NOT NULL DEFAULT 'Male',
    `nativeLanguage` VARCHAR(15) NOT NULL DEFAULT 'English',
    PRIMARY KEY (`ID`),
    FOREIGN KEY (`crewID`) REFERENCES `Crew`(`ID`)
);

--!-----------------------------------------------------!-- Auto Update Records --!---!--
-- method 1: automatic; will auto trigger whenever the crew table is modified.
DELIMITER $$
CREATE TRIGGER updateStaffCount
AFTER INSERT ON AirStaff
FOR EACH ROW
BEGIN
    DECLARE crew_count INT;
    SET crew_count = (SELECT COUNT(*) FROM AirStaff WHERE crewID = NEW.crewID);
    UPDATE Crew SET staffCount = crew_count WHERE ID = NEW.crewID;
END $$
DELIMITER ;

-- method 2: must be manually executed every time changes are made; error-prone
-- UPDATE `Crew` c SET `staffCount` = (
--     SELECT COUNT(*) 
--     FROM `AirStaff` a
--     WHERE a.`crewID` = c.`ID`
-- );

--!-----------------------------------------------------!-- Roles & Permissions --!---!--

GRANT SELECT (ID, airlines, model) ON flight_db.Plane TO rPublic;
GRANT SELECT (departure, destination, takeOffTime, takeOffDate, duration, hasFood) ON flight_db.Flight TO rPublic;
GRANT rPublic TO public;
SET DEFAULT ROLE rPublic TO public;

GRANT SELECT (ID, airlines, model, seats, capacity) ON flight_db.Plane TO rHelpdesk;
GRANT SELECT (ID, fName, lName, age, gender) ON flight_db.Pilot TO rHelpdesk;
GRANT SELECT (ID, pilotID, coPilotID, staffCount) ON flight_db.Crew TO rHelpdesk;
GRANT SELECT (ID, planeID, crewID, departure, destination, takeOffTime, takeOffDate, duration, hasFood) ON flight_db.Flight TO rHelpdesk;
GRANT SELECT (ID, crewID, fName, lName, age, gender, nativeLanguage) ON flight_db.AirStaff TO rHelpdesk;
GRANT rHelpdesk TO helpdesk;
SET DEFAULT ROLE rHelpdesk TO helpdesk;

GRANT SELECT, INSERT ON flight_db.Plane TO rAssociate; -- view all
GRANT SELECT, INSERT ON flight_db.Pilot TO rAssociate; -- view all
GRANT SELECT (ID, staffCount) ON flight_db.Crew TO rAssociate;
GRANT SELECT, UPDATE (pilotID, coPilotID) ON flight_db.Crew TO rAssociate;
GRANT SELECT (ID, hasVIP) ON flight_db.Flight TO rAssociate;
GRANT SELECT, UPDATE (planeID, crewID, departure, destination, takeOffTime, takeOffDate, duration, hasFood) ON flight_db.Flight TO rAssociate;
GRANT INSERT ON flight_db.Flight TO rAssociate;
GRANT SELECT (ID, fName, lName, age, gender, nativeLanguage) ON flight_db.AirStaff TO rAssociate;
GRANT SELECT, UPDATE (crewID) ON flight_db.AirStaff TO rAssociate;
GRANT rAssociate TO associate;
SET DEFAULT ROLE rAssociate TO associate;

-- manager has SELECT, UPDATE, and INSERT all tables
GRANT ALL ON flight_db.* TO rManager;
GRANT rManager TO manager;
SET DEFAULT ROLE rManager TO manager;

FLUSH PRIVILEGES;
