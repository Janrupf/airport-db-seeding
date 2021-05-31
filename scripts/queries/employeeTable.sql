    --  just print them all
SELECT * FROM AirportEmployee;

    --  just print them all readable
SELECT RegistrationNumber, AE.Surname, AE.Name, AE.Job, AE.HouseNumber, AE.Street, AE.Residence as LocationID, L.Zip, L.Name as CityName, L.Country as CountryID, C.Name as CountryName FROM AirportEmployee AE
JOIN Location L on AE.Residence = L.ID
JOIN Country C on L.Country = C.ID;

    --  distribution by country
SELECT L.Country as CountryID, C.Name as CountryName, COUNT(C.ID) as NumberOfEmloyees FROM AirportEmployee AE
JOIN Location L on AE.Residence = L.ID
JOIN Country C on L.Country = C.ID
GROUP BY C.Name
ORDER BY 2;

    --  distribution by job
SELECT Job, COUNT(RegistrationNumber) as JobCount FROM AirportEmployee
GROUP BY Job
ORDER BY 2 DESC;

    -- get all not working employees
SELECT RegistrationNumber, CONCAT_WS(' ', Surname, Name) as Name, Job FROM AirportEmployee AE
WHERE RegistrationNumber NOT IN (
    SELECT EmployeeNumber FROM VehicleOperation
);

    --  get percentage of working and not working employees distributed by job
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