import argparse
import os

import dotenv
import pymysql
from types import SimpleNamespace

import command.seed
import command.generate_flights
import command.generate_queries
from data.cache import Cache

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Airport database controller script")

    subparsers = parser.add_subparsers(dest="subparsers", description="Seed the database")
    seed_parser = subparsers.add_parser("seed")
    generate_flights_parser = subparsers.add_parser("generate-flights")
    generate_queries_parser = subparsers.add_parser("generate-queries")

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
    elif args.subparsers == "generate-flights":
        command.generate_flights.run(command_data)
    elif args.subparsers == "generate-queries":
        command.generate_queries.run(command_data)
    else:
        raise RuntimeError("No subcommand supplied")
