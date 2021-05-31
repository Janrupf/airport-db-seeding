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