--! create admin database

CREATE DATABASE control_db DEFAULT CHARACTER SET utf8mb4;
USE control_db;
set autocommit=1;

--!-----------------------------------------------------!-- Users & Roles --!---------!--
DROP USER IF EXISTS 'app'@'%';
CREATE USER 'app'@'%' IDENTIFIED BY 'secretfornoonetoknow';

DROP USER IF EXISTS 'executive'@'%';
CREATE USER 'executive'@'%' IDENTIFIED BY 'secretfornoonetoknow';

DROP ROLE IF EXISTS rApp, rExecutive;
CREATE ROLE rApp, rExecutive;

--!-----------------------------------------------------!-- Create Table --!----------!--

CREATE TABLE `Profile` (
    `ID` INT NOT NULL AUTO_INCREMENT,
    `fName` CHAR(15) NOT NULL,
    `lName` CHAR(15) NOT NULL,
    `gender` ENUM('Male', 'Female') NOT NULL DEFAULT 'Male',
    `phone` CHAR(10) NOT NULL,
    PRIMARY KEY (`ID`)
);

CREATE TABLE `Access` (
    `ID` INT NOT NULL,
    `accessLvl` ENUM('helpdesk','associate','manager','executive') NOT NULL,
    PRIMARY KEY (`ID`),
    FOREIGN KEY (`ID`) REFERENCES `Profile`(`ID`)
);

CREATE TABLE `Authentication` (
    `ID` INT NOT NULL,
    `password` CHAR(16) NOT NULL DEFAULT 'flightAirlines',
    PRIMARY KEY (`ID`),
    FOREIGN KEY (`ID`) REFERENCES `Profile`(`ID`)
);

CREATE TABLE `Logs` (
    `date` DATE NOT NULL,
    `time` TIME NOT NULL,
    `authorID` INT NOT NULL,
    `action` VARCHAR(30) NOT NULL,
    `record` VARCHAR(10) NOT NULL,
    PRIMARY KEY (`date`, `time`, `authorID`),
    FOREIGN KEY (`authorID`) REFERENCES `Profile`(`ID`)
);

CREATE TABLE `Session` (
    `userID` INT NOT NULL,
    `token` CHAR(10) NOT NULL,
    -- here while userID is just ID shared by other tables, 
    -- this table isn't required to have any relation with other tables.
    PRIMARY KEY (`userID`)
);

--!-----------------------------------------------------!-- Roles & Permissions --!---!--

-- for ethical reasons, no one should be able to edit system logs
GRANT SELECT ON control_db.Logs TO rExecutive; -- executives can only view all logs
GRANT INSERT ON control_db.Logs TO rApp; -- system can only append to the logs

-- executives should, however, be able to view and edit all other employee related info.
GRANT ALL ON control_db.Profile TO rExecutive;
GRANT ALL ON control_db.Access TO rExecutive;
GRANT ALL ON control_db.Authentication TO rExecutive;
GRANT rExecutive TO executive;

-- system has only read certain data- data that is required for the program to operate.
GRANT SELECT ON control_db.Authentication TO rApp;
GRANT SELECT ON control_db.Access TO rApp;
GRANT SELECT (ID, fName, lName) ON control_db.Profile TO rApp;
GRANT ALL ON control_db.Session TO rApp;
GRANT rApp TO app;
SET DEFAULT ROLE rApp TO app;

FLUSH PRIVILEGES;
