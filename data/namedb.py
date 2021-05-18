class NameDB:
    def __init__(self, cache):
        first_names = NameDB.read_names(cache.resolve_entry("first_names.txt", NameDB.download_first_names))
        second_names = NameDB.read_names(cache.resolve_entry("second_names.txt", NameDB.download_second_names))

        count = min(len(first_names), len(second_names))
        self.full_names = dict()

        for x in range(0, count):
            self.full_names[first_names[x]] = second_names[x]

        print(f"Name database initialized, stored {count} names")

    def get_names(self):
        return self.full_names

    @staticmethod
    def read_names(file):
        with open(file, "r") as f:
            return [name.strip() for name in f]

    @staticmethod
    def download_first_names(http, path):
        print("Downloading first names...")
        request = http.request("GET",
                               "https://raw.githubusercontent.com/smashew/NameDatabases/master/NamesDatabases/"
                               "first%20names/us.txt")
        print("Done!")

        with open(path, "w") as f:
            f.write(request.data.decode("utf-8"))

    @staticmethod
    def download_second_names(http, path):
        print("Downloading second names...")
        request = http.request("GET",
                               "https://raw.githubusercontent.com/smashew/NameDatabases/master/NamesDatabases"
                               "/surnames/us.txt")
        print("Done!")

        with open(path, "w") as f:
            f.write(request.data.decode("utf-8"))
