    --  just print them all
SELECT * FROM AirportEmployee AE;

    --  just print them all readable
SELECT AE.Surname, AE.Name, AE.Job, AE.HouseNumber, AE.Street, L.Zip, L.Name as CityName, C.Name as CountryName FROM AirportEmployee AE
JOIN Location L on AE.Residence = L.ID
JOIN Country C on L.Country = C.ID;

    --  distribution by country
SELECT C.Name as CountryName, COUNT(C.ID) as NumberOfEmloyees FROM AirportEmployee AE
JOIN Location L on AE.Residence = L.ID
JOIN Country C on L.Country = C.ID
GROUP BY C.Name
ORDER BY 2 DESC;

    --  distribution by job
SELECT Job, COUNT(RegistrationNumber) as JobCount FROM AirportEmployee
GROUP BY Job
ORDER BY 2 DESC;

    --  todo add working, free and vacation from work time, operation and service