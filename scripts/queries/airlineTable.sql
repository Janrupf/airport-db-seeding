    --  just print them all
SELECT * FROM Airline A;

    --  just print them all readable
SELECT A.Callsign, A.Name as AirlineName, C.Name as CountryName FROM Airline A
JOIN Country C on C.ID = A.Country;

    --  distribution by country
SELECT C.Name as CountryName, COUNT(A.Callsign) as NumberOfAirlines FROM Airline A
JOIN Country C on C.ID = A.Country
GROUP BY C.ID
ORDER BY 2 DESC;

    --  print german airlines
SELECT A.Callsign, A.Name as AirlineName FROM Airline A
JOIN Country C on C.ID = A.Country
WHERE C.Name = 'Germany';

    --  print airlines which have more slots than all german airlines together
SELECT A.Callsign, A.Name as AirlineName, C.Name as CountryName FROM Airline A
JOIN Country C on C.ID = A.Country
WHERE A.SlotCount > (
    SELECT SUM(A.SlotCount) FROM Airline A
    JOIN Country C on C.ID = A.Country
    WHERE C.Name = 'Germany');

    --  todo some ideas here:
    --      - number of passengers transported (SUM)
    --      - passenger distribution transported