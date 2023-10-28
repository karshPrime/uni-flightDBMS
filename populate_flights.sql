--! populate the flight database with sample entries

USE flight_db;
set autocommit=1;

--* Planes
INSERT INTO `Planes` (`ID`,`airlines`,`model`,`seats`,`capacity`,`manufactureYear`,`journeys`)
VALUES
('90001', 'Delta Air Lines', 'Boeing 737', '160', '5000', '2015', '237'),
('90002', 'American Airlines', 'Airbus A320', '180', '5500', '2017', '192'),
('90003', 'United Airlines', 'Boeing 787 Dreamliner', '240', '7000', '2016', '175'),
('90004', 'Southwest Airlines', 'Boeing 737', '150', '4800', '2014', '261'),
('90005', 'Lufthansa', 'Airbus A380', '480', '9000', '2013', '128'),
('90006', 'Emirates', 'Boeing 777', '350', '7500', '2019', '83'),
('90007', 'Air France', 'Airbus A350', '300', '7200', '2018', '97'),
('90008', 'British Airways', 'Boeing 747', '400', '8200', '2012', '163'),
('90009', 'Qantas', 'Airbus A380', '480', '9000', '2015', '135'),
('90010', 'Singapore Airlines', 'Airbus A350', '330', '7700', '2017', '122');

--* Pilots
INSERT INTO `Pilot` (`ID`,`fName`,`lName`,`age`,`gender`,`Nationality`)
VALUES
('20001', 'Olivia', 'Smith', '32', 'Female', 'Australian', '454'),
('20002', 'William', 'Johnson', '29', 'Male', 'Australian', '322'),
('20003', 'Amelia', 'Brown', '35', 'Female', 'Australian', '484'),
('20004', 'James', 'Davis', '31', 'Male', 'Australian', '346'),
('20005', 'Charlotte', 'Wilson', '28', 'Female', 'Australian', '304'),
('20006', 'Liam', 'Taylor', '33', 'Male', 'Australian', '370'),
('20007', 'Ava', 'Jones', '30', 'Female', 'American', '355'),
('20008', 'Noah', 'Anderson', '34', 'Male', 'American', '406'),
('20009', 'Sophia', 'Martin', '29', 'Female', 'Canadian', '321'),
('20010', 'Ethan', 'Garcia', '32', 'Male', 'Canadian', '355'),
('20011', 'Isabella', 'Martinez', '27', 'Female', 'Mexican', '287'),
('20012', 'Lucas', 'Rodriguez', '30', 'Male', 'Mexican', '306'),
('20013', 'Mia', 'Kim', '31', 'Female', 'Korean', '329'),
('20014', 'Logan', 'Lee', '29', 'Male', 'Korean', '291'),
('20015', 'Harper', 'Johnson', '34', 'Female', 'British', '378'),
('20016', 'Mason', 'Williams', '33', 'Male', 'British', '363'),
('20017', 'Ella', 'Harris', '28', 'Female', 'French', '313'),
('20018', 'Oliver', 'Brown', '31', 'Male', 'French', '339'),
('20019', 'Aiden', 'Smith', '29', 'Male', 'German', '302'),
('20020', 'Emma', 'Davis', '32', 'Female', 'German', '323');

--* Crew
INSERT INTO `Crew` (`ID`,`pilotID`,`coPilotID`,`staffCount`)
VALUES
('10001', '20001', '20002'),
('10002', '20016', '20006'),
('10003', '20002', '20009'),
('10004', '20013', '20010'),
('10005', '20005', '20012'),
('10006', '20007', '20015'),
('10007', '20003', '20014'),
('10008', '20008', '20001'),
('10009', '20011', '20019'),
('10010', '20004', '20017');

--* Flights
INSERT INTO 'Flight' (`ID`,`planeID`,`crewID`,`departure`,`destination`,`takeOffTime`,`takeOffDate`,`duration`,`routeType`,`hasVIP`,`hasFood`)
VALUES
('00001', '90004', '10005', 'New York', 'Los Angeles', '08:30:00', '2023-10-15', '05:30:00', 'domestic', 'false', 'true'),
('00002', '90008', '10003', 'London', 'Paris', '10:15:00', '2023-10-16', '01:30:00', 'international', 'false', 'true'),
('00003', '90003', '10010', 'Tokyo', 'Seoul', '09:45:00', '2023-10-17', '02:30:00', 'international', 'false', 'false'),
('00004', '90005', '10005', 'Los Angeles', 'San Francisco', '08:00:00', '2023-10-18', '01:15:00', 'domestic', 'true', 'true'),
('00005', '90001', '10006', 'Sydney', 'Melbourne', '11:00:00', '2023-10-19', '01:45:00', 'domestic', 'false', 'true'),
('00006', '90007', '10008', 'Paris', 'Amsterdam', '09:30:00', '2023-10-20', '01:45:00', 'international', 'false', 'false'),
('00007', '90009', '10002', 'Chicago', 'Miami', '07:45:00', '2023-10-21', '03:00:00', 'domestic', 'true', 'true'),
('00008', '90006', '10004', 'Berlin', 'Vienna', '10:30:00', '2023-10-22', '01:45:00', 'international', 'false', 'true'),
('00009', '90002', '10007', 'Beijing', 'Shanghai', '09:15:00', '2023-10-23', '02:00:00', 'international', 'false', 'false'),
('00010', '90010', '10009', 'Rome', 'Barcelona', '08:30:00', '2023-10-24', '01:30:00', 'international', 'false', 'true'),
('00011', '90005', '10005', 'San Francisco', 'Los Angeles', '12:00:00', '2023-10-25', '01:15:00', 'domestic', 'false', 'true'),
('00012', '90003', '10010', 'Seoul', 'Tokyo', '13:30:00', '2023-10-26', '02:30:00', 'international', 'false', 'false'),
('00013', '90001', '10001', 'Sydney', 'Brisbane', '10:15:00', '2023-10-27', '02:00:00', 'domestic', 'true', 'true'),
('00014', '90006', '10004', 'Vienna', 'Zurich', '11:45:00', '2023-10-28', '01:30:00', 'international', 'false', 'false'),
('00015', '90008', '10004', 'Paris', 'Barcelona', '12:30:00', '2023-10-29', '01:45:00', 'international', 'false', 'true'),
('00016', '90008', '10008', 'Melbourne', 'Moscow', '16:30:00', '2023-11-01', '14:45:00', 'international', 'true', 'true');

--* AirStaff
INSERT INTO `AirStaff` (`ID`,`crewID`,`fName`,`lName`,`age`,`gender`,`nativeLanguage`) 
VALUES
('30001', '10001', 'Alice', 'Smith', '28', 'Female', 'English'),
('30002', '10007', 'Ivgor', 'Yuliyanta', '34', 'Male', 'Russian'),
('30003', '10004', 'Charlie', 'Wilson', '29', 'Male', 'English'),
('30004', '10006', 'David', 'Brown', '27', 'Male', 'English'),
('30005', '10008', 'Eva', 'Martinez', '32', 'Female', 'Spanish'),
('30006', '10003', 'Frank', 'Lee', '31', 'Male', 'English'),
('30007', '10002', 'Grace', 'Harris', '25', 'Female', 'English'),
('30008', '10001', 'Hannah', 'Davis', '26', 'Female', 'English'),
('30009', '10009', 'Isaac', 'Anderson', '30', 'Male', 'English'),
('30010', '10005', 'Jack', 'Miller', '33', 'Male', 'English'),
('30011', '10007', 'Emily', 'Moore', '29', 'Female', 'English'),
('30012', '10010', 'Katherine', 'White', '27', 'Female', 'English'),
('30013', '10003', 'Sophia', 'Johnson', '28', 'Female', 'English'),
('30014', '10006', 'Liam', 'Wilson', '31', 'Male', 'Italian'),
('30015', '10004', 'Noah', 'Smith', '29', 'Male', 'English'),
('30016', '10008', 'Oliver', 'Brown', '30', 'Male', 'French'),
('30017', '10007', 'Ella', 'Harris', '26', 'Female', 'English'),
('30018', '10002', 'Mia', 'Anderson', '32', 'Female', 'French'),
('30019', '10001', 'Aiden', 'Lee', '34', 'Male', 'Mandarin'),
('30020', '10009', 'Lucas', 'Martinez', '28', 'Male', 'Spanish'),
('30021', '10005', 'Olivia', 'Moore', '29', 'Female', 'English'),
('30022', '10010', 'Liam', 'Smith', '35', 'Male', 'English'),
('30023', '10004', 'Emma', 'Wilson', '31', 'Female', 'English'),
('30024', '10006', 'Charlotte', 'Brown', '27', 'Female', 'English'),
('30025', '10008', 'Benjamin', 'Johnson', '30', 'Male', 'Italian'),
('30026', '10003', 'William', 'Lee', '29', 'Male', 'English'),
('30027', '10002', 'Ava', 'Petyoshka', '27', 'Female', 'Russian'),
('30028', '10001', 'James', 'Anderson', '32', 'Male', 'English'),
('30029', '10009', 'Mason', 'Smith', '28', 'Male', 'English'),
('30030', '10005', 'Ella', 'Moore', '34', 'Female', 'English'),
('30031', '10007', 'Emily', 'Williams', '31', 'Female', 'German'),
('30032', '10010', 'Katherine', 'Brown', '30', 'Female', 'English'),
('30033', '10003', 'Sophia', 'Davis', '29', 'Female', 'English'),
('30034', '10006', 'Liam', 'Anderson', '27', 'Male', 'English'),
('30035', '10004', 'Noah', 'Martin', '32', 'Male', 'English'),
('30036', '10008', 'Oliver', 'Taylor', '28', 'Male', 'French'),
('30037', '10007', 'Ella', 'Popovskii', '26', 'Female', 'Russian'),
('30038', '10002', 'Mia', 'Garcia', '30', 'Female', 'Spanish'),
('30039', '10001', 'Aiden', 'Hernandez', '33', 'Male', 'Spanish'),
('30040', '10009', 'Lucas', 'Ramirez', '31', 'Male', 'Spanish'),
('30041', '10005', 'Olivia', 'Lopez', '27', 'Female', 'Spanish'),
('30042', '10010', 'Liam', 'Perez', '29', 'Male', 'Spanish'),
('30043', '10004', 'Emma', 'Rodriguez', '32', 'Female', 'Spanish'),
('30044', '10006', 'Charlotte', 'Gonzalez', '30', 'Female', 'Spanish'),
('30045', '10008', 'Benjamin', 'Sanchez', '31', 'Male', 'Spanish'),
('30046', '10003', 'Harper', 'Smith', '27', 'Female', 'English'),
('30047', '10002', 'Mason', 'Brown', '33', 'Male', 'English'),
('30048', '10001', 'Sophia', 'Wilson', '30', 'Female', 'French'),
('30049', '10009', 'Ava', 'Johnson', '28', 'Female', 'English'),
('30050', '10005', 'Ella', 'Davis', '29', 'Female', 'German');
