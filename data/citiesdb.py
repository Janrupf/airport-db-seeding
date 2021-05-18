import csv
from types import SimpleNamespace


class CitiesDB:
    def __init__(self, cache):
        cities_csv = cache.resolve_entry("cities.csv", CitiesDB.download_cities)

        with open(cities_csv) as f:
            reader = csv.reader(f)
            next(reader, None)  # Skip CSV header
            self.cities = [SimpleNamespace(name=city[0], country=city[1]) for city in reader]

        print(f"City database initialized, stored {len(self.cities)} cities")

    def get_cities(self):
        return self.cities

    @staticmethod
    def download_cities(http, path):
        print("Downloading cities list...")
        request = http.request("GET",
                               "https://raw.githubusercontent.com/datasets/world-cities/master/data/world-cities.csv")
        print("Done!")

        with open(path, "w") as f:
            f.write(request.data.decode("utf-8"))
