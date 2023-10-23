concommand.Add('fated_gang_command_leave', function(pl)
    if pl:GetGangId() != '0' then
        if pl:IsGangBoss() then
            for steamid64, _ in pairs(pl:GetGangTable().players) do
                local pl = player.GetBySteamID64(steamid64)

                if IsValid(pl) then
                    pl:SetGangId('0')
                end
            end

            FatedGang.data[pl:SteamID64()] = nil
        else
            for gang_pl_steamid, _ in pairs(pl:GetGangTable().players) do
                local gang_pl = player.GetBySteamID64(gang_pl_steamid)
    
                FatedGang.notify(gang_pl, string.format('%s вышел из банды.', pl:Name()))
            end

            pl:GetGangTable().players[pl:SteamID64()] = nil
            pl:SetGangId('0')
        end

        net.Start('FatedGang-ToClient')
            net.WriteTable(FatedGang.data)
        net.Broadcast()
    end
end)

concommand.Add('fated_gang_command_invite', function(pl, _, args)
    local gang_data = pl:GetGangTable()

    if !gang_data then
        FatedGang.notify(pl, 'У вас нету банды.')

        return
    end

    if !pl:IsGangBoss() and !pl:GetGangTableRank().access.invite then
        FatedGang.notify(pl, 'Нету доступа для приглашения.')

        return
    end

    local target_steamid = args[1]

    if !target_steamid then
        FatedGang.notify(pl, 'Укажите игрока!')

        return
    end

    local target = player.GetBySteamID64(target_steamid)
    
    if target:GetGangId() != '0' then
        FatedGang.notify(pl, string.format('%s уже состоит в банде.', target:Name()))

        return
    end

    if !FatedGang.data.invites[target:SteamID64()] then
        FatedGang.data.invites[target:SteamID64()] = {}
    end

    for i, invite_table in pairs(FatedGang.data.invites[target:SteamID64()]) do
        if invite_table.id == pl:GetGangId() then
            FatedGang.data.invites[target:SteamID64()][i] = nil
        end
    end

    table.insert(FatedGang.data.invites[target:SteamID64()], {id = pl:GetGangId(), name = gang_data.name, img = gang_data.img})

    FatedGang.notify(pl, string.format('Вы пригласили в банду: %s', target:Name()))

    net.Start('FatedGang-ToClient')
        net.WriteTable(FatedGang.data)
    net.Broadcast()
end)

concommand.Add('fated_gang_command_kick', function(pl, _, args)
    local gang_data = pl:GetGangTable()

    if !gang_data then
        FatedGang.notify(pl, 'У вас нету банды.')

        return
    end

    if !pl:IsGangBoss() and !pl:GetGangTableRank().access.kick then
        FatedGang.notify(pl, 'Нету доступа, чтобы выгнать.')

        return
    end

    local target_steamid = args[1]
    
    if !gang_data.players[target_steamid] then
        return
    end

    local target_pl = player.GetBySteamID64(target_steamid)

    if IsValid(target_pl) then
        target_pl:SetGangId('0')
    end

    FatedGang.notify(pl, 'Вы выгнали: ' .. gang_data.players[target_steamid].nick)
    
    gang_data.players[target_steamid] = nil

    net.Start('FatedGang-ToClient')
        net.WriteTable(FatedGang.data)
    net.Broadcast()
end)

concommand.Add('fated_gang_command_rank', function(pl, _, args)
    local gang_data = pl:GetGangTable()

    if !gang_data then
        FatedGang.notify(pl, 'У вас нету банды.')

        return
    end

    if !pl:IsGangBoss() and !pl:GetGangTableRank().access.rank then
        FatedGang.notify(pl, 'Нету доступа на выдачу ранга.')

        return
    end

    local target_steamid = args[1]
    
    if !gang_data.players[target_steamid] then
        FatedGang.notify(pl, 'Укажите игрока из банды!')

        return
    end

    local rank_new = args[2]

    if !gang_data.ranks[rank_new] then
        FatedGang.notify(pl, 'Такого ранга не существует!')

        return
    end

    gang_data.players[target_steamid].rank = rank_new

    for gang_pl_steamid, _ in pairs(pl:GetGangTable().players) do
        local gang_pl = player.GetBySteamID64(gang_pl_steamid)

        FatedGang.notify(gang_pl, string.format('%s назначил %s ранг: %s', pl:Name(), gang_data.players[target_steamid].nick, rank_new))
    end

    net.Start('FatedGang-ToClient')
        net.WriteTable(FatedGang.data)
    net.Broadcast()
end)

concommand.Add('fated_gang_command_boss', function(pl, _, args)
    local gang_data = pl:GetGangTable()

    if !gang_data then
        FatedGang.notify(pl, 'У вас нету банды.')

        return
    end

    if !pl:IsGangBoss() then
        FatedGang.notify(pl, 'Вы не босс.')

        return
    end

    local target_steamid = args[1]
    
    if !gang_data.players[target_steamid] then
        FatedGang.notify(pl, 'Укажите игрока из банды!')

        return
    end
    
    pl:GetGangTablePlayer().boss = false

    gang_data.players[target_steamid].boss = true

    net.Start('FatedGang-ToClient')
        net.WriteTable(FatedGang.data)
    net.Broadcast()
end)

concommand.Add('fated_gang_command_img', function(pl, _, args)
    local gang_data = pl:GetGangTable()

    if !gang_data then
        FatedGang.notify(pl, 'У вас нету банды.')

        return
    end

    if !pl:IsGangBoss() then
        FatedGang.notify(pl, 'Вы не босс.')

        return
    end

    local img_new = args[1]

    if !img_new then
        return
    end

    pl:GetGangTable().img = img_new

    net.Start('FatedGang-ToClient')
        net.WriteTable(FatedGang.data)
    net.Broadcast()
end)
