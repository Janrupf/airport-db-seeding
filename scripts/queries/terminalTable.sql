    --  just print them all
SELECT * FROM Terminal;

    -- number of available parking positions
SELECT T.Label, COUNT(PP.TerminalID) as AvailablePositions FROM Terminal T, ParkingPosition PP
WHERE T.ID = PP.TerminalID
GROUP BY T.ID;

    -- number of available parking positions for each plane type
SELECT T.Label, PT.Name, COUNT(PT.Name) FROM Terminal T, ParkingPosition PP, ParkingPositionPlaneType PPPT, PlaneType PT
WHERE T.ID = PP.TerminalID AND PP.Label = PPPT.ParkingPositionLabel AND PPPT.PlaneType = PT.ID
GROUP BY PT.Name, T.Label
ORDER BY 1,2;