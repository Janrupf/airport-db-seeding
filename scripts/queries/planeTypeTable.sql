    --  just print them all
SELECT * FROM PlaneType;

    --  just print them all readable
SELECT Name FROM PlaneType
ORDER BY Name;

    --  todo some more stuff here:
    --      - airlines operating plane types
    --      - passenger distribution

    --  print the operating plane types per airline
SELECT A.Name, CONCAT_WS(', ', PT.Name) FROM Airline A
JOIN Flight F on A.Callsign = F.AirlineCallsign
JOIN PlaneType PT on F.PlaneType = PT.ID
GROUP BY A.Callsign;