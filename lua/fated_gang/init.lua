--[[
	* FatedGang *
	GitHub: https://github.com/darkfated/FatedGang
	Author's discord: darkfated
]]--

local function run_scripts()
	local cl = SERVER and AddCSLuaFile or include
	local sv = SERVER and include or function() end

	sv('meta.lua')
	cl('meta.lua')
	
	sv('data.lua')
	sv('commands.lua')

	sv('nets.lua')
	cl('nets.lua')
	
	cl('menu.lua')
end

local function init()
	if SERVER then
		resource.AddWorkshop('2924839375')
		resource.AddFile('materials/fated_gang/menu/leave.png')
		resource.AddFile('materials/fated_gang/menu/member.png')
		resource.AddFile('materials/fated_gang/menu/edit.png')
		resource.AddFile('materials/fated_gang/menu/color.png')
		resource.AddFile('materials/fated_gang/menu/image-set.png')
		resource.AddFile('materials/fated_gang/menu/pages/main.png')
		resource.AddFile('materials/fated_gang/menu/pages/gang_list.png')
	end

	FatedGang = FatedGang or {}

	run_scripts()
end

init()