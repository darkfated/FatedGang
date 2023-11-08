local GANG_FILE = 'fated_gang.json'

local function ReadData()
    local data = {}

    if file.Exists(GANG_FILE, 'DATA') then
        data = util.JSONToTable(file.Read(GANG_FILE, 'DATA')) or {}
    end

    FatedGang.data = data
    FatedGang.data.invites = {}
end

local function SaveData()
    file.Write(GANG_FILE, util.TableToJSON(FatedGang.data))

    for _, pl in pairs(player.GetAll()) do
        if pl:GetGangId() != '0' then
            pl:SetPData('fated_gang_id', pl:GetGangId())
        end
    end
end

local function OnPlayerInitialSpawn(pl)
    pl:SetGangId(pl:GetPData('fated_gang_id'))

    net.Start('FatedGang-ToClient')
        net.WriteTable(FatedGang.data)
    net.Send(pl)
end

local function OnPlayerDisconnected(pl)
    pl:SetPData('fated_gang_id', pl:GetGangId())
end

hook.Add('Initialize', 'FatedGang.RestoreData', ReadData)
hook.Add('ShutDown', 'FatedGang.SaveAllData', SaveData)
hook.Add('PlayerInitialSpawn', 'FatedGang.ResetPlayerData', OnPlayerInitialSpawn)
hook.Add('PlayerDisconnected', 'FatedGang.SavePlayerData', OnPlayerDisconnected)
