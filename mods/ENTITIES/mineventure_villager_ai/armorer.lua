
local FOLLOW_STOP_DISTANCE = 3
local FOLLOW_RESUME_DISTANCE = 5

local FOLLOW_SPEED_BONUS = 1.0
local FOLLOW_TOLERANCE = 1.5

local function DOD_find_nearest_player(objref)
    local villager_pos = objref:get_pos()
    if not villager_pos then
        return nil, nil, math.huge
    end

    local nearest_player = nil
    local nearest_pos = nil
    local nearest_distance = math.huge

    for _, player in ipairs(core.get_connected_players()) do
        local player_pos = player:get_pos()

        if player_pos then
            local distance = vector.distance(villager_pos, player_pos)

            if distance < nearest_distance then
                nearest_player = player
                nearest_pos = player_pos
                nearest_distance = distance
            end
        end
    end

    return nearest_player, nearest_pos, nearest_distance
end

local function DOD_armorer_stop(entity)
    entity:cancel_navigation()
    entity._dod_state = "WAITING"
end

local function DOD_armorer_follow(entity, target_pos, dtime)
    if entity._dod_state ~= "FOLLOWING" then
        entity._dod_state = "FOLLOWING"

        entity:session_navigate(
            target_pos,
            FOLLOW_SPEED_BONUS,
            FOLLOW_TOLERANCE
        )

        return
    end

    local status = entity:poll_navigation_state(
        entity.object:get_pos(),
        dtime,
        nil,
        target_pos
    )

    -- Restart navigation if the previous session ended or failed.
    if status == "arrived"
    or status == "failed"
    or status == "failure" then
        entity:session_navigate(
            target_pos,
            FOLLOW_SPEED_BONUS,
            FOLLOW_TOLERANCE
        )
    end
end

DOD_register_custom_function("armorer", function(objref, dtime)
    if not objref or not objref:is_valid() then
        return
    end

    local entity = objref:get_luaentity()
    if not entity then
        return
    end

    local _, target_pos, distance = DOD_find_nearest_player(objref)

    -- No connected player.
    if not target_pos then
        if entity._dod_state == "FOLLOWING" then
            entity:cancel_navigation()
        end

        entity._dod_state = "IDLE"
        return
    end

    -- Stop following when close enough.
    if distance <= FOLLOW_STOP_DISTANCE then
        if entity._dod_state ~= "WAITING" then
            DOD_armorer_stop(entity)
        end

        return
    end

    -- Hysteresis: remain waiting until the player moves farther away.
    if entity._dod_state == "WAITING"
    and distance <= FOLLOW_RESUME_DISTANCE then
        return
    end

    -- Follow the nearest player.
    DOD_armorer_follow(entity, target_pos, dtime or 0)
end)
