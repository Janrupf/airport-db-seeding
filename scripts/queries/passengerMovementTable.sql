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