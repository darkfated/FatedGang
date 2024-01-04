if SERVER then
    timer.Create('FatedGang.ArenaReset', 1, 0, function()
        local time = DaynightGlobal:GetTime()

        if string.format('%.2f', time) == '6.00' then
            FatedGang.arenas = {}
            FatedGang.CreateArenaList()

            net.Start('FatedGang-ToClientArena')
                net.WriteTable(FatedGang.arenas)
            net.Broadcast()
        end
    end)

    hook.Add('PlayerSpawn', 'FatedGang.Arena', function(pl)
        local arena_type = pl:GetGangArenaType()

        if arena_type != '0' then
            local active_arena = pl:GetGangActiveArena()

            if active_arena != '0' then
                if pl:GetGangArenaPlayerDeath() then
                    FatedGang.notify(pl, 'Вы умерли в этом раунде. Ожидайте следующего')

                    timer.Simple(0, function()
                        pl:SetPos(table.Random(FatedGang.config.arena_spawns_waiting))
                    end)

                    pl:StripWeapons()

                    return
                end

                local arena_table = FatedGang.arenas[active_arena]
                local spawn_vector

                for k, spawn in pairs(arena_table.spawns[arena_type]) do
                    if spawn[2] == pl:SteamID64() then
                        spawn_vector = spawn[1]
                    end
                end

                timer.Simple(0, function()
                    pl:StripWeapons()
                    pl:StripAmmo()
                    pl:Give(arena_table.weapon)
                    pl:GiveAmmo(1000, pl:GetActiveWeapon():GetPrimaryAmmoType(), true)
                    pl:SetPos(spawn_vector)
                    pl:SetModel(FatedGang.config.arena_models[arena_type])
                    pl:SetPlayerColor(Vector(1, 1, 1))
                end)
            end
        end
    end)

    hook.Add('PlayerDeath', 'FatedGang.Arena', function(pl, _, attacker)
        if pl:GetGangArenaType() == '0' then
            return
        end
        
        pl:SetGangArenaPlayerDeath(true)

        local active_arena = pl:GetGangActiveArenaTable()
        active_arena.alive[pl:GetGangArenaType()] = active_arena.alive[pl:GetGangArenaType()] - 1

        net.Start('FatedGang-ToClientArena')
            net.WriteTable(FatedGang.arenas)
        net.Broadcast()

        local attacker_gang = attacker:GetGangTable()
        attacker_gang.arena_kills = attacker_gang.arena_kills + 1
    end)

    hook.Add('PlayerDeath', 'FatedGang.Shop', function(pl)
        if pl:GetGangId() == '0' then
            return
        end

        pl.gang_active_item = {}
    end)

    hook.Add('canDropWeapon', 'FatedGang.DropWeapon', function(pl, wep)
        if pl.gang_weapons and pl.gang_weapons[wep:GetClass()] then
            return false
        end
    end)

    hook.Add('PlayerSpawnProp', 'FatedGang.Arena', function(pl)
        if pl:GetGangActiveArena() != '0' then
            return false
        end
    end)
else
    local scrw = ScrW()

    hook.Add('HUDPaint', 'FatedGang.Arena', function()
        local pl = LocalPlayer()

        if pl:GetGangActiveArena() == '0' then
            return
        end

        local arena_active = pl:GetGangActiveArenaTable()
        local gang_1_table = FatedGang.data[arena_active.gangs[1]]

        if !gang_1_table then
            return
        end

        local gang_2_table = FatedGang.data[arena_active.gangs[2]]

        if !gang_2_table then
            return
        end
        
        draw.RoundedBox(0, scrw * 0.5 - 100, 10, 200, 30, Mantle.color.background_alpha)
        draw.SimpleText(pl:GetGangActiveArena(), 'Fated.17', scrw * 0.5, 24, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        local time_left = math.Round(pl:GetGangActiveArenaTable().arena_time - CurTime())
        draw.SimpleText(time_left, 'Fated.15', scrw * 0.5, 44, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

        // 1 сторона
        draw.RoundedBoxEx(16, scrw * 0.5 - 144, 10, 44, 44, Mantle.color.background_alpha, true, false, true, true)
        draw.SimpleText(arena_active.wins[1], 'Fated.20', scrw * 0.5 - 96, 25, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(arena_active.alive[1], 'Fated.15', scrw * 0.5 - 96, 49, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(gang_1_table.name, 'Fated.17', scrw * 0.5 - 150, 27, gang_1_table.color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

        http.DownloadMaterial('https://i.imgur.com/' .. gang_1_table.img .. '.png', gang_1_table.img .. '.png', function(gang_icon)
            surface.SetDrawColor(color_white)
            surface.SetMaterial(gang_icon)
            surface.DrawTexturedRect(scrw * 0.5 - 136, 19, 26, 26)
        end, 0, 512, 512)

        // 2 сторона
        draw.RoundedBoxEx(16, scrw * 0.5 + 100, 10, 44, 44, Mantle.color.background_alpha, false, true, true, true)
        draw.SimpleText(arena_active.wins[2], 'Fated.20', scrw * 0.5 + 96, 25, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        draw.SimpleText(arena_active.alive[2], 'Fated.15', scrw * 0.5 + 96, 49, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        draw.SimpleText(gang_2_table.name, 'Fated.17', scrw * 0.5 + 150, 27, gang_2_table.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        http.DownloadMaterial('https://i.imgur.com/' .. gang_2_table.img .. '.png', gang_2_table.img .. '.png', function(gang_icon)
            surface.SetDrawColor(color_white)
            surface.SetMaterial(gang_icon)
            surface.DrawTexturedRect(scrw * 0.5 + 110, 19, 26, 26)
        end, 0, 512, 512)
    end)
end
