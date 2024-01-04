--[[
    * FatedGang *
    GitHub: https://github.com/darkfated/FatedGang
    Author's discord: darkfated
]]--

local function run_scripts()
    local cl = SERVER and AddCSLuaFile or include
    local sv = SERVER and include or function() end

    sv('func.lua')
    cl('func.lua')

    cl('config_main.lua')
    sv('config_main.lua')
    cl('config_shop.lua')
    sv('config_shop.lua')

    sv('meta.lua')
    cl('meta.lua')
    
    sv('data.lua')
    sv('commands.lua')

    sv('nets.lua')
    cl('nets.lua')

    sv('hooks.lua')
    cl('hooks.lua')
    
    cl('menu.lua')
end

local function init()
    if SERVER then
        resource.AddFile('materials/fated_gang/menu/color.png')
        resource.AddFile('materials/fated_gang/menu/icon-set.png')
        resource.AddFile('materials/fated_gang/menu/pages/main.png')
        resource.AddFile('materials/fated_gang/menu/pages/gang_list.png')
        resource.AddFile('materials/fated_gang/menu/pages/arena.png')
        resource.AddFile('materials/fated_gang/menu/pages/shop.png')
        resource.AddFile('materials/fated_gang/menu/pages/top.png')
    end

    FatedGang = FatedGang or {
        config = {}
    }

    run_scripts()
end

init()