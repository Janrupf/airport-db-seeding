    --  just print them all
SELECT * FROM PlaneType;

    --  just print them all readable
SELECT Name FROM PlaneType
ORDER BY Name;

    --  print the operating plane types per airline
SELECT Callsign, A.Name, GROUP_CONCAT(CONCAT(' ', PT.Name)) as OperatingPlaneTypes FROM Airline A
JOIN Flight F on A.Callsign = F.AirlineCallsign
JOIN PlaneType PT on F.PlaneType = PT.ID
GROUP BY A.Callsign;