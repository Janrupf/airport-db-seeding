    --  just print them all
SELECT * FROM ParkingPosition;

    --  just print them all readable
SELECT ParkingPosition.Label as PositionLabel, T.Label as Terminal, ST_AsText(GeographicPosition), GROUP_CONCAT(CONCAT(' ',PT.Name)) as PossiblePlaneTypes FROM ParkingPosition
JOIN Terminal T on T.ID = ParkingPosition.TerminalID
JOIN ParkingPositionPlaneType PPPT on ParkingPosition.Label = PPPT.ParkingPositionLabel
JOIN PlaneType PT on PT.ID = PPPT.PlaneType
GROUP BY ParkingPositionLabel;

    --  print occupied gates with the time and flight
SELECT PP.Label, T.Label, A.Name, CONCAT_WS(', ', A.Name, ROW_NUMBER() over (PARTITION BY F.AirlineCallsign)) as Flight, CONCAT_WS(' - ', F.StartParkTime, F.EndParkTime) FROM ParkingPosition PP
JOIN Flight F on PP.Label = F.ParkingPositionLabel
JOIN Airline A on F.AirlineCallsign = A.Callsign
JOIN Terminal T on PP.TerminalID = T.ID
ORDER BY PP.Label;