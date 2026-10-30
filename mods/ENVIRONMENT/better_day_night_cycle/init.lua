local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

better_day_night_cycle = {}

better_day_night_cycle.config =
    dofile(modpath .. "/src/config.lua")

better_day_night_cycle.clock =
    dofile(modpath .. "/src/clock.lua")

better_day_night_cycle.cycle =
    dofile(modpath .. "/src/cycle.lua")

dofile(modpath .. "/src/api.lua")

if better_day_night_cycle.config.enabled then
    better_day_night_cycle.cycle.start()

    minetest.log("action",
        "[better_day_night_cycle] Custom day/night cycle enabled")
else
    minetest.log("action",
        "[better_day_night_cycle] Custom day/night cycle disabled")
end