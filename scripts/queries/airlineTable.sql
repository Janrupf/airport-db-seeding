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