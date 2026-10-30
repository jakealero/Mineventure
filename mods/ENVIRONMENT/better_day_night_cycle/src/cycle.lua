local config = better_day_night_cycle.config
local clock = better_day_night_cycle.clock

local cycle = {
    running = false,
    initialized = false,
    tod = nil,
}

local function advance(tod, elapsed)

    local day_width =
        config.night_start - config.day_start

    local night_width = 1.0 - day_width

    local cycle_duration =
        config.day_duration + config.night_duration

    elapsed = elapsed % cycle_duration

    while elapsed > 0 do

        local is_day =
            tod >= config.day_start
            and tod < config.night_start

        local boundary
        local rate

        if is_day then

            boundary = config.night_start

            rate = day_width /
                config.day_duration

        else

            boundary = config.day_start

            if tod >= config.night_start then
                boundary = config.day_start + 1.0
            end

            rate = night_width /
                config.night_duration
        end

        local distance = boundary - tod

        if distance < 0 then
            distance = distance + 1.0
        end

        local seconds_to_boundary =
            distance / rate

        if elapsed < seconds_to_boundary then

            tod = (tod + elapsed * rate) % 1.0
            elapsed = 0

        else

            tod = boundary % 1.0

            elapsed = elapsed -
                seconds_to_boundary
        end
    end

    return tod
end


function cycle.start()

    if cycle.running then
        return
    end

    cycle.running = true
    cycle.initialized = false

    -- Initialize on the first globalstep.
    -- Avoid reading time during mod initialization.

    minetest.register_globalstep(function(dtime)

        if not cycle.running then
            return
        end

        if not cycle.initialized then

            local initial_tod = clock.get()

            if initial_tod == nil then

                initial_tod = 0.5

                minetest.log("warning",
                    "[better_day_night_cycle] get_timeofday() returned nil; starting at midday")
            end

            cycle.tod = initial_tod
            cycle.initialized = true

            return
        end

        cycle.tod = advance(
            cycle.tod,
            math.max(0, dtime)
        )

        clock.set(cycle.tod)

    end)
end


function cycle.stop()
    cycle.running = false
end


function cycle.is_running()
    return cycle.running
end


function cycle.get_phase()

    if not cycle.initialized or not cycle.tod then
        return nil
    end

    if cycle.tod >= config.day_start
        and cycle.tod < config.night_start then

        return "day"
    end

    return "night"
end


function cycle.get_timeofday()

    if not cycle.initialized then
        return clock.get()
    end

    return cycle.tod
end


function cycle.set_timeofday(value)

    assert(type(value) == "number",
        "time-of-day must be a number")

    cycle.tod = value % 1.0
    cycle.initialized = true

    clock.set(cycle.tod)
end


function cycle.set_durations(day_seconds, night_seconds)

    assert(type(day_seconds) == "number"
        and day_seconds > 0,
        "day duration must be a positive number")

    assert(type(night_seconds) == "number"
        and night_seconds > 0,
        "night duration must be a positive number")

    config.day_duration = day_seconds
    config.night_duration = night_seconds
end


return cycle