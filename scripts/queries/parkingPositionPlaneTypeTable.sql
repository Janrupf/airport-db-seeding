    --  just print them all
SELECT * FROM ParkingPositionPlaneType;

    --  just print them all readable
SELECT ParkingPositionLabel, GROUP_CONCAT(CONCAT(' ', Name)) FROM ParkingPositionPlaneType PPPT
JOIN PlaneType PT on PT.ID = PPPT.PlaneType
GROUP BY ParkingPositionLabel
ORDER BY ParkingPositionLabel;