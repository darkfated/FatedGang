local PLAYER = FindMetaTable('Player')

function PLAYER:GetGangId()
    return self:GetNWString('fated_gang_id', '0')
end

function PLAYER:SetGangId(id)
    self:SetNWString('fated_gang_id', id)
end

function PLAYER:GetGangTable()
    return FatedGang.data[self:GetGangId()] or {}
end

function PLAYER:GetGangTablePlayer()
    return self:GetGangTable().players[self:SteamID()]
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

// Ганы
function PLAYER:SetGangGan(gan)
    local pl_gang = self:GetGangTable()
    pl_gang.balance = gan
end

function PLAYER:GetGangGan(count)
    return self:GetGangTable().balance
end

function PLAYER:AddGangGan(gan)
    self:SetGangGan(self:GetGangGan() + gan)
end

// Арена
function PLAYER:GetGangActiveArena()
    return self:GetNWString('fated_gang_arena', '0')
end

function PLAYER:SetGangActiveArena(id)
    self:SetNWString('fated_gang_arena', id)
end

function PLAYER:GetGangActiveArenaTable()
    return FatedGang.arenas[self:GetGangActiveArena()] or {}
end

function PLAYER:GetGangArenaType()
    return self:GetNWInt('fated_gang_arena_type', '0')
end

function PLAYER:SetGangArenaType(t)
    self:SetNWInt('fated_gang_arena_type', t)
end

function PLAYER:GetGangArenaPlayerDeath()
    return self:GetNWBool('fated_gang_arena_death', false)
end

function PLAYER:SetGangArenaPlayerDeath(bool)
    self:SetNWInt('fated_gang_arena_death', bool)
end
