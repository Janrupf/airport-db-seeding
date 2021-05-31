    --  just print them all
SELECT * FROM Passenger;

    --  just print them all readable
SELECT Passenger.ID as PassengerID, Surname, Passenger.Name as Name, PassportID, Street, HouseNumber, Residence as LocationID, L.Zip, L.Name as CityName, L.Country as CountryID, C.Name as CountryName FROM Passenger
JOIN Location L on L.ID = Passenger.Residence
JOIN Country C on L.Country = C.ID
ORDER BY Passenger.Name, Surname;

    --  print number of passengers distributed across countries
SELECT L.Country as CountryID, C.Name as CountryName, COUNT(Passenger.ID) as NumberOfPassengers FROM Passenger
JOIN Location L on L.ID = Passenger.Residence
JOIN Country C on L.Country = C.ID
GROUP BY C.ID
ORDER BY 1;