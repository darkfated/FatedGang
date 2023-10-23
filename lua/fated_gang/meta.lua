local PLAYER = FindMetaTable('Player')

function PLAYER:GetGangId()
    return self:GetNWString('fated_gang_id', '0')
end

function PLAYER:SetGangId(id)
    self:SetNWString('fated_gang_id', id)
end

function PLAYER:GetGangTable()
    return FatedGang.data[self:GetGangId()]
end

function PLAYER:GetGangTablePlayer()
    return self:GetGangTable().players[self:SteamID64()]
end

function PLAYER:IsGangBoss()
    return self:GetGangTablePlayer().boss
end

function GetGangTableRank(rank, gang_id)
    return FatedGang.data[gang_id].ranks[rank]
end

function PLAYER:GetGangTableRank()
    return GetGangTableRank(self:GetGangTablePlayer().rank, self:GetGangId())
end

function PLAYER:GetGangColor()
    return self:GetGangTable().color
end
