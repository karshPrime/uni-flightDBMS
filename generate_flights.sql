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
    `flightCount` INT,
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
    `routeType` enum('domestic', 'international') NOT NULL DEFAULT 'domestic',
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
-- auto trigger increment staffCount in Crew table when a new airstaff uses its key
DELIMITER $$
CREATE TRIGGER updateStaffCount
BEFORE INSERT ON AirStaff
FOR EACH ROW
BEGIN
    DECLARE crew_count INT;
    SET crew_count = (SELECT COUNT(*) FROM AirStaff WHERE crewID = NEW.crewID) + 1;
    UPDATE Crew SET staffCount = crew_count WHERE ID = NEW.crewID;
END $$
DELIMITER ;

-- auto trigger decrement staffCount in Crew table when a airstaff with its key is deleted
DELIMITER $$
CREATE TRIGGER decrementStaffCount
BEFORE DELETE ON AirStaff
FOR EACH ROW
BEGIN
    DECLARE crew_count INT;
    SET crew_count = (SELECT COUNT(*) FROM AirStaff WHERE crewID = OLD.crewID) - 1;
    UPDATE Crew SET staffCount = crew_count WHERE ID = OLD.crewID;
END $$
DELIMITER ;

--!-----------------------------------------------------!-- Roles & Permissions --!---!--
--* Public permissions
CREATE VIEW PPlane AS SELECT ID, airlines, model FROM flight_db.Plane;
CREATE VIEW PFlight AS SELECT departure, destination, takeOffTime, takeOffDate, duration, hasFood FROM flight_db.Flight;

GRANT SELECT ON PPlane TO rPublic;
GRANT SELECT ON PFlight TO rPublic;

GRANT rPublic TO public;
SET DEFAULT ROLE rPublic TO public;


--* Helpdesk permissions
CREATE VIEW HPlane AS SELECT ID, airlines, model, seats, capacity FROM flight_db.Plane;
CREATE VIEW HPilot AS SELECT ID, fName, lName, age, gender FROM flight_db.Pilot;
CREATE VIEW HFlight AS SELECT ID, planeID, crewID, departure, destination, takeOffTime, takeOffDate, duration, hasFood FROM flight_db.Flight;

GRANT SELECT ON HPlane TO rHelpdesk;
GRANT SELECT ON HPilot TO rHelpdesk;
GRANT SELECT ON HFlight TO rHelpdesk;
GRANT SELECT ON flight_db.Crew TO rHelpdesk; 
GRANT SELECT ON flight_db.AirStaff TO rHelpdesk; 

GRANT rHelpdesk TO helpdesk;
SET DEFAULT ROLE rHelpdesk TO helpdesk;


--* Associate permissions
GRANT SELECT, UPDATE ON flight_db.Crew TO rAssociate;
GRANT SELECT, UPDATE, INSERT ON flight_db.Flight TO rAssociate;
GRANT SELECT, INSERT ON flight_db.AirStaff TO rAssociate;
GRANT SELECT, INSERT ON flight_db.Plane TO rAssociate; 
GRANT SELECT, INSERT ON flight_db.Pilot TO rAssociate; 

GRANT rAssociate TO associate;
SET DEFAULT ROLE rAssociate TO associate;


--* Manager and Executive permissions
-- have SELECT, UPDATE, and INSERT on all tables
GRANT ALL ON flight_db.* TO rManager;
GRANT rManager TO manager;

SET DEFAULT ROLE rManager TO manager;
GRANT rManager TO executive;
SET DEFAULT ROLE rManager TO executive; -- exec has same perms manager on this db

FLUSH PRIVILEGES;
