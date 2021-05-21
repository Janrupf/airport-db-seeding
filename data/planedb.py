import csv


class PlaneDB:
    def __init__(self, cache):
        planes_csv = cache.resolve_entry("planes.csv", PlaneDB.download_planes)

        with open(planes_csv) as f:
            reader = csv.reader(f, quotechar='"')
            next(reader, None)  # Skip CSV header
            self.planes = [plane[0] for plane in reader]

        print(f"Planes database initialized, stored {len(self.planes)} planes")

    def get_planes(self):
        return self.planes

    @staticmethod
    def download_planes(http, path):
        print("Downloading planes list...")
        request = http.request("GET", "https://raw.githubusercontent.com/jpatokal/openflights/master/data/planes.dat")
        print("Done!")

        with open(path, "w") as f:
            f.write(request.data.decode("utf-8"))
