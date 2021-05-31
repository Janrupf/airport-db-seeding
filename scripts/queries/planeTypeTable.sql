    --  Gibt die Tabelle PlaneType aus.
SELECT * FROM PlaneType;

    --  Gibt die Tabelle PlaneType aus und sortiert diese zur besseren Übersicht nach dem Namen
SELECT Name FROM PlaneType
ORDER BY Name;

    --  Gibt aus, welche Airlines welche Flugzeuge verwenden
SELECT Callsign, A.Name, GROUP_CONCAT(CONCAT(' ', PT.Name)) as OperatingPlaneTypes FROM Airline A
JOIN Flight F on A.Callsign = F.AirlineCallsign
JOIN PlaneType PT on F.PlaneType = PT.ID
GROUP BY A.Callsign;