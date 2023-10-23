FatedGang.data = FatedGang.data or {}

hook.Add('Initialize', 'FatedGang.RestoreData', function()
    if !file.Exists('fated_gang.json', 'DATA') then
        file.Write('fated_gang.json', '[]')
    end

    FatedGang.data = util.JSONToTable(file.Read('fated_gang.json', 'DATA'))
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
    pl:SetGangId(pl:GetPData('fated_gang_id'))

    net.Start('FatedGang-ToClient')
        net.WriteTable(FatedGang.data)
    net.Send(pl)
end)

hook.Add('PlayerDisconnected', 'FatedGang.SavePlayerData', function(pl)
    pl:SetPData('fated_gang_id', pl:GetGangId())
end)
