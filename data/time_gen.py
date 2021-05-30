import functools
import random


class TimeGen:
    def __init__(self, hour_min_step, hour_max_step):
        self.hour_min_step = hour_min_step
        self.hour_max_step = hour_max_step

        self.current_start_hour = 6
        self.current_start_minute = 0

    def __iter__(self):
        return self

    def __next__(self):
        self.current_start_minute += random.randint(0, 4) * 15

        if self.current_start_minute >= 60:
            self.current_start_hour += random.randint(self.hour_min_step, self.hour_max_step)
            self.current_start_minute = 0

        if self.current_start_hour >= 22:
            self.current_start_hour = 6

        end_hour = self.current_start_hour
        end_minute = self.current_start_minute + 15

        if end_minute == 60:
            end_hour += 1
            end_minute = 0

        return (
            SimpleTimeValue(self.current_start_hour, self.current_start_minute, 0),
            SimpleTimeValue(end_hour, end_minute, 0)
        )


@functools.total_ordering
class SimpleTimeValue:
    def __init__(self, hour, minute, second):
        self.hour = hour
        self.minute = minute
        self.second = second

    def __gt__(self, other):
        if self.hour < other.hour:
            return False
        elif self.hour > other.hour:
            return True

        if self.minute < other.minute:
            return False
        elif self.minute > other.minute:
            return True

        if self.second < other.second:
            return False
        elif self.second > other.second:
            return True

        return False

    def __eq__(self, other):
        return self.hour == other.hour and self.minute == other.minute and self.second == other.second

    def to_string(self):
        return f"{str(self.hour).rjust(2, '0')}:{str(self.minute).rjust(2, '0')}:{str(self.second).rjust(2, '0')}"

    def __str__(self):
        return self.to_string()
