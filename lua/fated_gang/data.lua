FatedGang.data = FatedGang.data or {}

hook.Add('Initialize', 'FatedGang.RestoreData', function()
    if !file.Exists('fated_gang.json', 'DATA') then
        file.Write('fated_gang.json', '[]')
    end

    FatedGang.data = util.JSONToTable(file.Read('fated_gang.json', 'DATA'), true, true)
    FatedGang.data.invites = {}
end)

hook.Add('ShutDown', 'FatedGang.SaveAllData', function()
    file.Write('fated_gang.json', util.TableToJSON(FatedGang.data))

    for k, pl in pairs(player.GetAll()) do
        if pl:GetGangId() != '0' then
            pl:SetPData('fated_gang_id', pl:GetGangId())
        end
    end
end)

hook.Add('PlayerInitialSpawn', 'FatedGang.ResetPlayerData', function(pl)
    local ply_gang_id = pl:GetPData('fated_gang_id')

    if FatedGang.data[ply_gang_id] and FatedGang.data[ply_gang_id].players[pl:SteamID()] then
        pl:SetGangId(ply_gang_id)
    end

    pl:SetNWBool('fated_gang_arena_ready', true)

    FatedGang.initializationSendGangData()
    net.Send(pl)

    net.Start('FatedGang-ToClientArena')
        net.WriteTable(FatedGang.arenas)
    net.Broadcast()
end)

hook.Add('PlayerDisconnected', 'FatedGang.SavePlayerData', function(pl)
    pl:SetPData('fated_gang_id', pl:GetGangId())
end)
