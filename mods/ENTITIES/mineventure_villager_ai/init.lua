local path = core.get_modpath(core.get_current_modname())

local files = {
    "armorer.lua",
}
for _, file in pairs (files) do
	dofile (path .. "/" .. file)
end