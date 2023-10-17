--! create admin database

CREATE DATABASE `control_db` DEFAULT CHARACTER SET utf8mb4;
USE control_db;
set autocommit=0;

--!-----------------------------------------------------!-- Create Table --!----------!--

CREATE TABLE `Profile` (
    `ID` INT NOT NULL AUTO_INCREMENT,
    `fName` CHAR(15) NOT NULL,
    `lName` CHAR(15) NOT NULL,
    `gender` enum('Male', 'Female') NOT NULL DEFAULT 'Male';
    `phone` CHAR(10) NOT NULL,
    PRIMARY KEY (`ID`),
);

CREATE TABLE `Access` (
    `ID` INT NOT NULL,
    `acessLvl` enum('helpdesk','associate','manager','executive') NOT NULL,
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
