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