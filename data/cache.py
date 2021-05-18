from pathlib import Path
import urllib3
import certifi


class Cache:
    def __init__(self):
        self.http = urllib3.PoolManager(
            ca_certs=certifi.where()
        )

        self.path = Path("./cache")
        self.path.mkdir(parents=True, exist_ok=True)

        self.cached_instances = dict()

    def get_cached_instance(self, cls):
        if cls in self.cached_instances:
            return self.cached_instances[cls]

        self.cached_instances[cls] = cls(self)
        return self.cached_instances[cls]

    def get_http(self):
        return self.http

    def resolve_entry(self, entry_name, resolver=None):
        full_entry_path = self.path / entry_name

        if full_entry_path.exists():
            return full_entry_path

        if resolver is None:
            return None

        resolver(self.get_http(), full_entry_path)
        return full_entry_path
