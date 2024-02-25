hook.Add('Initialize', 'FatedGang', function()
    if !sql.TableExists('fatedgang') then
        sql.Query([[
            CREATE TABLE IF NOT EXISTS fatedgang (
                id TEXT,
                info TEXT,
                players TEXT,
                score INTEGER DEFAULT '0'
            )
        ]])
    end
end)

hook.Add('PlayerInitialSpawn', 'FatedGang', function(pl)
    local query = sql.Query('SELECT * FROM fatedgang')

    if query then
        local tabl = {}

        for _, row in ipairs(query) do            
            local gang_players = util.JSONToTable(row.players)

            if gang_players[pl:SteamID()] then
                pl:SetGangId(row.id)
            end

            tabl[row.id] = row
        end

        local compressedData = util.Compress(util.TableToJSON(tabl))

        net.Start('FatedGang-ToClientAll')
            net.WriteUInt(#compressedData, 32)
            net.WriteData(compressedData, #compressedData)
        net.Send(pl)
    end
end)
