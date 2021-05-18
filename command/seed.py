from data.namedb import NameDB
from data.streetnamesdb import StreetNamesDB
from data.citiesdb import CitiesDB

from pathlib import Path

import random

PASSPORT_MIN = 100000
PASSPORT_MAX = 1000000

ZIP_CODE_MIN = 10000
ZIP_CODE_MAX = 90000

HOUSE_NUMBER_MIN = 1
HOUSE_NUMBER_MAX = 300

PASSENGER_COUNT = 2000

INSERT_COUNTRY_STATEMENT = """INSERT INTO Country (Name) VALUES (%s)"""
INSERT_LOCATION_STATEMENT = """INSERT INTO Location (Zip, Name, Country) VALUES (%s, %s, %s)"""
INSERT_PASSENGER_STATEMENT = """INSERT INTO Passenger (Name, Surname, PassportID, HouseNumber, Street, Residence) VALUES (%s, %s, %s, %s, %s, %s)"""


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

    scripts_path = Path("scripts")
    scripts_path.mkdir(parents=True, exist_ok=True)

    for out_name, out_data in out.items():
        with open(f"{scripts_path / out_name}.sql", "w") as f:
            for query in out_data:
                f.write(f"{query};\n")

    data.database.rollback()

    pass
