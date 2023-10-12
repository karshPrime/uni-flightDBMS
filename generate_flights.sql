--! create flight database

CREATE DATABASE `flight_db` DEFAULT CHARACTER SET utf8mb4;
USE flight_db;
set autocommit=0;

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

