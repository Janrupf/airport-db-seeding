    --  just print them all
SELECT * FROM ParkingPosition;

    --  just print them all readable
SELECT ParkingPosition.Label as PositionLabel, T.Label as Terminal, ST_AsText(GeographicPosition), GROUP_CONCAT(CONCAT(' ',PT.Name)) as PossiblePlaneTypes FROM ParkingPosition
JOIN Terminal T on T.ID = ParkingPosition.TerminalID
JOIN ParkingPositionPlaneType PPPT on ParkingPosition.Label = PPPT.ParkingPositionLabel
JOIN PlaneType PT on PT.ID = PPPT.PlaneType
GROUP BY ParkingPositionLabel;

    --  todo show occupied