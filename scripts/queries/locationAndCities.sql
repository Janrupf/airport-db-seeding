    --  Gibt die Tabelle Location aus.
SELECT * FROM Location;

    --  LC.1: Gibt die Tabelle Location aus und ergänzt durch Beziehungen Daten.
SELECT Location.ID as CityID, Location.Name as CityName, Zip, C.ID as CountryID, C.Name as CountryName FROM Location
JOIN Country C on Location.Country = C.ID
ORDER BY C.Name, Location.Name;

    --  LC.2: Gibt alle deutschen Städte aus
SELECT Location.ID as CityID, Location.Name as CityName, Zip FROM Location
JOIN Country C on Location.Country = C.ID
WHERE C.Name = 'Germany'
ORDER BY Location.Name;