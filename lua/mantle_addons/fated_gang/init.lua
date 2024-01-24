--[[
    * FatedGang *
    GitHub: https://github.com/darkfated/FatedGang
    Author's discord: darkfated
]]--

local function run_scripts()
    Mantle.run_sv('func.lua')
    Mantle.run_cl('func.lua')

    Mantle.run_cl('config_main.lua')
    Mantle.run_sv('config_main.lua')
    Mantle.run_cl('config_shop.lua')
    Mantle.run_sv('config_shop.lua')

    Mantle.run_sv('meta.lua')
    Mantle.run_cl('meta.lua')
    
    Mantle.run_sv('data.lua')
    Mantle.run_sv('commands.lua')

    Mantle.run_sv('nets.lua')
    Mantle.run_cl('nets.lua')

    Mantle.run_sv('hooks.lua')
    Mantle.run_cl('hooks.lua')
    
    Mantle.run_cl('menu.lua')
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