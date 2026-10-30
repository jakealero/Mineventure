-- Structural destruction
-- Destroys nonflammable solid blocks directly adjacent to active fire.

local FIRE_NODES = {
    ["mcl_fire:fire"] = true,
    ["mcl_fire:eternal_fire"] = true,
}

local FIRE_PROCESSING = {
    --metalic ore blocks
    ["mcl_core:stone_with_iron"] = "mcl_raw_ores:raw_iron_block",
    ["mcl_core:stone_with_gold"] = "mcl_raw_ores:raw_gold_block",
    ["mcl_copper:stone_with_copper"] = "mcl_copper:block_raw",
    ["mcl_deepslate:deepslate_with_iron"] = "mcl_raw_ores:raw_iron_block",
    ["mcl_deepslate:deepslate_with_gold"] = "mcl_raw_ores:raw_gold_block",
    ["mcl_deepslate:deepslate_with_copper"] = "mcl_copper:block_raw",

    ["mcl_raw_ores:raw_iron_block"] = "mcl_core:ironblock",
    ["mcl_raw_ores:raw_gold_block"] = "mcl_core:goldblock",
    ["mcl_copper:block_raw"] = "mcl_copper:block",

    ["mcl_core:goldblock"] = "mcl_core:lava_source",
    ["mcl_core:ironblock"] = "mcl_core:lava_source",
    ["mcl_copper:block"] = "mcl_core:lava_source",

    --non metallic ore blocks
    ["mcl_core:stone_with_lapis"] = "mcl_core:lapisblock",
    ["mcl_core:stone_with_diamond"] = "mcl_core:diamondblock",
    ["mcl_core:stone_with_emerald"] = "mcl_core:emeraldblock",

    ["mcl_deepslate:stone_with_lapis"] = "mcl_core:lapisblock",
    ["mcl_deepslate:stone_with_diamond"] = "mcl_core:diamondblock",
    ["mcl_deepslate:stone_with_emerald"] = "mcl_core:emeraldblock",


    --other smeltable blocks
    ["mcl_core:clay"] = "mcl_core:brick_block",
    ["mcl_core:sand"] = "mcl_core:glass"
}


local EXCLUDED_NODES = {
    ["mcl_core:dirt_with_grass"] = true,    
    ["mcl_core:brick_block"] = true,
    ["mcl_core:glass"] = true
}

local ADJACENTS = {
    -- Horizontal sides
    {x = -1, y = 0, z =  0},
    {x =  1, y = 0, z =  0},
    {x =  0, y = 0, z = -1},
    {x =  0, y = 0, z =  1},

    -- Above
    {x = 0, y = 1, z = 0},
}

local function smelt(pos, process)
    core.set_node(pos, {name = process})    
    local sound = mcl_sounds.node_sound_metal_defaults();
    core.sound_play(sound, {
        pos = pos,
        gain = 1.0,
        max_hear_distance = 16,
    })
end

local function is_destructible(pos)
    local node = core.get_node_or_nil(pos)

    if not node then
        return false
    end

    --Process Smeltable Blocks
    local processed = FIRE_PROCESSING[node.name]

    if processed then
        smelt(pos, processed)
        return false
    end

    -- Exclude blocks.
    if EXCLUDED_NODES[node.name] then
        return false
    end

    -- Do not interact with unloaded positions.
    if not node then
        return false
    end

    -- Explicitly exclude fire.
    if FIRE_NODES[node.name] then
        return false
    end

    -- Exclude air and other nonflammable blocks handled by the base fire system.
    if node.name == "air"
        or core.get_item_group(node.name, "flammable") ~= 0 then
        return false
    end

    local def = core.registered_nodes[node.name]

    if not def then
        return false
    end

    -- Only destroy solid, non-liquid nodes.
    if not def.walkable or def.liquidtype ~= "none" then
        return false
    end

    return true
end

local function destroy_adjacent_block(fire_pos)
    local candidates = {}

    -- Collect directly adjacent eligible blocks.
    for _, offset in ipairs(ADJACENTS) do
        local pos = vector.add(fire_pos, offset)

        if is_destructible(pos) then
            candidates[#candidates + 1] = pos
        end
    end

    -- Nothing eligible to destroy.
    if #candidates == 0 then
        return
    end

    -- Destroy one randomly selected block.
    local target = candidates[math.random(#candidates)]

    core.remove_node(target)

    -- Allow falling nodes above the removed block to fall.
    core.check_for_falling(target)
end

core.register_abm({
    label = "Fire structural destruction",

    nodenames = {
        "mcl_fire:fire",
        "mcl_fire:eternal_fire",
    },

    interval = 5,
    chance = 8,
    catch_up = false,

    action = destroy_adjacent_block,
})