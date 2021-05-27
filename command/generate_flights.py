import string
from pathlib import Path
from types import SimpleNamespace
from data.time_gen import TimeGen
from data.date_gen import DateGen
from data.prefixdb import PrefixDB
import random

GET_ALL_SLOTS_STATEMENT = """SELECT * FROM Slot"""
GET_ALL_PASSENGERS_IDS_STATEMENT = """SELECT ID FROM Passenger"""
GET_AIRLINE_INFO_STATEMENT = """
SELECT Airline.Callsign, Airline.Name, C.Name AS CountryName FROM Airline JOIN Country C ON C.ID = Airline.Country
"""
GET_ALL_PARKING_POSITIONS_STATEMENT = """SELECT * FROM ParkingPosition"""
GET_ALL_PARKING_POSITIONS_WITH_PLANE_TYPES_STATEMENT = """
SELECT ParkingPositionLabel, PT.ID AS PlaneType
FROM ParkingPositionPlaneType
         JOIN ParkingPosition PP on ParkingPositionPlaneType.ParkingPositionLabel = PP.Label
         JOIN PlaneType PT on ParkingPositionPlaneType.PlaneType = PT.ID
         ORDER BY ParkingPositionLabel
"""
GET_ALL_EMPLOYEES_STATEMENT = """SELECT * FROM AirportEmployee"""
GET_ALL_APRON_VEHICLES_STATEMENT = """SELECT * FROM ApronVehicle"""

INSERT_FLIGHT_STATEMENT = """
INSERT INTO Flight 
    (PlaneRegistration, StartParkTime, EndParkTime, PlaneType, AirlineCallsign, ParkingPositionLabel)
    VALUES (%s, %s, %s, %s, %s, %s)
"""

INSERT_PASSENGER_MOVEMENT_STATEMENT = """
INSERT INTO PassengerMovement (Passenger, FlightNumber, Type) VALUES (%s, %s, %s)
"""

INSERT_SERVICE_STATEMENT = """
INSERT INTO Service (EmployeeNumber, FlightNumber) VALUES (%s, %s)
"""

INSERT_VEHICLE_OPERATION_STATEMENT = """
INSERT INTO VehicleOperation (EmployeeNumber, LicensePlate, WorkTime) VALUES (%s, %s, %s)
"""


def map_database_rows(rows, *names):
    names = list(names)
    objs = list()

    for row in rows:
        mapped = dict()

        for i in range(0, len(names)):
            mapped[names[i]] = row[i]

        objs.append(SimpleNamespace(**mapped))

    return objs


def group_by(attr, objs):
    grouped = dict()

    for obj in objs:
        attr_value = getattr(obj, attr)

        if attr_value not in grouped:
            grouped[attr_value] = list()

        grouped[attr_value].append(obj)

    return grouped


def group_flatten(key_attr, value_attr, objs):
    grouped = dict()

    for obj in objs:
        key_value = getattr(obj, key_attr)

        if key_value not in grouped:
            grouped[key_value] = list()

        grouped[key_value].append(getattr(obj, value_attr))

    return grouped


def flatten(objs):
    return [obj[0] for obj in objs]


def collected_data(data, cursor):
    cursor.execute(GET_ALL_SLOTS_STATEMENT)
    all_slots = group_by("airline_callsign", map_database_rows(cursor.fetchall(), "id", "type", "start_time", "end_time", "airline_callsign"))

    cursor.execute(GET_AIRLINE_INFO_STATEMENT)
    airlines = map_database_rows(cursor.fetchall(), "callsign", "name", "country")

    cursor.execute(GET_ALL_PARKING_POSITIONS_WITH_PLANE_TYPES_STATEMENT)
    parking_positions = group_flatten("label", "plane_type", map_database_rows(cursor.fetchall(), "label", "plane_type"))

    cursor.execute(GET_ALL_PASSENGERS_IDS_STATEMENT)
    passenger_ids = flatten(cursor.fetchall())

    cursor.execute(GET_ALL_EMPLOYEES_STATEMENT)
    employees = group_by("job", map_database_rows(cursor.fetchall(), "registration_number", "name", "surname", "job", "house_number", "street", "residence"))

    cursor.execute(GET_ALL_APRON_VEHICLES_STATEMENT)
    vehicles = group_by("job", map_database_rows(cursor.fetchall(), "license_plate", "status", "job"))

    return SimpleNamespace(slots=all_slots, airlines=airlines, parking_positions=parking_positions, passenger_ids=passenger_ids, employees=employees, vehicles=vehicles)


def generate_plane_registration(prefix):
    suffix = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(4))

    return f"{prefix}-{suffix}"


def seed_flights(data, out, collected, cursor):
    time_gen = TimeGen(1, 5)
    date_gen = DateGen(2021, 5)

    parking_positions = list(collected.parking_positions.items())
    prefix_db = data.cache.get_cached_instance(PrefixDB)
    prefixes = prefix_db.get_prefixes()

    out["flight"] = list()

    for i in range(0, 10):
        airline = random.choice(collected.airlines)
        position, plane_types = random.choice(parking_positions)
        plane_type = random.choice(plane_types)

        registration = generate_plane_registration(prefixes[airline.country])

        start_park_time = next(time_gen)[0]
        end_park_time = next(time_gen)[1]

        start_date, end_date = next(date_gen)

        full_start_time = f"{start_date.to_string()} {start_park_time.to_string()}"
        full_end_time = f"{end_date.to_string()} {end_park_time.to_string()}"

        out["flight"].append(cursor.mogrify(INSERT_FLIGHT_STATEMENT, (registration, full_start_time, full_end_time, plane_type, airline.callsign, position)))

    return 10


def seed_passenger_movement(flight_count, out, collected, cursor):
    out["passengerMovement"] = list()

    for i in range(1, flight_count + 1):
        passenger_arrival_count = random.randint(40, 200)
        passenger_departure_count = random.randint(40, 200)

        arrival_ids = set([random.choice(collected.passenger_ids) for _ in range(0, passenger_arrival_count)])
        departure_ids = set([random.choice(collected.passenger_ids) for _ in range(0, passenger_departure_count)])

        duplicates = list()

        for departure_id in departure_ids:
            if departure_id in arrival_ids:
                duplicates.append(departure_id)

        for departure_id in duplicates:
            departure_ids.remove(departure_id)

        for arrival in arrival_ids:
            out["passengerMovement"].append(cursor.mogrify(INSERT_PASSENGER_MOVEMENT_STATEMENT, (arrival, i, "Arrival")))

        for departure in departure_ids:
            out["passengerMovement"].append(cursor.mogrify(INSERT_PASSENGER_MOVEMENT_STATEMENT, (departure, i, "Departure")))

    random.shuffle(out["passengerMovement"])


def seed_service(flight_count, out, collected, cursor):
    required_people = {
        "apron driver": (1, 1),
        "load master": (1, 2),
        "cleaning power": (5, 10)
    }

    out["service"] = list()

    assigned_people = list()
    for i in range(1, flight_count + 1):
        for job, (min_count, max_count) in required_people.items():
            count = random.randint(min_count, max_count)

            for _ in range(count):
                while True:
                    employee = random.choice(collected.employees[job])
                    if employee not in assigned_people:
                        assigned_people.append(employee)
                        break

                out["service"].append(cursor.mogrify(INSERT_SERVICE_STATEMENT, (employee.registration_number, i)))


def seed_vehicle_operation(out, collected, cursor):
    job_mapping = {
        "tanker": "apron driver",
        "apron stairs": "apron driver",
        "luggage cart": "apron driver",
        "pushback": "apron driver",
        "follow me": "apron driver",
        "luggage loader": "apron driver",
        "cleaning vehicle": "cleaning power",
        "toilet vehicle": "cleaning power",
        "construction vehicle": "construction worker",
        "passenger bus": "bus driver",
        "crew bus": "bus driver",
        "emergency vehicle": "paramedic",
        "fire truck": "firefighter"
    }

    available_employees = collected.employees.copy()

    out["vehicleOperation"] = list()

    for vehicle_job, vehicles in collected.vehicles.items():
        for vehicle in vehicles:
            if vehicle.status != "Moving":
                continue

            employees_for_vehicle = available_employees[job_mapping[vehicle_job]]
            target_employee = random.choice(employees_for_vehicle)
            employees_for_vehicle.remove(target_employee)

            work_time = random.randint(1, 3)

            out["vehicleOperation"].append(cursor.mogrify(INSERT_VEHICLE_OPERATION_STATEMENT, (target_employee.registration_number, vehicle.license_plate, work_time)))


def run(data):
    out = dict()

    with data.database.cursor() as database_cursor:
        collected = collected_data(data, database_cursor)
        flight_count = seed_flights(data, out, collected, database_cursor)
        seed_passenger_movement(flight_count, out, collected, database_cursor)
        seed_service(flight_count, out, collected, database_cursor)
        seed_vehicle_operation(out, collected, database_cursor)
        pass

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
