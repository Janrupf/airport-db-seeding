import argparse
import os
import certifi

import dotenv
import pymysql
from types import SimpleNamespace

import command.seed
from data.cache import Cache

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Airport database controller script")

    subparsers = parser.add_subparsers(dest="subparsers", description="Seed the database")
    seed_parser = subparsers.add_parser("seed")

    args = parser.parse_args()

    dotenv.load_dotenv()

    database = pymysql.connect(
        host=os.environ["DATABASE_HOST"],
        port=int(os.environ["DATABASE_PORT"]),
        user=os.environ["DATABASE_USER"],
        password=os.environ["DATABASE_PASSWORD"],
        database=os.environ["DATABASE_DATABASE"],
        ssl_verify_identity=False
    )

    cache = Cache()

    command_data = SimpleNamespace(
        cache=cache,
        args=args,
        database=database
    )

    if args.subparsers == "seed":
        command.seed.run(command_data)
    else:
        raise RuntimeError("No subcommand supplied")
