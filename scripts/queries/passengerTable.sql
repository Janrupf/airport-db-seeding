    --  just print them all
SELECT * FROM Passenger;

    --  just print them all readable
SELECT Surname, Passenger.Name, PassportID, Street, HouseNumber, L.Zip, L.Name as CityName, C.Name FROM Passenger
JOIN Location L on L.ID = Passenger.Residence
JOIN Country C on L.Country = C.ID
ORDER BY Passenger.Name, Surname;

    --  print number of passengers distributed across countries
SELECT C.Name as Country, COUNT(Passenger.ID) as NumberOfPassengers FROM Passenger
JOIN Location L on L.ID = Passenger.Residence
JOIN Country C on L.Country = C.ID
GROUP BY C.ID
ORDER BY 1;