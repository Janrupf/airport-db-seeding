    --  just print them all
SELECT * FROM Location;

    --  just print them all readable
SELECT Location.ID as CityID, Location.Name as CityName, Zip, C.ID as CountryID, C.Name as CountryName FROM Location
JOIN Country C on Location.Country = C.ID
ORDER BY C.Name, Location.Name;

    --  print all german cities
SELECT Location.ID as CityID, Location.Name as CityName, Zip FROM Location
JOIN Country C on Location.Country = C.ID
WHERE C.Name = 'Germany'
ORDER BY Location.Name;