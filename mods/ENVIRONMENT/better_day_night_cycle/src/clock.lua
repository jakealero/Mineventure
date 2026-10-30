local clock = {}

function clock.get()
    local tod = minetest.get_timeofday()

    if type(tod) ~= "number" then
        return nil
    end

    return tod % 1.0
end

function clock.set(value)
    minetest.set_timeofday(value % 1.0)
end

return clock