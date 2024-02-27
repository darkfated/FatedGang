concommand.Add('fatedgang_command_leave', function(pl)
    local pl_gang = pl:GangId()

    if !pl_gang then
        return
    end

    local querySelect = string.format("SELECT players FROM fatedgang WHERE id = '%s'", pl_gang)
    local resultSelect = sql.Query(querySelect)

    if resultSelect then
        local players_table = util.JSONToTable(resultSelect[1].players)

        if pl:SteamID() == pl_gang then
            for pl_steamid, pl_data in pairs(players_table) do
                local pl_game = player.GetBySteamID(pl_steamid)

                if pl_game then
                    pl_game:SetGangId(false)
                end
            end

            players_table = {}
        else
            for pl_steamid, pl_data in pairs(players_table) do
                if pl_steamid == pl:SteamID() then
                    pl:SetGangId(false)
                    
                    players_table[pl_steamid] = nil
    
                    break
                end
            end
        end

        if !table.IsEmpty(players_table) then
            local queryUpdate = string.format("UPDATE fatedgang SET players = '%s' WHERE id = '%s'", util.TableToJSON(players_table), pl_gang)
            sql.Query(queryUpdate)

            net.Start('FatedGang-ClientPlayerRemove')
                net.WriteString(pl_gang)
                net.WriteTable(players_table)
            net.Broadcast()
        else
            sql.Query("DELETE FROM fatedgang WHERE id = '" .. pl_gang .. "'")

            net.Start('FatedGang-ClientRemove')
                net.WriteString(pl_gang)
            net.Broadcast()
        end
    end
end)

concommand.Add('fatedgang_command_add_rank', function(pl, _, args)
    local id = args[1]
    local rank_name = args[2]

    if !id or !rank_name then
        return
    end

    local pl_gang = pl:GangId()

    if !pl_gang then
        return
    end

    if !pl:IsSuperAdmin() and pl:SteamID() != id then
        Mantle.notify(pl, Color(102, 49, 138), 'Банды', 'У вас нету прав на совершение этого действия.')

        return
    end

    local querySelect = string.format("SELECT * FROM fatedgang WHERE id = '%s'", id)
    local resultSelect = sql.Query(querySelect)

    if resultSelect then
        local gang_table = resultSelect[1]
        local info_table = util.JSONToTable(gang_table.info)

        table.insert(info_table.ranks, {
            name = rank_name,
            col = Color(46, 66, 103),
            access = {
                invite = false
            }
        })

        info_table = util.TableToJSON(info_table)

        local queryUpdate = string.format("UPDATE fatedgang SET info = '%s' WHERE id = '%s'", info_table, id)
        sql.Query(queryUpdate)

        gang_table.info = info_table

        net.Start('FatedGang-ToClient')
            net.WriteString(pl_gang)
            net.WriteTable(gang_table)
        net.Broadcast()
    end
end)

concommand.Add('fatedgang_command_rename_rank', function(pl, _, args)
    local id = args[1]
    local k = tonumber(args[2])
    local rank_name = args[3]

    if !id or !k or !rank_name then
        return
    end

    local pl_gang = pl:GangId()

    if !pl_gang then
        return
    end

    if !pl:IsSuperAdmin() and pl:SteamID() != id then
        Mantle.notify(pl, Color(102, 49, 138), 'Банды', 'У вас нету прав на совершение этого действия.')

        return
    end

    local querySelect = string.format("SELECT * FROM fatedgang WHERE id = '%s'", id)
    local resultSelect = sql.Query(querySelect)

    if resultSelect then
        local gang_table = resultSelect[1]
        local info_table = util.JSONToTable(gang_table.info)
        info_table.ranks[k].name = rank_name
        info_table = util.TableToJSON(info_table)

        local queryUpdate = string.format("UPDATE fatedgang SET info = '%s' WHERE id = '%s'", info_table, id)
        sql.Query(queryUpdate)

        gang_table.info = info_table

        net.Start('FatedGang-ToClient')
            net.WriteString(pl_gang)
            net.WriteTable(gang_table)
        net.Broadcast()
    end
end)

concommand.Add('fatedgang_command_remove_rank', function(pl, _, args)
    local id = args[1]
    local k = tonumber(args[2])

    if !id or !k then
        return
    end

    local pl_gang = pl:GangId()

    if !pl_gang then
        return
    end

    if !pl:IsSuperAdmin() and pl:SteamID() != id then
        Mantle.notify(pl, Color(102, 49, 138), 'Банды', 'У вас нету прав на совершение этого действия.')

        return
    end

    if k == 1 then
        return
    end

    local querySelect = string.format("SELECT * FROM fatedgang WHERE id = '%s'", id)
    local resultSelect = sql.Query(querySelect)

    if resultSelect then
        local gang_table = resultSelect[1]
        local info_table = util.JSONToTable(gang_table.info)
        table.remove(info_table.ranks, k)
        info_table = util.TableToJSON(info_table)

        local queryUpdate = string.format("UPDATE fatedgang SET info = '%s' WHERE id = '%s'", info_table, id)
        sql.Query(queryUpdate)

        gang_table.info = info_table

        net.Start('FatedGang-ToClient')
            net.WriteString(pl_gang)
            net.WriteTable(gang_table)
        net.Broadcast()
    end
end)

concommand.Add('fatedgang_command_set_rank', function(pl, _, args)
    local id = args[1]
    local steamid = args[2]
    local k = tonumber(args[3])

    if !id or !steamid or !k then
        return
    end

    local pl_gang = pl:GangId()

    if !pl_gang then
        return
    end

    if !pl:IsSuperAdmin() and pl:SteamID() != id then
        Mantle.notify(pl, Color(102, 49, 138), 'Банды', 'У вас нету прав на совершение этого действия.')
        
        return
    end

    local querySelect = string.format("SELECT * FROM fatedgang WHERE id = '%s'", id)
    local resultSelect = sql.Query(querySelect)

    if resultSelect then
        local gang_table = resultSelect[1]
        local players_table = util.JSONToTable(gang_table.players)
        players_table[steamid].rank = k
        players_table = util.TableToJSON(players_table)

        local queryUpdate = string.format("UPDATE fatedgang SET players = '%s' WHERE id = '%s'", players_table, id)
        sql.Query(queryUpdate)

        gang_table.players = players_table

        net.Start('FatedGang-ToClient')
            net.WriteString(pl_gang)
            net.WriteTable(gang_table)
        net.Broadcast()
    end
end)

concommand.Add('fatedgang_command_kick', function(pl, _, args)
    local id = args[1]
    local steamid = args[2]

    if !id or !steamid then
        return
    end

    local pl_gang = pl:GangId()

    if !pl_gang then
        return
    end

    if !pl:IsSuperAdmin() and pl:SteamID() != id then
        Mantle.notify(pl, Color(102, 49, 138), 'Банды', 'У вас нету прав на совершение этого действия.')

        return
    end

    if pl:SteamID() == steamid then
        Mantle.notify(pl, Color(102, 49, 138), 'Банды', 'Нельзя кикнуть самого себя!')
        Mantle.notify(pl, Color(102, 49, 138), 'Банды', 'Если желаешь удалить банду - покинь её')

        return
    end

    local querySelect = string.format("SELECT * FROM fatedgang WHERE id = '%s'", id)
    local resultSelect = sql.Query(querySelect)

    if resultSelect then
        local gang_table = resultSelect[1]
        local players_table = util.JSONToTable(gang_table.players)
        players_table[steamid] = nil
        players_table = util.TableToJSON(players_table)

        local queryUpdate = string.format("UPDATE fatedgang SET players = '%s' WHERE id = '%s'", players_table, id)
        sql.Query(queryUpdate)

        gang_table.players = players_table

        local kick_pl = player.GetBySteamID(steamid)

        if kick_pl then
            kick_pl:SetGangId(false)
            kick_pl:SendLua('if IsValid(FatedGang.menu) then FatedGang.menu:Remove() end')
        end

        net.Start('FatedGang-ToClient')
            net.WriteString(pl_gang)
            net.WriteTable(gang_table)
        net.Broadcast()
    end
end)

concommand.Add('fatedgang_command_img', function(pl, _, args)
    local id = args[1]
    local img = args[2]

    if !id or !img then
        return
    end

    local pl_gang = pl:GangId()

    if !pl_gang then
        return
    end

    if !pl:IsSuperAdmin() and pl:SteamID() != id then
        Mantle.notify(pl, Color(102, 49, 138), 'Банды', 'У вас нету прав на совершение этого действия.')

        return
    end

    local querySelect = string.format("SELECT * FROM fatedgang WHERE id = '%s'", id)
    local resultSelect = sql.Query(querySelect)

    if resultSelect then
        local gang_table = resultSelect[1]
        local info_table = util.JSONToTable(gang_table.info)
        info_table.img = img
        info_table = util.TableToJSON(info_table)

        local queryUpdate = string.format("UPDATE fatedgang SET info = '%s' WHERE id = '%s'", info_table, id)
        sql.Query(queryUpdate)

        gang_table.info = info_table

        net.Start('FatedGang-ToClient')
            net.WriteString(pl_gang)
            net.WriteTable(gang_table)
        net.Broadcast()
    end
end)

concommand.Add('fatedgang_command_invite', function(pl, _, args)
    local steamid = args[1]

    if !steamid then
        return
    end

    local pl_gang = pl:GangId()

    if !pl_gang then
        return
    end

    if !pl:IsSuperAdmin() and pl:SteamID() != pl_gang then
        Mantle.notify(pl, Color(102, 49, 138), 'Банды', 'Приглашает в банду только босс.')

        return
    end

    local target = player.GetBySteamID(steamid)

    if target then
        Mantle.notify(pl, Color(102, 49, 138), 'Банды', 'Вы пригласили ' .. target:Name())

        net.Start('FatedGang-SendInvite')
            net.WriteString(pl_gang)
        net.Send(target)
    end
end)

concommand.Add('fatedgang_command_delete', function(pl, _, args)
    local id = args[1]

    if !id then
        return
    end

    if !pl:IsSuperAdmin() and pl:SteamID() != id then
        Mantle.notify(pl, Color(102, 49, 138), 'Банды', 'Удалить банду может только босс.')

        return
    end

    local querySelect = string.format("SELECT * FROM fatedgang WHERE id = '%s'", id)
    local resultSelect = sql.Query(querySelect)

    if resultSelect then
        sql.Query("DELETE FROM fatedgang WHERE id = '" .. id .. "'")

        net.Start('FatedGang-ClientRemove')
            net.WriteString(id)
        net.Broadcast()
    end
end)
