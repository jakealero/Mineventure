local prefix = "better_day_night_cycle."

local function get_number(name, default)
    local value = minetest.settings:get(prefix .. name)
    local number = tonumber(value)

    if not number then
        return default
    end

    return number
end

local function get_bool(name, default)
    local value = minetest.settings:get_bool(prefix .. name)

    if value == nil then
        return default
    end

    return value
end

local config = {
    enabled = get_bool("enabled", true),

    day_duration = get_number("day_duration", 900),
    night_duration = get_number("night_duration", 600),

    day_start = get_number("day_start", 0.23),
    night_start = get_number("night_start", 0.73),
}

config.day_duration = math.max(1, config.day_duration)
config.night_duration = math.max(1, config.night_duration)

config.day_start = math.min(0.99,
    math.max(0, config.day_start))

config.night_start = math.min(1,
    math.max(0.01, config.night_start))

if config.day_start >= config.night_start then
    minetest.log("warning",
        "[better_day_night_cycle] Invalid day/night boundaries; using defaults")

    config.day_start = 0.23
    config.night_start = 0.73
end

return config