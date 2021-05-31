-- table: airlineTable.sql
    --  Gibt die Tabelle Airline aus.
SELECT * FROM Airline; -- einfache Projektion

    --  AT.1: Gibt die Tabelle Airline aus und ergänzt durch Beziehungen Daten.
SELECT Callsign, A.Name as AirlineName, SlotCount, Country as CountryID, C.Name as CountryName FROM Airline A -- Projektion mit Aliases
JOIN Country C on C.ID = A.Country; -- mit Beziehungen zwischen Airline und Country den Namen des Landes laden

    --  AT.2: Gibt eine Übersicht, aus welchem Land wie viele Airlines kommen.
SELECT C.Name as CountryName, COUNT(A.Callsign) as NumberOfAirlines FROM Airline A -- Projektion mit Aliases und Aggregatfunktion COUNT() zählt die Eintrage der Airlines pro Land
JOIN Country C on C.ID = A.Country -- mit Beziehungen zwischen Airline und Country den Namen des Landes laden
GROUP BY C.ID -- Gruppieren der Elemente nach dem Land
ORDER BY 2 DESC; -- absteigend nach der 2. Spalte (NumberOfAirlines) sortieren

    --  AT.3: Gibt nur Deutsche Airlines aus.
SELECT Callsign, A.Name as AirlineName, SlotCount, Country as CountryID, C.Name as CountryName FROM Airline A -- Projektion mit Aliases
JOIN Country C on C.ID = A.Country -- mit Beziehungen zwischen Airline und Country den Namen des Landes laden
WHERE C.Name = 'Germany'; -- Selektion des Namen des Landes (CountryName oder C.Name) nach "Deutschland"

    --  AT.4: Gibt die Airlines aus, die mehr Slots haben, als alle Deutsche zusammen.
SELECT A.Callsign, A.Name as AirlineName, SlotCount, Country as CountryID, C.Name as CountryName FROM Airline A -- Projektion mit Aliases
JOIN Country C on C.ID = A.Country -- mit Beziehungen zwischen Airline und Country den Namen des Landes laden
WHERE A.SlotCount > ( -- Selektion der Slot-Größe mit einer verschachtelten Abfrage
    SELECT SUM(A.SlotCount) FROM Airline A -- Aggregatfunktion SUM() summiert die Slots der deutschen Airlines (siehe At.3)
    JOIN Country C on C.ID = A.Country
    WHERE C.Name = 'Germany'
);

    --  AT.5: Gibt die Anzahl der Passagiere aus, die eine Airline befördert hat.
SELECT Callsign, Name, SlotCount, SUM(Passengers) as Passengers FROM Airline A -- Projektion mit Aliases und Aggregatfunktion SUM() summiert die Passagiere der Airlines
JOIN Flight F on A.Callsign = F.AirlineCallsign -- mit Beziehungen zwischen Flight und Airline...
JOIN ( -- ... Beziehungen zu Passagieren in der verschachtelten Abfrage herstellen
    SELECT F.FlightNumber, AirlineCallsign, COUNT(*) as Passengers FROM PassengerMovement -- Projektion mit Aliases und Aggregatfunktion COUNT() zählt die Passagiere pro Flug
    JOIN Flight F on F.FlightNumber = PassengerMovement.FlightNumber -- siehe JOIN davor
    GROUP BY F.FlightNumber -- Gruppieren der Elemente nach der Flugnummer
) PM on F.FlightNumber = PM.FlightNumber
GROUP BY Callsign; -- Gruppieren der Elemente nach dem Callsign der Airline

    --  AT.6: Gibt den prozentualen Anteil der Passagiere aus, die eine Airline befördert hat.
SELECT Callsign, Passengers*100 / ( -- Projektion mit Aliases und arithmetischen Befehlen
    SELECT COUNT(*) FROM PassengerMovement -- verschachtelte Abfrage, um alle Passagierbewegungen zu erhalten
) as percentage FROM (
    SELECT Callsign,  SUM(Passengers) as Passengers FROM Airline A -- Projektion mit Aliases und Aggregatfunktion SUM() summiert die Passagiere der Airlines
    JOIN Flight F on A.Callsign = F.AirlineCallsign -- Beziehung zwischen Flight, Airline...
    JOIN ( -- ... und Passenger nutzen, um ...
        SELECT F.FlightNumber, COUNT(*) as Passengers FROM PassengerMovement -- ...  die Zahl der Passagiere pro Airline zu erhalten
        JOIN Flight F on F.FlightNumber = PassengerMovement.FlightNumber
        GROUP BY F.FlightNumber -- Gruppieren der Elemente nach der Flugnummer
    ) PM on F.FlightNumber = PM.FlightNumber
    GROUP BY Callsign -- Gruppieren der Elemente nach dem Callsign, also der Airline
) total;


-- table: employeeTable.sql
    --  Gibt die Tabelle AirportEmployee aus.
SELECT * FROM AirportEmployee;

    --  AE.1: Gibt die Tabelle AirportEmployee aus und ergänzt durch Beziehungen Daten.
SELECT RegistrationNumber, AE.Surname, AE.Name, AE.Job, AE.HouseNumber, AE.Street, AE.Residence as LocationID, L.Zip, L.Name as CityName, L.Country as CountryID, C.Name as CountryName FROM AirportEmployee AE
JOIN Location L on AE.Residence = L.ID
JOIN Country C on L.Country = C.ID;

    --  AE.2: Gibt eine Übersicht, aus welchem Land wie viele Mitarbeiter kommen.
SELECT L.Country as CountryID, C.Name as CountryName, COUNT(C.ID) as NumberOfEmloyees FROM AirportEmployee AE
JOIN Location L on AE.Residence = L.ID
JOIN Country C on L.Country = C.ID
GROUP BY C.Name
ORDER BY 2;

    --  AE.3: Gibt eine Übersicht, wie viele Mitarbeiter welchen Job haben.
SELECT Job, COUNT(RegistrationNumber) as JobCount FROM AirportEmployee
GROUP BY Job
ORDER BY 2 DESC;

    -- AE.4: Gibt alle Mitarbeiter aus, die nicht in einer Schicht eingeteilt sind.
SELECT RegistrationNumber, CONCAT_WS(' ', Surname, Name) as Name, Job FROM AirportEmployee AE
WHERE RegistrationNumber NOT IN (
    SELECT EmployeeNumber FROM VehicleOperation
);

    --  AE.4: Gibt eine Übersicht, in welchem Beruf wie viele Mitarbeiter arbeiten oder frei haben.
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
    --  Gibt die Tabelle Location aus.
SELECT * FROM Location;

    --  LC.1: Gibt die Tabelle Location aus und ergänzt durch Beziehungen Daten.
SELECT Location.ID as CityID, Location.Name as CityName, Zip, C.ID as CountryID, C.Name as CountryName FROM Location
JOIN Country C on Location.Country = C.ID
ORDER BY C.Name, Location.Name;

    --  LC.2: Gibt alle deutschen Städte aus
SELECT Location.ID as CityID, Location.Name as CityName, Zip FROM Location
JOIN Country C on Location.Country = C.ID
WHERE C.Name = 'Germany'
ORDER BY Location.Name;


-- table: parkingPositionPlaneTypeTable.sql
    --  Gibt die Tabelle ParkingPositionPlaneType aus.
SELECT * FROM ParkingPositionPlaneType;

    --  PPT.1: Gibt die Tabelle ParkingPositionPlaneType formatiert aus und ergänzt durch Beziehungen Daten.
SELECT ParkingPositionLabel, GROUP_CONCAT(CONCAT(' ', Name)) FROM ParkingPositionPlaneType PPPT
JOIN PlaneType PT on PT.ID = PPPT.PlaneType
GROUP BY ParkingPositionLabel
ORDER BY ParkingPositionLabel;


-- table: parkingPositionTable.sql
    --  Gibt die Tabelle ParkingPosition aus.
SELECT * FROM ParkingPosition;

    --  PT.1: Gibt die Tabelle ParkingPosition formatiert aus und ergänzt durch Beziehungen Daten.
SELECT ParkingPosition.Label as PositionLabel, TerminalID, T.Label as Terminal, ST_AsText(GeographicPosition) as GeoPositionReference, GROUP_CONCAT(CONCAT(' ',PT.Name)) as PossiblePlaneTypes FROM ParkingPosition
JOIN Terminal T on T.ID = ParkingPosition.TerminalID
JOIN ParkingPositionPlaneType PPPT on ParkingPosition.Label = PPPT.ParkingPositionLabel
JOIN PlaneType PT on PT.ID = PPPT.PlaneType
GROUP BY ParkingPositionLabel;

    --  PT.2: Gibt die ParkingPositions aus und zeigt, wann ein Flug eine Position belegt.
SELECT PP.Label, TerminalID, T.Label as Terminal, Callsign, A.Name as AirlineName, CONCAT(A.Name, ROW_NUMBER() over (PARTITION BY F.AirlineCallsign)) as FlightNumber, CONCAT_WS(' - ', F.StartParkTime, F.EndParkTime) as ParkingTime FROM ParkingPosition PP
JOIN Flight F on PP.Label = F.ParkingPositionLabel
JOIN Airline A on F.AirlineCallsign = A.Callsign
JOIN Terminal T on PP.TerminalID = T.ID
ORDER BY PP.Label;


-- table: passengerMovementTable.sql
    -- Gibt die Tabelle PassengerMovement aus.
SELECT * FROM PassengerMovement;

    --  Gibt alle Passagiere aus, die vom Flughafen fliegen
SELECT Passenger as PassengerID, Name, Surname, PassportID, F.FlightNumber, EndParkTime as DepatureTime, AirlineCallsign, ParkingPositionLabel FROM PassengerMovement
JOIN Passenger P on P.ID = PassengerMovement.Passenger
JOIN Flight F on F.FlightNumber = PassengerMovement.FlightNumber
WHERE Type = 'Departure';

    --  Gibt alle Passagiere aus, die am Flughafen ankommen
SELECT Passenger as PassengerID, Name, Surname, PassportID, F.FlightNumber, StartParkTime as ArrivalTime, AirlineCallsign, ParkingPositionLabel FROM PassengerMovement
JOIN Passenger P on P.ID = PassengerMovement.Passenger
JOIN Flight F on F.FlightNumber = PassengerMovement.FlightNumber
WHERE Type = 'Arrival';


-- table: passengerTable.sql
    --  Gibt die Tabelle Passenger aus.
SELECT * FROM Passenger;

    --  Gibt die Tabelle Passenger aus und ergänzt durch Beziehungen Daten.
SELECT Passenger.ID as PassengerID, Surname, Passenger.Name as Name, PassportID, Street, HouseNumber, Residence as LocationID, L.Zip, L.Name as CityName, L.Country as CountryID, C.Name as CountryName FROM Passenger
JOIN Location L on L.ID = Passenger.Residence
JOIN Country C on L.Country = C.ID
ORDER BY Passenger.Name, Surname;

    --  Gibt die Anzahl der Passagiere pro Land aus.
SELECT L.Country as CountryID, C.Name as CountryName, COUNT(Passenger.ID) as NumberOfPassengers FROM Passenger
JOIN Location L on L.ID = Passenger.Residence
JOIN Country C on L.Country = C.ID
GROUP BY C.ID
ORDER BY 1;


-- table: planeTypeTable.sql
    --  Gibt die Tabelle PlaneType aus.
SELECT * FROM PlaneType;

    --  Gibt die Tabelle PlaneType aus und sortiert diese zur besseren Übersicht nach dem Namen
SELECT Name FROM PlaneType
ORDER BY Name;

    --  Gibt aus, welche Airlines welche Flugzeuge verwenden
SELECT Callsign, A.Name, GROUP_CONCAT(CONCAT(' ', PT.Name)) as OperatingPlaneTypes FROM Airline A
JOIN Flight F on A.Callsign = F.AirlineCallsign
JOIN PlaneType PT on F.PlaneType = PT.ID
GROUP BY A.Callsign;


-- table: terminalTable.sql
    --  Gibt die Tabelle Terminal aus.
SELECT * FROM Terminal;

    --  Gibt die Nummer der verfügbaren ParkPositions pro Terminal aus.
SELECT TerminalID, T.Label as Terminal, COUNT(PP.TerminalID) as AvailablePositions FROM Terminal T, ParkingPosition PP
WHERE T.ID = PP.TerminalID
GROUP BY T.ID;


