# Better Day-Night Cycle

A Luanti mod that independently controls the real-time duration of daytime and nighttime.

## Default timing

- Day: 900 seconds (15 minutes)
- Night: 600 seconds (10 minutes)
- Full cycle: 1500 seconds (25 minutes)

The default normalized time boundaries are 0.23 (day begins) and 0.73 (night begins).

## Installation

1. Place the `better_day_night_cycle` directory in your world's `worldmods` directory, or install it as a normal mod.
2. Enable the mod for the world.
3. Set `time_speed = 0` in `minetest.conf` so the engine's built-in clock does not compete with the mod.
4. Restart the world.

## Configuration

Settings are available in `settingtypes.txt`:

- `better_day_night_cycle.enabled`
- `better_day_night_cycle.day_duration` — real seconds per daytime
- `better_day_night_cycle.night_duration` — real seconds per nighttime
- `better_day_night_cycle.day_start` — normalized day-start time
- `better_day_night_cycle.night_start` — normalized night-start time

## Mod API

Other mods can use:

```lua
better_day_night_cycle.get_phase()       -- "day" or "night"
better_day_night_cycle.get_timeofday()   -- number from 0.0 to 1.0
better_day_night_cycle.set_timeofday(0.5)
better_day_night_cycle.set_durations(900, 600)
better_day_night_cycle.is_running()
```

Durations passed to `set_durations` are real-world seconds.

## Performance and scope

The mod only updates the world's time-of-day. It does not change globalstep `dtime`, entity physics, movement speed, or other simulation timing. Its own globalstep callback performs a small amount of arithmetic.

Only one mod should own time-of-day progression. Other mods that call `minetest.set_timeofday()` can conflict with this one.
