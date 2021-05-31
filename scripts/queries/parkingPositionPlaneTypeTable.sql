    --  Gibt die Tabelle ParkingPositionPlaneType aus.
SELECT * FROM ParkingPositionPlaneType;

    --  PPT.1: Gibt die Tabelle ParkingPositionPlaneType formatiert aus und ergänzt durch Beziehungen Daten.
SELECT ParkingPositionLabel, GROUP_CONCAT(CONCAT(' ', Name)) FROM ParkingPositionPlaneType PPPT
JOIN PlaneType PT on PT.ID = PPPT.PlaneType
GROUP BY ParkingPositionLabel
ORDER BY ParkingPositionLabel;