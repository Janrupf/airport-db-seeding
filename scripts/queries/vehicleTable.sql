    --  just print them all
SELECT * FROM ApronVehicle;

    --  print all free vehicles - todo add working times, operation and service
SELECT * FROM ApronVehicle
WHERE Status = 'Parking';

    --  todo print count by gate

    --  todo add more