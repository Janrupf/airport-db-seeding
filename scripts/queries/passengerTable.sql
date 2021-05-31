    --  Gibt die Tabelle Passenger aus.
SELECT * FROM Passenger;

    --  Gibt die Tabelle Passenger aus und ergänzt durch Beziehungen Daten.
SELECT Passenger.ID as PassengerID, Surname, Passenger.Name as Name, PassportID, Street, HouseNumber, Residence as LocationID, L.Zip, L.Name as CityName, L.Country as CountryID, C.Name as CountryName FROM Passenger
JOIN Location L on L.ID = Passenger.Residence
JOIN Country C on L.Country = C.ID
ORDER BY Passenger.Name, Surname;

    --  Gibt die Anzahl der Passagiere pro Land aus.
SELECT L.Country as CountryID, C.Name as CountryName, COUNT(Passenger.ID) as NumberOfPassengers FROM Passenger
JOIN Location L on L.ID = Passenger.Residence
JOIN Country C on L.Country = C.ID
GROUP BY C.ID
ORDER BY 1;