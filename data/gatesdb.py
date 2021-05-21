import csv
from types import SimpleNamespace


class GatesDB:
    def __init__(self, cache):
        gates_csv = cache.resolve_entry("gates.csv", GatesDB.download_gates)

        with open(gates_csv) as f:
            reader = csv.reader(f)
            next(reader, None)  # Skip CSV header
            self.gates = [SimpleNamespace(label=gate[0], geoX=gate[1], geoY=gate[2], terminal=gate[3]) for gate in reader]

        print(f"Gate database initialized, stored {len(self.gates)} gates")

    def get_gates(self):
        return self.gates

    @staticmethod
    def download_gates(http, path):
        print("Downloading gates list...")
        request = http.request("GET",
                               "https://jonas.cluborganizer.de/upload/gate.csv")
        print("Done!")

        with open(path, "w") as f:
            f.write(request.data.decode("utf-8"))
