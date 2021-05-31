# Projekt Eckdaten

## Inhaltsverzeichnis
1. [Erstellung](#erstellung-der-datenbank-und-tabellen)
2. [Befüllen](#befllen-der-datenbank)
3. [Projektion und Selektion](#projektion-und-selektion)
4. [Anmerkungen](#anmerkungen)

## Erstellung der Datenbank und Tabellen

Benötigte SQL Befehle:
```sql
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
```

Diese Befehle sind ebenfalls als SQL Skript in `scripts/creation/createDatabase.sql` zu finden.

## Befüllen der Datenbank
Aus Gründen der Lesbarkeit wurden diese Abfragen nicht in diese Datei eingefügt, können aber
in den Dateien unter `scripts/*.sql` gefunden werden (ausgenommen die `queries.sql`).

## Projektion und Selektion
### Datenabfragen
Alle Abfragen in der Datenbank werden in der Datei `scripts/queries.sql` zusammengefasst gespeichert.
Der Inhalt dieser Datei wird aus allen SQL-Skripten in dem Ordner `scripts/queries/*.sql` zusammengesetzt.
Die Skripte sind in die verschiedenen Tabellen unterteilt, um einen besseren Überblick behalten zu können.

Vor jeder Abfrage steht, was die jeweilige Abfrage für Daten liefert und eine eindeutige ID.
Eine Übersicht über die Abfragen mit ID, welche SQL-Anweisungen genutzt werden und was für Ergebnisse zu erwarten sind, gibt es in diesem Dokument.

### Übersicht der SQL-Abfragen
Die erste Abfrage auf eine Tabelle ist immer eine Projektion der gesamten Tabelle, um eine Übersicht über die Spalten und Daten zu erhalten.

Aufgrund der großen Anzahl an Abfragen auf die große Anzahl von Tabellen wird zunächst nur ein Script mit entsprechenden Kommentaren eingereicht.
Dieses Skript erfüllt die Mindestanforderungen. Sollten weitere Erklärungen zu anderen Abfragen gewünscht sein, sind wir gerne bereit, diese nachzureichen.

### Demonstration von 7 Abfragen
Es wurden 7 Abfragen als Demonstration der Datenbank ausgewählt:

1.
```sql
--  Gibt die Tabelle Airline aus.
SELECT * FROM Airline; -- einfache Projektion
```

Ergebnis:

| Callsign | Name | SlotCount | Country |
| :--- | :--- | :--- | :--- |
| ADRIA | Adria Airways | 4 | 196 |
| AEGEAN | Aegean Airlines | 8 | 87 |
| AEROFLOT | Aeroflot Russian Airlines | 4 | 187 |
| AIR AZORES | SATA International | 2 | 180 |
| AIR BERLIN | Air Berlin | 89 | 55 |
| AIR CANADA | Air Canada | 7 | 36 |
| AIR CHINA | Air China | 6 | 46 |
| AIR MALTA | Air Malta | 4 | 149 |
| AIR PORTUGAL | TAP Portugal | 4 | 180 |
| AIR SICILIA | Air Sicilia | 2 | 106 |
| AIRBALTIC | Air Baltic | 4 | 131 |
| AIRFRANS | Air France | 4 | 73 |
| AIRINDIA | Air India Limited | 4 | 102 |
| ALITALIA | Alitalia | 2 | 106 |
| ALL NIPPON | All Nippon Airways | 2 | 110 |
| AMERICAN | American Airlines | 4 | 227 |
| ASIANA | Asiana Airlines | 2 | 118 |
| AUSTRIAN | Austrian Airlines | 4 | 11 |
| BEE-LINE | Brussels Airlines | 2 | 19 |
| CONDOR | Condor Flugdienst | 38 | 55 |
| CROATIA | Croatia Airlines | 8 | 95 |
| CYPRUS | Cyprus Airways | 3 | 53 |
| DELTA | Delta Air Lines | 2 | 227 |
| DOLOMOTI | Air Dolomiti | 8 | 106 |
| EASY | easyJet | 8 | 75 |
| EGYPTAIR | Egyptair | 2 | 63 |
| ELAL | El Al Israel Airlines | 3 | 100 |
| EMIRATES | Emirates | 2 | 2 |
| ETHIOPIAN | Ethiopian Airlines | 2 | 67 |
| ETIHAD | Etihad Airways | 2 | 2 |
| EUROPA | Air Europa | 2 | 66 |
| FINNAIR | Finnair | 4 | 68 |
| FLYNIKI | Niki | 2 | 11 |
| FORMOSA | Formosa Airlines | 4 | 223 |
| GERMAN WINGS | Germanwings | 2 | 55 |
| GERMANIA | Germania | 4 | 55 |
| HAINAN | Hainan Airlines | 2 | 46 |
| IBERIA | Iberia Airlines | 6 | 66 |
| ICEAIR | Icelandair | 2 | 105 |
| INTERSKY | Intersky | 2 | 11 |
| JORDANIAN | Royal Jordanian | 4 | 109 |
| KLM | KLM Royal Dutch Airlines | 4 | 162 |
| LITUANICA | Air Lituanica | 2 | 129 |
| LUFTHANSA | Lufthansa | 258 | 55 |
| LUXAIR | Luxair | 2 | 130 |
| MERAIR | Meridiana | 10 | 106 |
| NOR SHUTTLE | Norwegian Air Shuttle | 12 | 163 |
| NOUVELAIR | Nouvel Air Tunisie | 4 | 218 |
| OMAN AIR | Oman Air | 2 | 168 |
| POLET | Polet Airlines \(Priv\) | 2 | 187 |
| POLLOT | LOT Polish Airlines | 10 | 175 |
| QANTAS | Qantas | 2 | 12 |
| QATARI | Qatar Airways | 2 | 183 |
| ROYALAIR MAROC | Royal Air Maroc | 4 | 133 |
| SCANDINAVIAN | Scandinavian Airlines System | 15 | 193 |
| SHAMROCK | Aer Lingus | 4 | 99 |
| SIBERIAN AIRLINES | S7 Airlines | 4 | 187 |
| SINGAPORE | Singapore Airlines | 4 | 194 |
| SKYFOX | SkyWork Airlines | 2 | 41 |
| SPEEDBIRD | British Airways | 4 | 75 |
| SPRINGBOK | South African Airways | 4 | 242 |
| SUNEXPRESS | SunExpress | 4 | 220 |
| SUNTURK | Pegasus Airlines | 2 | 220 |
| SVERDLOVSK AIR | Ural Airlines | 4 | 187 |
| SWISS | Swiss International Air Lines | 6 | 41 |
| TAM | TAM Brazilian Airlines | 2 | 30 |
| TAROM | Tarom | 4 | 185 |
| THAI | Thai Airways International | 2 | 214 |
| TUNAIR | Tunisair | 6 | 218 |
| TURKAIR | Turkish Airlines | 4 | 220 |
| U S AIR | US Airways | 14 | 227 |
| UKRAINE INTERNATIONAL | Ukraine International Airlines | 2 | 225 |
| UNITED | United Airlines | 16 | 227 |
| VELOCITY | Virgin Australia | 0 | 12 |
| VIRGIN | Virgin Atlantic Airways | 8 | 75 |
| VOLOTEA | VOLOTEA Airways | 4 | 66 |
| YELLOW CAB | TUIfly | 29 | 55 |

2.
```sql
--  AT.1: Gibt die Tabelle Airline aus und ergänzt durch Beziehungen Daten.
SELECT Callsign, A.Name as AirlineName, SlotCount, Country as CountryID, C.Name as CountryName FROM Airline A -- Projektion mit Aliases
JOIN Country C on C.ID = A.Country; -- mit Beziehungen zwischen Airline und Country den Namen des Landes laden
```

Ergebnis:

| Callsign | AirlineName | SlotCount | CountryID | CountryName |
| :--- | :--- | :--- | :--- | :--- |
| ADRIA | Adria Airways | 4 | 196 | Slovenia |
| AEGEAN | Aegean Airlines | 8 | 87 | Greece |
| AEROFLOT | Aeroflot Russian Airlines | 4 | 187 | Russia |
| AIR AZORES | SATA International | 2 | 180 | Portugal |
| AIR BERLIN | Air Berlin | 89 | 55 | Germany |
| AIR CANADA | Air Canada | 7 | 36 | Canada |
| AIR CHINA | Air China | 6 | 46 | China |
| AIR MALTA | Air Malta | 4 | 149 | Malta |
| AIR PORTUGAL | TAP Portugal | 4 | 180 | Portugal |
| AIR SICILIA | Air Sicilia | 2 | 106 | Italy |
| AIRBALTIC | Air Baltic | 4 | 131 | Latvia |
| AIRFRANS | Air France | 4 | 73 | France |
| AIRINDIA | Air India Limited | 4 | 102 | India |
| ALITALIA | Alitalia | 2 | 106 | Italy |
| ALL NIPPON | All Nippon Airways | 2 | 110 | Japan |
| AMERICAN | American Airlines | 4 | 227 | United States |
| ASIANA | Asiana Airlines | 2 | 118 | South Korea |
| AUSTRIAN | Austrian Airlines | 4 | 11 | Austria |
| BEE-LINE | Brussels Airlines | 2 | 19 | Belgium |
| CONDOR | Condor Flugdienst | 38 | 55 | Germany |
| CROATIA | Croatia Airlines | 8 | 95 | Croatia |
| CYPRUS | Cyprus Airways | 3 | 53 | Cyprus |
| DELTA | Delta Air Lines | 2 | 227 | United States |
| DOLOMOTI | Air Dolomiti | 8 | 106 | Italy |
| EASY | easyJet | 8 | 75 | United Kingdom |
| EGYPTAIR | Egyptair | 2 | 63 | Egypt |
| ELAL | El Al Israel Airlines | 3 | 100 | Israel |
| EMIRATES | Emirates | 2 | 2 | United Arab Emirates |
| ETHIOPIAN | Ethiopian Airlines | 2 | 67 | Ethiopia |
| ETIHAD | Etihad Airways | 2 | 2 | United Arab Emirates |
| EUROPA | Air Europa | 2 | 66 | Spain |
| FINNAIR | Finnair | 4 | 68 | Finland |
| FLYNIKI | Niki | 2 | 11 | Austria |
| FORMOSA | Formosa Airlines | 4 | 223 | Taiwan |
| GERMAN WINGS | Germanwings | 2 | 55 | Germany |
| GERMANIA | Germania | 4 | 55 | Germany |
| HAINAN | Hainan Airlines | 2 | 46 | China |
| IBERIA | Iberia Airlines | 6 | 66 | Spain |
| ICEAIR | Icelandair | 2 | 105 | Iceland |
| INTERSKY | Intersky | 2 | 11 | Austria |
| JORDANIAN | Royal Jordanian | 4 | 109 | Jordan |
| KLM | KLM Royal Dutch Airlines | 4 | 162 | Netherlands |
| LITUANICA | Air Lituanica | 2 | 129 | Lithuania |
| LUFTHANSA | Lufthansa | 258 | 55 | Germany |
| LUXAIR | Luxair | 2 | 130 | Luxembourg |
| MERAIR | Meridiana | 10 | 106 | Italy |
| NOR SHUTTLE | Norwegian Air Shuttle | 12 | 163 | Norway |
| NOUVELAIR | Nouvel Air Tunisie | 4 | 218 | Tunisia |
| OMAN AIR | Oman Air | 2 | 168 | Oman |
| POLET | Polet Airlines \(Priv\) | 2 | 187 | Russia |
| POLLOT | LOT Polish Airlines | 10 | 175 | Poland |
| QANTAS | Qantas | 2 | 12 | Australia |
| QATARI | Qatar Airways | 2 | 183 | Qatar |
| ROYALAIR MAROC | Royal Air Maroc | 4 | 133 | Morocco |
| SCANDINAVIAN | Scandinavian Airlines System | 15 | 193 | Sweden |
| SHAMROCK | Aer Lingus | 4 | 99 | Ireland |
| SIBERIAN AIRLINES | S7 Airlines | 4 | 187 | Russia |
| SINGAPORE | Singapore Airlines | 4 | 194 | Singapore |
| SKYFOX | SkyWork Airlines | 2 | 41 | Switzerland |
| SPEEDBIRD | British Airways | 4 | 75 | United Kingdom |
| SPRINGBOK | South African Airways | 4 | 242 | South Africa |
| SUNEXPRESS | SunExpress | 4 | 220 | Turkey |
| SUNTURK | Pegasus Airlines | 2 | 220 | Turkey |
| SVERDLOVSK AIR | Ural Airlines | 4 | 187 | Russia |
| SWISS | Swiss International Air Lines | 6 | 41 | Switzerland |
| TAM | TAM Brazilian Airlines | 2 | 30 | Brazil |
| TAROM | Tarom | 4 | 185 | Romania |
| THAI | Thai Airways International | 2 | 214 | Thailand |
| TUNAIR | Tunisair | 6 | 218 | Tunisia |
| TURKAIR | Turkish Airlines | 4 | 220 | Turkey |
| U S AIR | US Airways | 14 | 227 | United States |
| UKRAINE INTERNATIONAL | Ukraine International Airlines | 2 | 225 | Ukraine |
| UNITED | United Airlines | 16 | 227 | United States |
| VELOCITY | Virgin Australia | 0 | 12 | Australia |
| VIRGIN | Virgin Atlantic Airways | 8 | 75 | United Kingdom |
| VOLOTEA | VOLOTEA Airways | 4 | 66 | Spain |
| YELLOW CAB | TUIfly | 29 | 55 | Germany |

3.
```sql
--  AT.2: Gibt eine Übersicht, aus welchem Land wie viele Airlines kommen.
SELECT C.Name as CountryName, COUNT(A.Callsign) as NumberOfAirlines FROM Airline A -- Projektion mit Aliases und Aggregatfunktion COUNT() zählt die Eintrage der Airlines pro Land
JOIN Country C on C.ID = A.Country -- mit Beziehungen zwischen Airline und Country den Namen des Landes laden
GROUP BY C.ID -- Gruppieren der Elemente nach dem Land
ORDER BY 2 DESC; -- absteigend nach der 2. Spalte (NumberOfAirlines) sortieren
```

Ergebnis:

| CountryName | NumberOfAirlines |
| :--- | :--- |
| Germany | 6 |
| United States | 4 |
| Italy | 4 |
| Russia | 4 |
| Spain | 3 |
| Turkey | 3 |
| United Kingdom | 3 |
| Austria | 3 |
| Tunisia | 2 |
| United Arab Emirates | 2 |
| Australia | 2 |
| Portugal | 2 |
| Switzerland | 2 |
| China | 2 |
| Luxembourg | 1 |
| Ethiopia | 1 |
| Latvia | 1 |
| Finland | 1 |
| Morocco | 1 |
| Taiwan | 1 |
| France | 1 |
| Malta | 1 |
| Ukraine | 1 |
| Netherlands | 1 |
| Greece | 1 |
| Norway | 1 |
| South Africa | 1 |
| Croatia | 1 |
| Oman | 1 |
| Ireland | 1 |
| Poland | 1 |
| Belgium | 1 |
| Israel | 1 |
| Brazil | 1 |
| India | 1 |
| Qatar | 1 |
| Canada | 1 |
| Iceland | 1 |
| Romania | 1 |
| Jordan | 1 |
| Sweden | 1 |
| Cyprus | 1 |
| Japan | 1 |
| Singapore | 1 |
| South Korea | 1 |
| Slovenia | 1 |
| Egypt | 1 |
| Lithuania | 1 |
| Thailand | 1 |

4.
```sql
--  AT.3: Gibt nur Deutsche Airlines aus.
SELECT Callsign, A.Name as AirlineName, SlotCount, Country as CountryID, C.Name as CountryName FROM Airline A -- Projektion mit Aliases
JOIN Country C on C.ID = A.Country -- mit Beziehungen zwischen Airline und Country den Namen des Landes laden
WHERE C.Name = 'Germany'; -- Selektion des Namen des Landes (CountryName oder C.Name) nach "Deutschland"
```

Ergebnis:

| Callsign | AirlineName | SlotCount | CountryID | CountryName |
| :--- | :--- | :--- | :--- | :--- |
| AIR BERLIN | Air Berlin | 89 | 55 | Germany |
| CONDOR | Condor Flugdienst | 38 | 55 | Germany |
| GERMAN WINGS | Germanwings | 2 | 55 | Germany |
| GERMANIA | Germania | 4 | 55 | Germany |
| LUFTHANSA | Lufthansa | 258 | 55 | Germany |
| YELLOW CAB | TUIfly | 29 | 55 | Germany |

5.

```sql
--  AT.4: Gibt die Airlines aus, die mehr Slots haben, als alle Deutsche zusammen.
SELECT A.Callsign, A.Name as AirlineName, SlotCount, Country as CountryID, C.Name as CountryName FROM Airline A -- Projektion mit Aliases
JOIN Country C on C.ID = A.Country -- mit Beziehungen zwischen Airline und Country den Namen des Landes laden
WHERE A.SlotCount > ( -- Selektion der Slot-Größe mit einer verschachtelten Abfrage
    SELECT SUM(A.SlotCount) FROM Airline A -- Aggregatfunktion SUM() summiert die Slots der deutschen Airlines (siehe At.3)
    JOIN Country C on C.ID = A.Country
    WHERE C.Name = 'Germany'
);
```

Ergebnis:

| Callsign | AirlineName | SlotCount | CountryID | CountryName |
| :--- | :--- | :--- | :--- | :--- |

Keine Daten - Deutschland ist einfach das Monopol

6.
```sql
--  AT.5: Gibt die Anzahl der Passagiere aus, die eine Airline befördert hat.
SELECT Callsign, Name, SlotCount, SUM(Passengers) as Passengers FROM Airline A -- Projektion mit Aliases und Aggregatfunktion SUM() summiert die Passagiere der Airlines
JOIN Flight F on A.Callsign = F.AirlineCallsign -- mit Beziehungen zwischen Flight und Airline...
JOIN ( -- ... Beziehungen zu Passagieren in der verschachtelten Abfrage herstellen
    SELECT F.FlightNumber, AirlineCallsign, COUNT(*) as Passengers FROM PassengerMovement -- Projektion mit Aliases und Aggregatfunktion COUNT() zählt die Passagiere pro Flug
    JOIN Flight F on F.FlightNumber = PassengerMovement.FlightNumber -- siehe JOIN davor
    GROUP BY F.FlightNumber -- Gruppieren der Elemente nach der Flugnummer
) PM on F.FlightNumber = PM.FlightNumber
GROUP BY Callsign; -- Gruppieren der Elemente nach dem Callsign der Airline
```

| Callsign | Name | SlotCount | Passengers |
| :--- | :--- | :--- | :--- |
| AIR CHINA | Air China | 6 | 184 |
| CYPRUS | Cyprus Airways | 3 | 225 |
| EGYPTAIR | Egyptair | 2 | 160 |
| EMIRATES | Emirates | 2 | 275 |
| JORDANIAN | Royal Jordanian | 4 | 243 |
| LUXAIR | Luxair | 2 | 248 |
| OMAN AIR | Oman Air | 2 | 207 |
| SPRINGBOK | South African Airways | 4 | 260 |
| THAI | Thai Airways International | 2 | 186 |
| YELLOW CAB | TUIfly | 29 | 210 |

7.
```sql
--  AT.6: Gibt den prozentualen Anteil der Passagiere aus, die eine Airline befördert hat.
SELECT Callsign, Passengers*100 / ( -- Projektion mit Aliases und arithmetischen Befehlen
    SELECT COUNT(*) FROM PassengerMovement -- verschachtelte Abfrage, um alle Passagierbewegungen zu erhalten
) as percentage FROM (
    SELECT Callsign,  SUM(Passengers) as Passengers FROM Airline A -- Projektion mit Aliases und Aggregatfunktion SUM() summiert die Passagiere der Airlines
    JOIN Flight F on A.Callsign = F.AirlineCallsign -- Beziehung zwischen Flight, Airline...
    JOIN ( -- ... und Passenger nutzen, um ...
        SELECT F.FlightNumber, COUNT(*) as Passengers FROM PassengerMovement -- ...  die Zahl der Passagiere pro Airline zu erhalten
        JOIN Flight F on F.FlightNumber = PassengerMovement.FlightNumber
        GROUP BY F.FlightNumber -- Gruppieren der Elemente nach der Flugnummer
    ) PM on F.FlightNumber = PM.FlightNumber
    GROUP BY Callsign -- Gruppieren der Elemente nach dem Callsign, also der Airline
) total;
```

Ergebnis:

| Callsign | percentage |
| :--- | :--- |
| AIR CHINA | 8.3712 |
| CYPRUS | 10.2366 |
| EGYPTAIR | 7.2793 |
| EMIRATES | 12.5114 |
| JORDANIAN | 11.0555 |
| LUXAIR | 11.2830 |
| OMAN AIR | 9.4177 |
| SPRINGBOK | 11.8289 |
| THAI | 8.4622 |
| YELLOW CAB | 9.5541 |

Es wurden weitere Abfragen entwickelt, welche im Ordner `scripts/queries` gefunden werden können.
Die oben gelisteten Abfragen stammen aus `scripts/queries/airlineTable.sql` und sind die Abfragen,
für welche ihre genauen Ergebnisse notiert wurden.

## Modifikation
Zur Demonstration der Modifikation von Daten wurden verschiedene Abfragen ausgewählt, welche
logisch gruppiert wurden:

1. Registrieren eines neuen Fluges:
```sql
INSERT INTO Flight (PlaneRegistration, StartParkTime, EndParkTime, PlaneType, AirlineCallsign, ParkingPositionLabel)
VALUES (
        'LX-8IRM', -- Kennzeichen des Flugzeugs
        '2021-05-31 19:00:00', -- Datum und Zeit ab dem die Parkzeit des Fluges startet
        '2021-05-31 21:45:00', -- Datum und Zeit ab dem die Parkzeit des Fluges endet
        27, -- Typ des Flugzeugs, in diesem Fall ein Airbus A340-500
        'LUXAIR', -- Rufzeichen der Airline, in diesem Fall von Luxair
        '184' -- Die Position, an der das Flugzeug steht, in diesem Fall 184
);
```

Eingefügt wird das Flugzeug mit der Bezeichnung `LX-8IRM`, welches eine zugewiesene Parkzeit
am 31.05.2021 von 19:00 Uhr bis 21:45 Uhr hat. Der Typ des Flugzeugs (`27`) verweist auf die
`PlaneType` Tabelle und ist dort als `Airbus A340-500` gelistet. Als Letztes folgen zu eindeutigen
Identifikation der Fluglinie deren Rufzeichen (`LUXAIR`), welches auf die `Airline` Tabelle verweist
und dort die Fluglinie `Luxair` auflistet.

2. Ändern der Parkposition und des Flugzeugtyps eines Fluges
```sql
-- Ändern der Parkposition und Flugzeugtyps für den Flug mit der Nummer 4
UPDATE Flight SET ParkingPositionLabel = '182', PlaneType = 97 WHERE FlightNumber = 4;
```

Hier wird für den Flug mit der Nummer 4 die Parkposition auf `182` geändert, welche den Flugzeugtyp `97` 
erlaubt, welcher in der `PlaneType` Tabelle als `Boeing 777-300ER` gelistet ist.

3. Änderungen an Slots
```sql
UPDATE Slot SET AirlineCallsign = NULL WHERE ID = 918; -- Markiert den Slot mit der ID 918 als Frei
UPDATE Slot SET AirlineCallsign = 'LUFTHANSA' WHERE ID = 921; -- Weist den Slot mit der ID 921 der Lufthansa zu
UPDATE Airline SET SlotCount = 5 WHERE Callsign = 'AIR CHINA'; -- Setzt die maximal gebuchten slots von Air China
```
Diese Abfragen werden verwendet, um die von Fluggesellschaft gebuchten Slots zu verwalten. Ein Slot
mit einem Rufzeichen von `NULL` ist keiner Fluggesellschaft zugeordnet. Zusätzlich werden jeder
Fluggesellschaft eine maximale buchbare Anzahl an Slots zugeordnet, welche entsprechend geändert
werden können, je nach Kontingent des Flughafens und der Fluggesellschaft.

4. Änderungen an Mitarbeitern
```sql
DELETE FROM VehicleOperation WHERE EmployeeNumber = 10; -- Sicherstellen, dass der Mitarbeiter keine Fahrzeuge mehr bedient
DELETE FROM Service WHERE EmployeeNumber = 10; -- Sicherstellen, dass der Mitarbeiter keine Flüge mehr abfertigt
DELETE FROM AirportEmployee WHERE RegistrationNumber = 10; -- Endgültiges löschen des Mitarbeiters
```

Hier wird der Mitarbeiter mit der Nummer 10 entlassen – zuerst werden alle zugewiesenen Aufgaben gelöscht,
anschließend der Mitarbeiter selber.

5. Änderungen an Passagieren
```sql
INSERT INTO Passenger (Name, Surname, PassportID, HouseNumber, Street, Residence)
VALUES (
        'Weber', -- Name
        'Anna', -- Vorname
        733432, -- Pass Identifikationsnummer
        171, -- Haus Nummer
        'Kegelstraße', -- Straßenname
        4425 -- Ort, in diesem Fall Ulm
);
```
Für die Registrierung eines neuen Passagiers werden der volle Name sowie der Wohnort benötigt.
Die letzte Zahl, die den Ort beschreibt, verweist auf die `Location` Tabelle, welche eine Liste von
bekannten Orten weltweit enthält.

```sql
UPDATE Passenger SET Surname = 'Castle' WHERE ID = 1999;
```
Sollte sich der Nachname eines Passagiers ändern, kann er mithilfe dieser Abfrage geändert werden.
Beispielhaft wird der Nachname des Passagiers mit der Nummer `1999` auf `Castle` geändert.

## Anmerkungen
Zum Verständnis der vorliegenden Daten sollten folgende Dinge beachtet werden:

- Ein Flug beschreibt jeweils Ankunft und Abflug, somit ist es möglich, dass Passagiere mit demselben Flug
  ankommen und abfliegen
- Die `Slots` Tabelle beschreibt gleichzeitig Kapazitäten des Flughafens in Form aller Slots, sowie
  welche Slots welcher Fluggesellschaft gehören. Dies ist nicht zu verwechseln mit dem `SlotCount`,
  welcher jeder Fluggesellschaft zugeordnet wird. Dieser beschreibt, wie viele Slots eine Gesellschaft
  **maximal** buchen kann. Der `SlotCount` kann somit von der zugewiesenen Anzahl der Slots abweichen.
  
## Weitere Dokumentation
Eine Beschreibung der Projektstruktur, Programmierung und Lizenzierung kann im Markdown Dokument
`OVERVIEW_de.md` gefunden werden, welches online (mit dem Rest der Ordnerstruktur) unter 
https://github.com/Janrupf/airport-db-seeding/blob/main/OVERVIEW_de.md verfügbar ist.
