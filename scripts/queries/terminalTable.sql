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