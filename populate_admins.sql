--! populate the admin database with sample entries

USE control_db;
set autocommit=0;

--* profiles
INSERT INTO `Profile` (`ID`,`fName`,`lName`,`gender`,`phone`)
VALUES
('101', 'John', 'Smith', 'Male', '051234567'),
('102', 'Mary', 'Johnson', 'Female', '052345678'),
('103', 'David', 'Brown', 'Male', '053456789'),
('104', 'Sarah', 'Williams', 'Female', '054567890'),
('105', 'Michael', 'Jones', 'Male', '055678901'),
('106', 'Emily', 'Davis', 'Female', '056789012'),
('107', 'Christopher', 'Wilson', 'Male', '057890123'),
('108', 'Linda', 'Miller', 'Female', '058901234'),
('109', 'Daniel', 'Anderson', 'Male', '059012345'),
('110', 'Jennifer', 'Martinez', 'Female', '050123456');

--* access
INSERT INTO `Access` (`ID`,`accessLvl`)
VALUES
('101', 'Helpdesk'),
('102', 'Helpdesk'),
('103', 'Associate'),
('104', 'Manager'),
('105', 'Executive'),
('106', 'Associate'),
('107', 'Helpdesk'),
('108', 'Helpdesk'),
('109', 'Manager'),
('110', 'Associate');

--* authentication
INSERT INTO `Authentication` (`ID`,`password`)
VALUES
('101', 'sunshine2023'),
('102', 'p@ssw0rd!X'),
('103', 'secret1234'),
('104', 'myP@$$w0rd'),
('105', 'soccerFan#1'),
('106', 'letMeIn567'),
('107', 'coolDude$99'),
('108', 'secureP@ss'),
('109', 'happyDays42'),
('110', 'summerVacay');
