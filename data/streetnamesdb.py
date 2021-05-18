class StreetNamesDB:
    def __init__(self, cache):
        street_names = cache.resolve_entry("street-names.txt", StreetNamesDB.download_street_names)

        with open(street_names, "r") as f:
            self.street_names = [street_name.strip() for street_name in f]

        print(f"Street name database initialized, stored {len(self.street_names)} street names")

    def get_street_names(self):
        return self.street_names

    @staticmethod
    def download_street_names(http, path):
        print("Downloading street name list...")
        request = http.request("GET",
                               "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Miscellaneous/security-question-answers/street-names.txt")
        print("Done!")

        with open(path, "w") as f:
            f.write(request.data.decode("utf-8"))
