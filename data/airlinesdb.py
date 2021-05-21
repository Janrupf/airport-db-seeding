import csv
from types import SimpleNamespace


class AirlinesDB:
    def __init__(self, cache):
        airlines_csv = cache.resolve_entry("airlines.csv", AirlinesDB.download_airlines)

        with open(airlines_csv) as f:
            reader = csv.reader(f, quotechar='"')
            self.airlines = [SimpleNamespace(name=airline[1], callsign=airline[5], country=airline[6]) for airline in reader]

        print(f"Airlines database initialized, stored {len(self.airlines)} airlines")

    def get_airlines(self):
        return self.airlines

    @staticmethod
    def download_airlines(http, path):
        print("Downloading airlines list...")
        request = http.request("GET", "https://jonas.cluborganizer.de/upload/main_airlines.csv")
        print("Done!")

        with open(path, "w") as f:
            f.write(request.data.decode("utf-8"))
