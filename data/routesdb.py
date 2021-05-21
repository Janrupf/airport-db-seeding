import csv
from types import SimpleNamespace


class RoutesDB:
    def __init__(self, cache):
        routes_csv = cache.resolve_entry("routes.csv", RoutesDB.download_routes)

        with open(routes_csv) as f:
            reader = csv.reader(f, quotechar='"')
            self.routes = [SimpleNamespace(origin=route[1], destination=route[3], plane_types=route[7].split(" "), callsign=route[8]) for route in reader]

        print(f"Routes database initialized, stored {len(self.routes)} routes")

    def get_routes(self):
        return self.routes

    @staticmethod
    def download_routes(http, path):
        print("Downloading routes list...")
        request = http.request("GET", "https://jonas.cluborganizer.de/upload/main_routes.csv")
        print("Done!")

        with open(path, "w") as f:
            f.write(request.data.decode("utf-8"))
