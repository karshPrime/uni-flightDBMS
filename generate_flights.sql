--! create flight database

CREATE DATABASE `flight_db` DEFAULT CHARACTER SET utf8mb4;
USE flight_db;
set autocommit=0;

--!-----------------------------------------------------!-- Users & Roles --!---------!--
CREATE USER 'public'@'localhost' IDENTIFIED BY 'secretfornoonetoknow';
CREATE USER 'helpdesk'@'localhost' IDENTIFIED BY 'secretfornoonetoknow';
CREATE USER 'associate'@'localhost' IDENTIFIED BY 'secretfornoonetoknow';
CREATE USER 'manager'@'localhost' IDENTIFIED BY 'secretfornoonetoknow';

CREATE ROLE rPublic, rHelpdesk, rAssociate, rChief;

--!-----------------------------------------------------!-- Create Table --!----------!--

CREATE TABLE `Plane` (
    `ID` INT NOT NULL AUTO_INCREMENT,
    `airlines` VARCHAR(50) NOT NULL,
    `model` VARCHAR(50) NOT NULL,
    `seats` INT NOT NULL DEFAULT 100,
    `capacity` INT NOT NULL DEFAULT 5000,
    `manufactureYear` INT NOT NULL,
    `journeys` INT NOT NULL,
    CHECK (seats > 0),
    CHECK (capacity > 0),
    CHECK (journeys > 0),
    CHECK (capacity > 1990),
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
    `hasVIP` BOOLEAN NOT NULL DEFAULT false,
    `hasFood` BOOLEAN NOT NULL DEFAULT true,
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
    FOREIGN KEY (`crewID`) REFERENCES `Crew`(`ID`),
);

--!-----------------------------------------------------!-- Auto Update Records --!---!--
CREATE TRIGGER updateStaffCount
AFTER INSERT ON AirStaff
FOR EACH ROW
BEGIN
    DECLARE crew_count INT;
    SET crew_count = (SELECT COUNT(*) FROM AirStaff WHERE crewID = NEW.crewID);
    UPDATE Crew SET staffCount = crew_count WHERE ID = NEW.crewID;
END;


--!-----------------------------------------------------!-- Roles & Permissions --!---!--

GRANT SELECT (ID, airlines, model) ON flight_db.Plane TO rPublic;
GRANT SELECT (departure, destination, takeOffTime, takeOffDate, duration, hasFood) ON flight_db.Flight TO rPublic;
GRANT rPublic TO public;

GRANT SELECT (ID, airlines, model, seats, capacity) ON flight_db.Plane TO rHelpdesk;
GRANT SELECT (ID, fName, lName, age, gender) ON flight_db.Pilot TO rHelpdesk;
GRANT SELECT (ID, pilotID, coPilotID, staffCount) ON flight_db.Crew TO rHelpdesk;
GRANT SELECT (ID, planeID, crewID, departure, destination, takeOffTime, takeOffDate, duration, hasFood) ON flight_db.Flight TO rHelpdesk;
GRANT SELECT (ID, crewID, fName, lName, age, gender, nativeLanguage) ON flight_db.AirStaff TO rHelpdesk;
GRANT rHelpdesk TO helpdesk;

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

-- chief has SELECT, UPDATE and INSERT all tables
GRANT ALL ON flight_db.* TO rChief;
GRANT rChief TO chief;

FLUSH PRIVILEGES;
