import functools
import random


class DateGen:
    def __init__(self, year, month):
        self.year = year
        self.month = month

    def __iter__(self):
        return self

    def __next__(self):
        start_day = random.randint(1, 27)
        end_day = start_day + random.randint(0, 3)

        return (
            SimpleDateValue(start_day, self.month, self.year),
            SimpleDateValue(end_day, self.month, self.year)
        )


@functools.total_ordering
class SimpleDateValue:
    def __init__(self, day, month, year):
        self.day = day
        self.month = month
        self.year = year

    def __gt__(self, other):
        if self.year < other.year:
            return False
        elif self.year > other.year:
            return True

        if self.month < other.month:
            return False
        elif self.month > other.month:
            return True

        if self.day < other.day:
            return False
        elif self.day > other.day:
            return True

        return False

    def __eq__(self, other):
        return self.year == other.year and self.month == other.month and self.day == other.day

    def to_string(self):
        return f"{str(self.year)}-{str(self.month).rjust(2, '0')}-{str(self.day).rjust(2, '0')}"

    def __str__(self):
        return self.to_string()
