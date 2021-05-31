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