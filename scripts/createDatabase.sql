CREATE DATABASE 'airport';
USE 'airport';

CREATE TABLE Country (
	ID TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
	Name VARCHAR(255) NOT NULL,
	PRIMARY KEY(ID)
);

CREATE TABLE Airline (
	Callsign VARCHAR(64) NOT NULL,
	Name VARCHAR(255) NOT NULL,
	SlotCount INT UNSIGNED NOT NULL,
	Country TINYINT UNSIGNED NOT NULL,
	FOREIGN KEY(Country) REFERENCES Country(ID),
	PRIMARY KEY(Callsign)
);

CREATE TABLE Slot (
    	ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    	Type ENUM('Departure', 'Arrival') NOT NULL,
    	StartTime TIME NOT NULL,
    	EndTime TIME NOT NULL,
    	AirlineCallsign VARCHAR(64),
    	FOREIGN KEY(AirlineCallsign) REFERENCES Airline(Callsign),
    	PRIMARY KEY(ID)
);

CREATE TABLE Terminal (
    	ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    	Label VARCHAR(64) NOT NULL,
    	PRIMARY KEY(ID)
);

CREATE TABLE ParkingPosition (
Label VARCHAR(8) NOT NULL,
    	GeographicPosition POINT NOT NULL,
    	TerminalID INT UNSIGNED NOT NULL,
    	PRIMARY KEY(Label),
    	SPATIAL INDEX(GeographicPosition),
    	FOREIGN KEY(TerminalID) REFERENCES Terminal(ID)
);


CREATE TABLE PlaneType (
    	ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    	Name VARCHAR(128) NOT NULL,
    	PRIMARY KEY(ID)
);

CREATE TABLE Flight (
     FlightNumber INT UNSIGNED NOT NULL AUTO_INCREMENT,
     PlaneRegistration VARCHAR(16) NOT NULL,
     StartParkTime TIMESTAMP NOT NULL,
     EndParkTime TIMESTAMP NOT NULL,
     PlaneType INT UNSIGNED NOT NULL,
     AirlineCallsign VARCHAR(64) NOT NULL,
     ParkingPositionLabel VARCHAR(8) NOT NULL,
     PRIMARY KEY(FlightNumber),
     FOREIGN KEY(PlaneType) REFERENCES PlaneType(ID),
     FOREIGN KEY(AirlineCallsign) REFERENCES Airline(Callsign),
     FOREIGN KEY(ParkingPositionLabel) REFERENCES ParkingPosition(Label)
);

CREATE TABLE Location (
	ID BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
	Zip INT UNSIGNED NOT NULL,
	Name VARCHAR(255) NOT NULL,
	Country TINYINT UNSIGNED NOT NULL,
	PRIMARY KEY(ID)
);

CREATE TABLE Passenger (
	ID BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    	Name VARCHAR(64) NOT NULL,
    	Surname VARCHAR(64) NOT NULL,
    	PassportID INT UNSIGNED NOT NULL,
    	HouseNumber INT UNSIGNED NOT NULL,
    	Street VARCHAR(255) NOT NULL,
    	Residence BIGINT UNSIGNED NOT NULL,
    	FOREIGN KEY(Residence) REFERENCES Location(ID),
    	PRIMARY KEY(ID)
);

CREATE TABLE ApronVehicle (
    LicensePlate VARCHAR(16) NOT NULL,
    Status ENUM('Parking', 'Moving') NOT NULL,
    Job ENUM(
        'tanker',
        'apron stairs',
        'luggage cart',
        'pushback',
        'follow me',
        'luggage loader',
        'cleaning vehicle',
        'toilet vehicle',
        'construction vehicle',
        'passenger bus',
        'crew bus',
        'emergency vehicle',
        'fire truck'
    ) NOT NULL,
    PRIMARY KEY(LicensePlate)
);

CREATE TABLE AirportEmployee (
    	RegistrationNumber BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    	Name VARCHAR(64) NOT NULL,
    	Surname VARCHAR(64) NOT NULL,
    	Job ENUM(
    		'load master',
    		'air traffic controller',
    		'cleaning power',
    		'paramedic',
    		'firefighter',
    		'apron driver',
    		'construction worker',
    		'bus driver'
    	) NOT NULL,
    	HouseNumber INT UNSIGNED NOT NULL,
    	Street VARCHAR(255) NOT NULL,
    	Residence BIGINT UNSIGNED NOT NULL,
    	FOREIGN KEY(Residence) REFERENCES Location(ID),
    	PRIMARY KEY(RegistrationNumber)
);

CREATE TABLE ParkingPositionPlaneType (
	ParkingPositionLabel VARCHAR(8) NOT NULL,
    	PlaneType INT UNSIGNED NOT NULL,
    	PRIMARY KEY(ParkingPositionLabel, PlaneType),
    	FOREIGN KEY(ParkingPositionLabel) REFERENCES ParkingPosition(Label),
    	FOREIGN KEY(PlaneType) REFERENCES PlaneType(ID)
);

CREATE TABLE PassengerMovement (
    Passenger BIGINT UNSIGNED NOT NULL,
    FlightNumber INT UNSIGNED NOT NULL,
    Type ENUM('Arrival', 'Departure'),
    PRIMARY KEY(Passenger, FlightNumber),
    FOREIGN KEY(Passenger) REFERENCES Passenger(ID),
    FOREIGN KEY(FlightNumber) REFERENCES Flight(FlightNumber)
);

CREATE TABLE Service (
    EmployeeNumber INT UNSIGNED NOT NULL,
    FlightNumber INT UNSIGNED NOT NULL,
    PRIMARY KEY(EmployeeNumber, FlightNumber),
    FOREIGN KEY(EmployeeNumber) REFERENCES AirportEmployee(RegistrationNumber),
    FOREIGN KEY(FlightNumber) REFERENCES Flight(FlightNumber)
);

CREATE TABLE VehicleWorkTime (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL,
    PRIMARY KEY(ID)
);

CREATE TABLE VehicleOperation (
    EmployeeNumber INT UNSIGNED NOT NULL,
    LicensePlate VARCHAR(16) NOT NULL,
    WorkTime INT UNSIGNED NOT NULL,
    PRIMARY KEY(EmployeeNumber, LicensePlate, WorkTime),
    FOREIGN KEY(EmployeeNumber) REFERENCES AirportEmployee(RegistrationNumber),
    FOREIGN KEY(LicensePlate) REFERENCES ApronVehicle(LicensePlate),
    FOREIGN KEY(WorkTime) REFERENCES VehicleWorkTime(ID)
);
