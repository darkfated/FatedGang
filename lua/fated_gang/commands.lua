concommand.Add('fated_gang_command_leave', function(pl)
    if pl:GetGangId() != '0' then
        if pl:IsGangBoss() then
            for steamid, _ in pairs(pl:GetGangTable().players) do
                local pl = player.GetBySteamID(steamid)

                if IsValid(pl) then
                    pl:SetGangId('0')
                end
            end

            FatedGang.data[pl:SteamID()] = nil
        else
            for gang_pl_steamid, _ in pairs(pl:GetGangTable().players) do
                local gang_pl = player.GetBySteamID(gang_pl_steamid)

                if IsValid(gang_pl) then
                    FatedGang.notify(gang_pl, string.format('%s вышел из банды.', pl:Name()))
                end
            end

            pl:GetGangTable().players[pl:SteamID()] = nil
            pl:SetGangId('0')
        end

        FatedGang.initializationSendGangData()
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

    if table.Count(gang_data.players) + 1 > FatedGang.config.max_members then
        FatedGang.notify(pl, 'Максимальное кол-во участников: ' .. FatedGang.config.max_members)

        return
    end

    local target_steamid = args[1]

    if !target_steamid then
        FatedGang.notify(pl, 'Укажите игрока!')

        return
    end

    local target = player.GetBySteamID(target_steamid)
    
    if target:GetGangId() != '0' then
        FatedGang.notify(pl, string.format('%s уже состоит в банде.', target:Name()))

        return
    end

    if !FatedGang.data.invites[target:SteamID()] then
        FatedGang.data.invites[target:SteamID()] = {}
    end

    for i, invite_table in pairs(FatedGang.data.invites[target:SteamID()]) do
        if invite_table.id == pl:GetGangId() then
            FatedGang.data.invites[target:SteamID()][i] = nil
        end
    end

    table.insert(FatedGang.data.invites[target:SteamID()], {id = pl:GetGangId(), name = gang_data.name, img = gang_data.img})

    FatedGang.notify(pl, string.format('Вы пригласили в банду: %s', target:Name()))

    FatedGang.initializationSendGangData()
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

    local target_pl = player.GetBySteamID(target_steamid)

    if IsValid(target_pl) then
        target_pl:SetGangId('0')
    end

    FatedGang.notify(pl, 'Вы выгнали: ' .. gang_data.players[target_steamid].nick)
    
    gang_data.players[target_steamid] = nil

    FatedGang.initializationSendGangData()
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
        local gang_pl = player.GetBySteamID(gang_pl_steamid)

        FatedGang.notify(gang_pl, string.format('%s назначил %s ранг: %s', pl:Name(), gang_data.players[target_steamid].nick, rank_new))
    end

    FatedGang.initializationSendGangData()
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

    FatedGang.initializationSendGangData()
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

    if !isValidImageLink('https://i.imgur.com/' .. img_new .. '.png') then
        FatedGang.notify(pl, 'Картинка неправильного формата!')

        return
    end

    pl:GetGangTable().img = img_new

    FatedGang.initializationSendGangData()
    net.Broadcast()
end)

concommand.Add('fated_gang_command_buy', function(pl, _, args)
    local gang_data = pl:GetGangTable()

    if !gang_data then
        FatedGang.notify(pl, 'У вас нету банды.')

        return
    end

    if !pl:IsGangBoss() then
        FatedGang.notify(pl, 'Вы не босс.')

        return
    end

    local item = args[1]

    if !item then
        return
    end

    if gang_data.inventory[item] then
        FatedGang.notify(pl, 'Банда уже купила этот предмет.')

        return
    end

    for _, cat_data in pairs(FatedGang.config.shop_items) do
        local item_tabl = cat_data.items[item]

        if !item_tabl then
            continue
        end

        if gang_data.balance - item_tabl.cost < 0 then
            FatedGang.notify(pl, 'Не хватает ганов для покупки.')
            
            return
        end
    
        gang_data.balance = gang_data.balance - item_tabl.cost
        gang_data.inventory[item] = true
    
        FatedGang.notify(pl, 'Ты купил ' .. item .. ' для банды!')
    
        FatedGang.initializationSendGangData()
        net.Broadcast()

        break
    end
end)

concommand.Add('fated_gang_command_use', function(pl, _, args)
    local gang_data = pl:GetGangTable()

    if !gang_data then
        FatedGang.notify(pl, 'У вас нету банды.')

        return
    end

    local item = table.concat(args, ' ')

    if !item then
        return
    end

    if !gang_data.inventory[item] then
        FatedGang.notify(pl, 'У банды нет этого предмета.')

        return
    end

    pl.gang_active_item = pl.gang_active_item or {}

    if pl.gang_active_item[item] then
        FatedGang.notify(pl, 'Этот предмет уже активен.')

        return
    end

    for _, cat_data in pairs(FatedGang.config.shop_items) do
        local item_tabl = cat_data.items[item]

        if !item_tabl then
            continue
        end

        if !pl:canAfford(item_tabl.cost_for_use) then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase('cant_afford', ''))
    
            return
        end

        pl:addMoney(-item_tabl.cost_for_use)

        if item_tabl.wep then
            pl:Give(item_tabl.wep)
            pl.gang_weapons = pl.gang_weapons or {}

            pl.gang_weapons[item_tabl.wep] = true
        else
            item_tabl.func(pl)
        end

        FatedGang.notify(pl, 'Ты применил ' .. item .. ' на себя.')

        pl.gang_active_item[item] = true

        FatedGang.initializationSendGangData()
        net.Broadcast()

        break
    end
end)

concommand.Add('fated_gang_command_arena_ready', function(pl, _, args)
    pl:SetNWBool('fated_gang_arena_ready', !pl:GetNWBool('fated_gang_arena_ready'))
end)

concommand.Add('fated_gang_admin_command_delete', function(pl, _, args)
    if !pl:IsSuperAdmin() then
        FatedGang.notify(pl, 'У тебя нету прав на это действие.')

        return
    end

    local gang_id = args[1]

    if !FatedGang.data[gang_id] then
        FatedGang.notify(pl, 'Такой банды не существует.')

        return
    end

    for steamid, _ in pairs(FatedGang.data[gang_id].players) do
        local pl = player.GetBySteamID(steamid)

        if IsValid(pl) then
            pl:SetGangId('0')
        end
    end

    FatedGang.data[gang_id] = nil

    FatedGang.initializationSendGangData()
    net.Broadcast()
end)

concommand.Add('fated_gang_admin_command_delete_img', function(pl, _, args)
    if !pl:IsSuperAdmin() then
        FatedGang.notify(pl, 'У тебя нету прав на это действие.')

        return
    end

    local gang_id = args[1]

    if !FatedGang.data[gang_id] then
        FatedGang.notify(pl, 'Такой банды не существует.')

        return
    end

    FatedGang.data[gang_id].img = "neqfF6C"

    FatedGang.initializationSendGangData()
    net.Broadcast()
end)

concommand.Add('fated_gang_admin_command_name', function(pl, _, args)
    if !pl:IsSuperAdmin() then
        FatedGang.notify(pl, 'У тебя нету прав на это действие.')

        return
    end

    local gang_id = args[1]

    if !FatedGang.data[gang_id] then
        FatedGang.notify(pl, 'Такой банды не существует.')

        return
    end

    local name = args[2]

    if !name then
        FatedGang.notify(pl, 'Укажи название банды.')

        return
    end

    FatedGang.data[gang_id].name = name

    FatedGang.initializationSendGangData()
    net.Broadcast()
end)

concommand.Add('fated_gang_admin_command_give_gan', function(pl, _, args)
    if !pl:IsSuperAdmin() then
        FatedGang.notify(pl, 'У тебя нету прав на это действие.')

        return
    end

    local gang_id = args[1]

    if !FatedGang.data[gang_id] then
        FatedGang.notify(pl, 'Такой банды не существует.')

        return
    end

    local gan = args[2]

    if !gan then
        FatedGang.notify(pl, 'Укажи количество.')

        return
    end

    local current_gang = FatedGang.data[gang_id]
    current_gang.balance = current_gang.balance + gan

    FatedGang.initializationSendGangData()
    net.Broadcast()
end)

concommand.Add('fated_gang_admin_command_reset_stat', function(pl, _, args)
    if !pl:IsSuperAdmin() then
        FatedGang.notify(pl, 'У тебя нету прав на это действие.')

        return
    end

    for _, gang in pairs(FatedGang.data) do
        gang.balance = 0
        gang.arena_kills = 0
        gang.arena_wins = 0
    end

    FatedGang.initializationSendGangData()
    net.Broadcast()
end)

concommand.Add('fated_gang_admin_command_reset_inv', function(pl, _, args)
    if !pl:IsSuperAdmin() then
        FatedGang.notify(pl, 'У тебя нету прав на это действие.')

        return
    end

    for _, gang in pairs(FatedGang.data) do
        gang.inventory = {}
    end

    FatedGang.initializationSendGangData()
    net.Broadcast()
end)
