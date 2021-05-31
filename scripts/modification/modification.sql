-- -------------------- --
-- Änderungen an Flügen --
-- -------------------- --
-- Erstellen/registrieren eines neuen Fluges:
INSERT INTO Flight (PlaneRegistration, StartParkTime, EndParkTime, PlaneType, AirlineCallsign, ParkingPositionLabel)
VALUES (
        'LX-8IRM', -- Kennzeichen des Flugzeugs
        '2021-05-31 19:00:00', -- Datum und Zeit ab dem die Parkzeit des Fluges startet
        '2021-05-31 21:45:00', -- Datum und Zeit ab dem die Parkzeit des Fluges endet
        27, -- Typ des Flugzeugs, in diesem Fall ein Airbus A340-500
        'LUXAIR', -- Rufzeichen der Airline, in diesem Fall von Luxair
        '184' -- Die Position, an der das Flugzeug steht, in diesem Fall 184
);

-- Ändern der Parkposition und Flugzeugtyps für den Flug mit der Nummer 4
UPDATE Flight SET ParkingPositionLabel = '182', PlaneType = 97 WHERE FlightNumber = 4;

-- ------------------- --
-- Änderungen an Slots --
-- ------------------- --
UPDATE Slot SET AirlineCallsign = NULL WHERE ID = 918; -- Markiert den Slot mit der ID 918 als Frei
UPDATE Slot SET AirlineCallsign = 'LUFTHANSA' WHERE ID = 921; -- Weist den Slot mit der ID 921 der Lufthansa zu
UPDATE Airline SET SlotCount = 5 WHERE Callsign = 'AIR CHINA'; -- Setzt die maximal gebuchten slots von Air China

-- -------------------------- --
-- Änderungen an Mitarbeitern --
-- -------------------------- --

-- Vollständiges entfernen des Mitarbeiters mit der Nummer 10:
DELETE FROM VehicleOperation WHERE EmployeeNumber = 10; -- Sicherstellen, dass der Mitarbeiter keine Fahrzeuge mehr bedient
DELETE FROM Service WHERE EmployeeNumber = 10; -- Sicherstellen, dass der Mitarbeiter keine Flüge mehr abfertigt
DELETE FROM AirportEmployee WHERE RegistrationNumber = 10; -- Endgültiges löschen des Mitarbeiters

-- ------------------------- --
-- Änderungen an Passagieren --
-- ------------------------- --
-- Registrieren eines neuen Passagiers
INSERT INTO Passenger (Name, Surname, PassportID, HouseNumber, Street, Residence)
VALUES (
        'Weber', -- Name
        'Anna', -- Vorname
        733432, -- Pass Identifikationsnummer
        171, -- Haus Nummer
        'Kegelstraße', -- Straßenname
        4425 -- Ort, in diesem Fall Ulm
);

-- Ändern des Nachnamens des Passagiers mit der Nummer 1999
UPDATE Passenger SET Surname = 'Castle' WHERE ID = 1999;
