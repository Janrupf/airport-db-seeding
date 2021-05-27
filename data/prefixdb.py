import csv


class PrefixDB:
    def __init__(self, cache):
        prefix = cache.resolve_entry("prefix.csv", PrefixDB.download_prefix)

        self.prefixes = dict()

        with open(prefix) as f:
            reader = csv.reader(f)

            for prefix_mapping in reader:
                self.prefixes[prefix_mapping[0]] = prefix_mapping[1]

        print(f"Prefix database initialized, stored {len(self.prefixes)} prefixes")

    def get_prefixes(self):
        return self.prefixes

    @staticmethod
    def download_prefix(http, path):
        print("Downloading prefix list...")
        request = http.request("GET", "https://jonas.cluborganizer.de/upload/main_prefix.csv")
        print("Done!")

        with open(path, "w") as f:
            f.write(request.data.decode("utf-8"))
