local api = better_day_night_cycle
local cycle = api.cycle

-- Public API for other mods.

api.get_phase = cycle.get_phase

api.get_timeofday = cycle.get_timeofday

api.set_timeofday = cycle.set_timeofday

api.set_durations = cycle.set_durations

api.is_running = cycle.is_running