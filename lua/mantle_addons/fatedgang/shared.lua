local PLAYER = FindMetaTable('Player')

function PLAYER:GangId()
    return self:GetNWString('fatedgang_id', false)
end

function PLAYER:SetGangId(id)
    return self:SetNWString('fatedgang_id', id)
end
