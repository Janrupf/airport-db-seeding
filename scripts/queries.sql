-- table: airlineTable.sql
    --  Gibt die Tabelle Airline aus.
SELECT * FROM Airline;

    --  AT.1: Gibt die Tabelle Airline aus und ergänzt durch Beziehungen Daten.
SELECT Callsign, A.Name as AirlineName, SlotCount, Country as CountryID, C.Name as CountryName FROM Airline A
JOIN Country C on C.ID = A.Country;

    --  AT.2: Gibt eine Übersicht, aus welchem Land wie viele Airlines kommen.
SELECT C.Name as CountryName, COUNT(A.Callsign) as NumberOfAirlines FROM Airline A
JOIN Country C on C.ID = A.Country
GROUP BY C.ID
ORDER BY 2 DESC;

    --  AT.3: Gibt nur Deutsche Airlines aus.
SELECT Callsign, A.Name as AirlineName, SlotCount, Country as CountryID, C.Name as CountryName FROM Airline A
JOIN Country C on C.ID = A.Country
WHERE C.Name = 'Germany';

    --  AT.4: Gibt die Airlines aus, die mehr Slots haben, als alle Deutsche zusammen.
SELECT A.Callsign, A.Name as AirlineName, SlotCount, Country as CountryID, C.Name as CountryName FROM Airline A
JOIN Country C on C.ID = A.Country
WHERE A.SlotCount > (
    SELECT SUM(A.SlotCount) FROM Airline A
    JOIN Country C on C.ID = A.Country
    WHERE C.Name = 'Germany'
);

    --  AT.5: Gibt die Anzahl der Passagiere aus, die eine Airline befördert hat.
SELECT Callsign, Name, SlotCount, SUM(Passengers) as Passengers FROM Airline A
JOIN Flight F on A.Callsign = F.AirlineCallsign
JOIN (
    SELECT F.FlightNumber, AirlineCallsign, COUNT(*) as Passengers FROM PassengerMovement
    JOIN Flight F on F.FlightNumber = PassengerMovement.FlightNumber
    GROUP BY F.FlightNumber
) PM on F.FlightNumber = PM.FlightNumber
GROUP BY Callsign;

    --  AT.6: Gibt den prozentualen Anteil der Passagiere aus, die eine Airline befördert hat.
SELECT Callsign, Passengers*100 / (
    SELECT COUNT(*) FROM PassengerMovement
) as percentage FROM (
    SELECT Callsign,  SUM(Passengers) as Passengers FROM Airline A
    JOIN Flight F on A.Callsign = F.AirlineCallsign
    JOIN (
        SELECT F.FlightNumber, COUNT(*) as Passengers FROM PassengerMovement
        JOIN Flight F on F.FlightNumber = PassengerMovement.FlightNumber
        GROUP BY F.FlightNumber
    ) PM on F.FlightNumber = PM.FlightNumber
    GROUP BY Callsign
) total;


-- table: employeeTable.sql
    --  just print them all
SELECT * FROM AirportEmployee;

    --  just print them all readable
SELECT RegistrationNumber, AE.Surname, AE.Name, AE.Job, AE.HouseNumber, AE.Street, AE.Residence as LocationID, L.Zip, L.Name as CityName, L.Country as CountryID, C.Name as CountryName FROM AirportEmployee AE
JOIN Location L on AE.Residence = L.ID
JOIN Country C on L.Country = C.ID;

    --  distribution by country
SELECT L.Country as CountryID, C.Name as CountryName, COUNT(C.ID) as NumberOfEmloyees FROM AirportEmployee AE
JOIN Location L on AE.Residence = L.ID
JOIN Country C on L.Country = C.ID
GROUP BY C.Name
ORDER BY 2;

    --  distribution by job
SELECT Job, COUNT(RegistrationNumber) as JobCount FROM AirportEmployee
GROUP BY Job
ORDER BY 2 DESC;

    -- get all not working employees
SELECT RegistrationNumber, CONCAT_WS(' ', Surname, Name) as Name, Job FROM AirportEmployee AE
WHERE RegistrationNumber NOT IN (
    SELECT EmployeeNumber FROM VehicleOperation
);

    --  get percentage of working and not working employees distributed by job
WITH total(Job, TotalCount) as (SELECT Job, COUNT(Job) as TotalCount FROM AirportEmployee GROUP BY Job)
SELECT total.Job, WorkingCount, WorkingCount*100 / TotalCount as WorkingPercentag, NotWorkingCount, NotWorkingCount*100 / TotalCount as NotWorkingPercentag FROM total
LEFT OUTER JOIN (
    SELECT A.Job, COUNT(*) as WorkingCount FROM VehicleOperation VO
    JOIN AirportEmployee A on A.RegistrationNumber = VO.EmployeeNumber
    GROUP BY A.Job
) Working ON total.Job = Working.Job
LEFT OUTER JOIN (
    SELECT Job, COUNT(*) as NotWorkingCount FROM AirportEmployee AE
    WHERE RegistrationNumber NOT IN (
        SELECT EmployeeNumber FROM VehicleOperation
    )
    GROUP BY Job
) NotWorking ON total.Job = NotWorking.Job
GROUP BY Job;


-- table: locationAndCities.sql
    --  just print them all
SELECT * FROM Location;

    --  just print them all readable
SELECT Location.ID as CityID, Location.Name as CityName, Zip, C.ID as CountryID, C.Name as CountryName FROM Location
JOIN Country C on Location.Country = C.ID
ORDER BY C.Name, Location.Name;

    --  print all german cities
SELECT Location.ID as CityID, Location.Name as CityName, Zip FROM Location
JOIN Country C on Location.Country = C.ID
WHERE C.Name = 'Germany'
ORDER BY Location.Name;


-- table: parkingPositionPlaneTypeTable.sql
    --  just print them all
SELECT * FROM ParkingPositionPlaneType;

    --  just print them all readable
SELECT ParkingPositionLabel, GROUP_CONCAT(CONCAT(' ', Name)) FROM ParkingPositionPlaneType PPPT
JOIN PlaneType PT on PT.ID = PPPT.PlaneType
GROUP BY ParkingPositionLabel
ORDER BY ParkingPositionLabel;


-- table: parkingPositionTable.sql
    --  just print them all
SELECT * FROM ParkingPosition;

    --  just print them all readable
SELECT ParkingPosition.Label as PositionLabel, TerminalID, T.Label as Terminal, ST_AsText(GeographicPosition) as GeoPositionReference, GROUP_CONCAT(CONCAT(' ',PT.Name)) as PossiblePlaneTypes FROM ParkingPosition
JOIN Terminal T on T.ID = ParkingPosition.TerminalID
JOIN ParkingPositionPlaneType PPPT on ParkingPosition.Label = PPPT.ParkingPositionLabel
JOIN PlaneType PT on PT.ID = PPPT.PlaneType
GROUP BY ParkingPositionLabel;

    --  print occupied gates with the time and flight
SELECT PP.Label, TerminalID, T.Label as Terminal, Callsign, A.Name as AirlineName, CONCAT(A.Name, ROW_NUMBER() over (PARTITION BY F.AirlineCallsign)) as FlightNumber, CONCAT_WS(' - ', F.StartParkTime, F.EndParkTime) as ParkingTime FROM ParkingPosition PP
JOIN Flight F on PP.Label = F.ParkingPositionLabel
JOIN Airline A on F.AirlineCallsign = A.Callsign
JOIN Terminal T on PP.TerminalID = T.ID
ORDER BY PP.Label;


-- table: passengerMovementTable.sql
    -- just print them all
SELECT * FROM PassengerMovement;

    --  print all departing passengers
SELECT Passenger as PassengerID, Name, Surname, PassportID, F.FlightNumber, EndParkTime as DepatureTime, AirlineCallsign, ParkingPositionLabel FROM PassengerMovement
JOIN Passenger P on P.ID = PassengerMovement.Passenger
JOIN Flight F on F.FlightNumber = PassengerMovement.FlightNumber
WHERE Type = 'Departure';

    --  print all departing passengers
SELECT Passenger as PassengerID, Name, Surname, PassportID, F.FlightNumber, StartParkTime as ArrivalTime, AirlineCallsign, ParkingPositionLabel FROM PassengerMovement
JOIN Passenger P on P.ID = PassengerMovement.Passenger
JOIN Flight F on F.FlightNumber = PassengerMovement.FlightNumber
WHERE Type = 'Arrival';


-- table: passengerTable.sql
    --  just print them all
SELECT * FROM Passenger;

    --  just print them all readable
SELECT Passenger.ID as PassengerID, Surname, Passenger.Name as Name, PassportID, Street, HouseNumber, Residence as LocationID, L.Zip, L.Name as CityName, L.Country as CountryID, C.Name as CountryName FROM Passenger
JOIN Location L on L.ID = Passenger.Residence
JOIN Country C on L.Country = C.ID
ORDER BY Passenger.Name, Surname;

    --  print number of passengers distributed across countries
SELECT L.Country as CountryID, C.Name as CountryName, COUNT(Passenger.ID) as NumberOfPassengers FROM Passenger
JOIN Location L on L.ID = Passenger.Residence
JOIN Country C on L.Country = C.ID
GROUP BY C.ID
ORDER BY 1;


-- table: planeTypeTable.sql
    --  just print them all
SELECT * FROM PlaneType;

    --  just print them all readable
SELECT Name FROM PlaneType
ORDER BY Name;

    --  print the operating plane types per airline
SELECT Callsign, A.Name, GROUP_CONCAT(CONCAT(' ', PT.Name)) as OperatingPlaneTypes FROM Airline A
JOIN Flight F on A.Callsign = F.AirlineCallsign
JOIN PlaneType PT on F.PlaneType = PT.ID
GROUP BY A.Callsign;


-- table: terminalTable.sql
    --  just print them all
SELECT * FROM Terminal;

    -- number of available parking positions
SELECT TerminalID, T.Label as Terminal, COUNT(PP.TerminalID) as AvailablePositions FROM Terminal T, ParkingPosition PP
WHERE T.ID = PP.TerminalID
GROUP BY T.ID;

    -- number of available parking positions for each plane type
SELECT TerminalID, T.Label as Terminal, PT.ID as PlaneTypeID, PT.Name as PlaneType, COUNT(PT.Name) as AvialablePositions FROM Terminal T, ParkingPosition PP, ParkingPositionPlaneType PPPT, PlaneType PT
WHERE T.ID = PP.TerminalID AND PP.Label = PPPT.ParkingPositionLabel AND PPPT.PlaneType = PT.ID
GROUP BY PT.Name, T.Label
ORDER BY TerminalID, PlaneTypeID;


