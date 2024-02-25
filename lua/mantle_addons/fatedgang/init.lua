--[[
    * FatedGang *
    GitHub: https://github.com/darkfated/FatedGang
    Author's discord: darkfated
]]--

local function run_scripts() 
    Mantle.run_cl('config.lua')
    Mantle.run_sv('config.lua')

    Mantle.run_cl('shared.lua')
    Mantle.run_sv('shared.lua')
    Mantle.run_cl('client.lua')
    Mantle.run_sv('server.lua')

    Mantle.run_sv('commands.lua')
    Mantle.run_cl('nets.lua')
    Mantle.run_sv('nets.lua')

    Mantle.run_cl('interface/create_menu.lua')
    Mantle.run_cl('interface/menu.lua')
    Mantle.run_cl('interface/menu_tabs/players.lua')
    Mantle.run_cl('interface/menu_tabs/gangs.lua')
    Mantle.run_cl('interface/menu_tabs/shop.lua')
    Mantle.run_cl('interface/menu_tabs/arena.lua')
    Mantle.run_cl('interface/menu_tabs/leaders.lua')
    Mantle.run_cl('interface/menu_tabs/settings.lua')
end

local function init()
    if SERVER then
        resource.AddWorkshop('3161031117')
    end

    FatedGang = FatedGang or {
        menu_tabs = {},
        gangs = {},
        config = {}
    }

    run_scripts()
end

init()
