    --  just print them all
SELECT * FROM ApronVehicle;

    --  print all free vehicles
SELECT * FROM ApronVehicle
WHERE Status = 'Parking';