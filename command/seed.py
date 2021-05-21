import string

from data.gatesdb import GatesDB
from data.namedb import NameDB
from data.streetnamesdb import StreetNamesDB
from data.citiesdb import CitiesDB
from data.planedb import PlaneDB

from pathlib import Path

import random

PASSPORT_MIN = 100000
PASSPORT_MAX = 1000000

ZIP_CODE_MIN = 10000
ZIP_CODE_MAX = 90000

HOUSE_NUMBER_MIN = 1
HOUSE_NUMBER_MAX = 300

PASSENGER_COUNT = 2000
APRON_VEHICLE_COUNT = 100

INSERT_COUNTRY_STATEMENT = """INSERT INTO Country (Name) VALUES (%s)"""
INSERT_LOCATION_STATEMENT = """INSERT INTO Location (Zip, Name, Country) VALUES (%s, %s, %s)"""
INSERT_PASSENGER_STATEMENT = """INSERT INTO Passenger (Name, Surname, PassportID, HouseNumber, Street, Residence) VALUES (%s, %s, %s, %s, %s, %s)"""
INSERT_AIRPORT_EMPLOYEE_STATEMENT = """INSERT INTO AirportEmployee(Name, Surname, Job, HouseNumber, Street, Residence) VALUES (%s, %s, %s, %s, %s, %s)"""
INSERT_GATE_STATEMENT = """INSERT INTO ParkingPosition (Label, GeographicPosition, TerminalID) VALUES (%s, POINT(%s,%s), %s)"""
INSERT_APRON_VEHICLE_STATEMENT = """INSERT INTO ApronVehicle(LicensePlate, Status, Job) VALUES (%s, %s, %s)"""
INSERT_PLANE_TYPE_STATEMENT = """INSERT INTO PlaneType(Name) VALUES (%s)"""


def seed_country(all_countries, cursor, out):
    out["country"] = list()
    for country in all_countries:
        out["country"].append(cursor.mogrify(INSERT_COUNTRY_STATEMENT, (country,)))


def seed_location(data, all_countries, cursor, out):
    cities_db = data.cache.get_cached_instance(CitiesDB)

    out["location"] = list()

    for city in cities_db.get_cities():
        country_id = all_countries.index(city.country) + 1
        out["location"].append(cursor.mogrify(INSERT_LOCATION_STATEMENT,
                                              (random.randint(ZIP_CODE_MIN, ZIP_CODE_MAX), city.name, country_id)))

    return len(out["location"])


def seed_passenger(location_count, data, cursor, out):
    street_name_db = data.cache.get_cached_instance(StreetNamesDB)
    name_db = data.cache.get_cached_instance(NameDB)
    names = list(name_db.get_names().items())

    out["passenger"] = list()

    for i in range(PASSENGER_COUNT):
        first_name, surname = random.choice(names)
        street_name = random.choice(street_name_db.get_street_names())
        location = random.randint(1, location_count)

        out["passenger"].append(cursor.mogrify(INSERT_PASSENGER_STATEMENT, (
            first_name, surname, random.randint(PASSPORT_MIN, PASSPORT_MAX),
            random.randint(HOUSE_NUMBER_MIN, HOUSE_NUMBER_MAX), street_name, location)))


def seed_employees(location_count, data, cursor, out):
    street_name_db = data.cache.get_cached_instance(StreetNamesDB)
    name_db = data.cache.get_cached_instance(NameDB)
    names = list(name_db.get_names().items())

    out["airportEmployee"] = list()

    # 'load master', 'air traffic controller', 'cleaning power', 'paramedic', 'firefighter', 'apron driver', 'construction worker', 'bus driver'

    jobs = dict()
    jobs["load master"] = 100
    jobs["air traffic controller"] = 32
    jobs["cleaning power"] = 200
    jobs["paramedic"] = 20
    jobs["firefighter"] = 100
    jobs["apron driver"] = 200
    jobs["construction worker"] = 30
    jobs["bus driver"] = 80

    for job, count in jobs.items():
        for i in range(count):
            first_name, surname = random.choice(names)
            street_name = random.choice(street_name_db.get_street_names())
            location = random.randint(1, location_count)

            out["airportEmployee"].append(cursor.mogrify(INSERT_AIRPORT_EMPLOYEE_STATEMENT, (
                first_name, surname, job, random.randint(HOUSE_NUMBER_MIN, HOUSE_NUMBER_MAX), street_name, location)))


def seed_gates(data, cursor, out):
    gates_db = data.cache.get_cached_instance(GatesDB)

    out["parkingPosition"] = list()

    for gate in gates_db.get_gates():
        out["parkingPosition"].append(cursor.mogrify(INSERT_GATE_STATEMENT,
                                                     (gate.label, gate.geoX, gate.geoY, int(gate.terminal))))


def seed_apron_vehicles(data, cursor, out):
    # ('tanker', 'apron stairs', 'luggage cart', 'pushback', 'follow me', 'luggage loader', 'cleaning vehicle', 'toilet vehicle', 'construction vehicle', 'passenger bus', 'crew bus', 'emergency vehicle', 'fire truck')
    jobs = dict()

    jobs["tanker"] = 20
    jobs["apron stairs"] = 20
    jobs["luggage cart"] = 100
    jobs["pushback"] = 70
    jobs["follow me"] = 10
    jobs["luggage loader"] = 150
    jobs["cleaning vehicle"] = 50
    jobs["toilet vehicle"] = 100
    jobs["construction vehicle"] = 15
    jobs["passenger bus"] = 30
    jobs["crew bus"] = 10
    jobs["emergency vehicle"] = 6
    jobs["fire truck"] = 20

    out["apronVehicle"] = list()

    def gen_license_plate():
        return ''.join(random.choice(string.ascii_uppercase + string.ascii_lowercase + string.digits) for _ in range(8))

    for job, count in jobs.items():
        busy_count = random.randint(1, min(count - 4, 20))

        for i in range(busy_count):
            out["apronVehicle"].append(
                cursor.mogrify(INSERT_APRON_VEHICLE_STATEMENT, (gen_license_plate(), "Moving", job)))

        for i in range(count - busy_count):
            out["apronVehicle"].append(
                cursor.mogrify(INSERT_APRON_VEHICLE_STATEMENT, (gen_license_plate(), "Parking", job)))


def seed_planes(data, cursor, out):
    plane_db = data.cache.get_cached_instance(PlaneDB)

    out["planeType"] = list()

    for plane in plane_db.get_planes():
        out["planeType"].append(cursor.mogrify(INSERT_PLANE_TYPE_STATEMENT, (plane,)))


def run(data):
    out = dict()

    cities_db = data.cache.get_cached_instance(CitiesDB)

    found_countries = {}
    all_countries = [found_countries.setdefault(country, country) for country in
                     [city.country for city in cities_db.get_cities()] if country not in found_countries]

    with data.database.cursor() as database_cursor:
        seed_country(all_countries, database_cursor, out)
        location_count = seed_location(data, all_countries, database_cursor, out)
        seed_passenger(location_count, data, database_cursor, out)
        seed_employees(location_count, data, database_cursor, out)
        seed_gates(data, database_cursor, out)
        seed_apron_vehicles(data, database_cursor, out)
        seed_planes(data, database_cursor, out)

    scripts_path = Path("scripts")
    scripts_path.mkdir(parents=True, exist_ok=True)

    for out_name, out_data in out.items():
        target_path = Path(f"{scripts_path / out_name}.sql")

        if target_path.exists():
            print(f"Not rewriting {target_path}")
            continue

        with open(target_path, "w") as f:
            for query in out_data:
                f.write(f"{query};\n")

    data.database.rollback()

    pass
