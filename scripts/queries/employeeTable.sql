    --  Gibt die Tabelle AirportEmployee aus.
SELECT * FROM AirportEmployee;

    --  AE.1: Gibt die Tabelle AirportEmployee aus und ergänzt durch Beziehungen Daten.
SELECT RegistrationNumber, AE.Surname, AE.Name, AE.Job, AE.HouseNumber, AE.Street, AE.Residence as LocationID, L.Zip, L.Name as CityName, L.Country as CountryID, C.Name as CountryName FROM AirportEmployee AE
JOIN Location L on AE.Residence = L.ID
JOIN Country C on L.Country = C.ID;

    --  AE.2: Gibt eine Übersicht, aus welchem Land wie viele Mitarbeiter kommen.
SELECT L.Country as CountryID, C.Name as CountryName, COUNT(C.ID) as NumberOfEmloyees FROM AirportEmployee AE
JOIN Location L on AE.Residence = L.ID
JOIN Country C on L.Country = C.ID
GROUP BY C.Name
ORDER BY 2;

    --  AE.3: Gibt eine Übersicht, wie viele Mitarbeiter welchen Job haben.
SELECT Job, COUNT(RegistrationNumber) as JobCount FROM AirportEmployee
GROUP BY Job
ORDER BY 2 DESC;

    -- AE.4: Gibt alle Mitarbeiter aus, die nicht in einer Schicht eingeteilt sind.
SELECT RegistrationNumber, CONCAT_WS(' ', Surname, Name) as Name, Job FROM AirportEmployee AE
WHERE RegistrationNumber NOT IN (
    SELECT EmployeeNumber FROM VehicleOperation
);

    --  AE.4: Gibt eine Übersicht, in welchem Beruf wie viele Mitarbeiter arbeiten oder frei haben.
WITH total(Job, TotalCount) as (SELECT Job, COUNT(Job) as TotalCount FROM AirportEmployee GROUP BY Job)
SELECT total.Job, WorkingCount, WorkingCount*100 / TotalCount as WorkingPercentag, NotWorkingCount, NotWorkingCount*100 / TotalCount as NotWorkingPercentag FROM total
LEFT OUTER JOIN (
    SELECT A.Job, COUNT(*) as WorkingCount FROM VehicleOperation VO
    JOIN AirportEmployee A on A.RegistrationNumber = VO.EmployeeNumber
    GROUP BY A.Job
) Working ON total.Job = Working.Job
LEFT OUTER JOIN (
    SELECT Job, COUNT(*) as NotWorkingCount FROM AirportEmployee AE
    WHERE RegistrationNumber NOT IN (
        SELECT EmployeeNumber FROM VehicleOperation
    )
    GROUP BY Job
) NotWorking ON total.Job = NotWorking.Job
GROUP BY Job;