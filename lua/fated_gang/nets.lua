if SERVER then
    util.AddNetworkString('FatedGang-ToClient')
    util.AddNetworkString('FatedGang-Msg')
    util.AddNetworkString('FatedGang-ChangeGang')
    util.AddNetworkString('FatedGang-InviteFeedback')
    util.AddNetworkString('FatedGang-SetColor')
    util.AddNetworkString('FatedGang-CreateGang')

    if FatedGang.config.arena_enabled then
        util.AddNetworkString('FatedGang-ToClientArena')
        util.AddNetworkString('FatedGang-SelectArena')
    end

    function FatedGang.notify(pl, txt)
        net.Start('FatedGang-Msg')
        net.WriteString(txt)
    
        if pl == true then
            net.Broadcast()
        else
            net.Send(pl)
        end
    end

    net.Receive('FatedGang-ChangeGang', function(_, pl)
        if !pl:IsGangBoss() then
            FatedGang.notify(pl, 'Вы не являетесь боссом банды!')

            return
        end

        local gang_name = net.ReadString()
        local gang_desc = net.ReadString()
        local gang_ranks = net.ReadTable()

        if string.len(gang_name) < 3 then
            FatedGang.notify(pl, 'Слишком маленькое название!')
    
            return
        end

        if string.len(gang_name) > 20 then
            FatedGang.notify(pl, 'Слишком длинное название!')
    
            return
        end

        local pl_gang = pl:GetGangTable()
        pl_gang.name = gang_name
        pl_gang.desc = gang_desc
        pl_gang.ranks = gang_ranks

        if !pl_gang.ranks['Участник'] then
            pl_gang.ranks['Участник'] = {
                color = Color(50, 107, 153),
                access = {
                    invite = false,
                    kick = false,
                    edit = false,
                    rank = false
                }
            }
        end

        FatedGang.initializationSendGangData()
        net.Broadcast()

        FatedGang.notify(pl, 'Новые параметры успешно применены.')

        pl:ConCommand('fated_gang_open')
    end)

    net.Receive('FatedGang-InviteFeedback', function(_, pl)
        if pl:GetGangId() != '0' then
            FatedGang.notify(pl, 'Перед принятием заявки выйдите из банды.')

            return 
        end

        local invite_id = net.ReadInt(5)
        local invite_feedback_bool = net.ReadBool()
        local gang_id = FatedGang.data.invites[pl:SteamID()][invite_id].id

        if !FatedGang.data[gang_id] then
            FatedGang.notify(pl, 'Банда не существует.')

            FatedGang.data.invites[pl:SteamID()][invite_id] = nil

            FatedGang.initializationSendGangData()
            net.Broadcast()
            
            return
        end

        if invite_feedback_bool then
            local invite_gang_table = FatedGang.data[gang_id]

            if table.Count(invite_gang_table.players) + 1 > FatedGang.config.max_members then
                FatedGang.notify(pl, 'В банде уже максимальное кол-во участников.')
        
                return
            end

            invite_gang_table.players[pl:SteamID()] = {
                nick = pl:Name(),
                steamid64 = pl:SteamID64(),
                rank = 'Участник'
            }

            pl:SetGangId(FatedGang.data.invites[pl:SteamID()][invite_id].id)

            for gang_pl_steamid, _ in pairs(pl:GetGangTable().players) do
                local gang_pl = player.GetBySteamID(gang_pl_steamid)

                if IsValid(gang_pl) then
                    FatedGang.notify(gang_pl, string.format('%s вступил в банду!', pl:Name()))
                end
            end
        end

        FatedGang.data.invites[pl:SteamID()][invite_id] = nil

        FatedGang.initializationSendGangData()
        net.Broadcast()
    end)

    net.Receive('FatedGang-SetColor', function(_, pl)
        if pl:GetGangId() == '0' then
            FatedGang.notify(pl, 'У вас нет банды.')

            return 
        end

        if !pl:IsGangBoss() then
            FatedGang.notify(pl, 'Вы не босс.')
    
            return
        end

        local color = net.ReadColor(false)
        pl:GetGangTable().color = color
        
        FatedGang.notify(pl, 'Вы сменили цвет банды.')

        FatedGang.initializationSendGangData()
        net.Broadcast()
    end)

    net.Receive('FatedGang-CreateGang', function(_, pl)
        if pl:GetGangId() != '0' then
            FatedGang.notify(pl, 'У вас уже есть банда. Сначала расформируйте её.')
    
            return
        end
    
        local gang_name = net.ReadString()
    
        if !gang_name then
            FatedGang.notify(pl, 'Введите название банды.')
    
            return
        end

        if string.len(gang_name) < 3 then
            FatedGang.notify(pl, 'Слишком маленькое название!')
    
            return
        end
    
        if string.len(gang_name) > 20 then
            FatedGang.notify(pl, 'Слишком длинное название!')
    
            return
        end
    
        local gang_desc = net.ReadString()
    
        if !gang_desc then
            FatedGang.notify(pl, 'Введите описание для банды.')
    
            return
        end

        local gang_color = net.ReadTable()
        local gang_img = net.ReadString()
        local img_custom_bool = true

        if !isValidImageLink('https://i.imgur.com/' .. gang_img .. '.png') then
            img_custom_bool = false
        end
    
        FatedGang.data[pl:SteamID()] = {
            id = pl:SteamID64(),
            steamid = pl:SteamID(),
            name = gang_name,
            desc = gang_desc,
            color = gang_color,
            balance = 0,
            inventory = {},
            img = img_custom_bool and gang_img or 'neqfF6C',
            players = {
                [pl:SteamID()] = {
                    nick = pl:Name(),
                    steamid64 = pl:SteamID64(),
                    rank = 'Участник',
                    boss = true
                }
            },
            ranks = {
                ['Участник'] = {
                    color = Color(50, 107, 153),
                    access = {
                        invite = false,
                        kick = false,
                        edit = false,
                        rank = false
                    }
                },
            },
            arena_kills = 0,
            arena_wins = 0
        }

        if !pl:canAfford(FatedGang.config.cost_create) then
            DarkRP.notify(pl, 1, 4, DarkRP.getPhrase('cant_afford', ''))
    
            return
        end

        pl:addMoney(-FatedGang.config.cost_create)
        pl:SetGangId(pl:SteamID())
        
        FatedGang.notify(pl, 'Ты купил банду за ' .. DarkRP.formatMoney(FatedGang.config.cost_create))
    
        FatedGang.initializationSendGangData()
        net.Broadcast()
    end)

    if FatedGang.config.arena_enabled then
        net.Receive('FatedGang-SelectArena', function(_, pl)
            if pl:GetGangId() == '0' then
                FatedGang.notify(pl, 'У вас нет банды.')

                return 
            end

            if !pl:IsGangBoss() then
                FatedGang.notify(pl, 'Вы не босс.')
        
                return
            end

            local arena_id = net.ReadString()
            local arena_table = FatedGang.arenas[arena_id]

            if !arena_table then
                FatedGang.notify(pl, 'Такой арены не существует!')
                
                return
            end

            local server_time = GetGlobalFloat('SRP_Time') -- Можете вырезать проверку, либо привязать своё игровое время

            if !(server_time > 0 and server_time < 6) then
                FatedGang.notify(pl, 'Не подходящее время! С 0:00 до 6:00')

                return
            end

            if arena_table.status == 3 then
                FatedGang.notify(pl, 'Эта точка уже захватывается.')
                
                return
            end

            local pl_gang_id = pl:GetGangId()

            if table.HasValue(arena_table.loser, pl_gang_id) then
                return
            end

            if arena_table.winner == pl_gang_id then
                FatedGang.notify(pl, 'Вы итак на арене, т.к. являетесь владельцем.')

                return
            end

            if pl:GetGangActiveArena() != '0' and pl:GetGangActiveArena() != arena_id then
                FatedGang.notify(pl, 'Вы уже учавствуете в захвате другой точки!')

                return
            end

            if arena_table.status == 1 and pl:GetGangActiveArena() == arena_id then
                pl:SetGangActiveArena('0')

                if arena_table.gangs[2] == pl:GetGangId() then
                    arena_table.gangs[2] = ''
                elseif arena_table.gangs[1] == pl:GetGangId() then
                    arena_table.gangs[1] = ''
                end

                arena_table.status = 0

                net.Start('FatedGang-ToClientArena')
                    net.WriteTable(FatedGang.arenas)
                net.Broadcast()

                return
            end

            pl:SetGangActiveArena(arena_id)

            local function TwoPlayerJoin(gang_id)
                arena_table.gangs[2] = gang_id
                arena_table.status = 2
                arena_table.time_start = CurTime() + FatedGang.config.arena_waiting_time

                timer.Create('FatedGang.Arena-' .. arena_table.gangs[1], 1, FatedGang.config.arena_waiting_time, function()
                    local function PlayerCheckReady(t)
                        arena_table.players[t] = {}

                        for steamid, _ in pairs(FatedGang.data[arena_table.gangs[t]].players) do
                            local gang_pl = player.GetBySteamID(steamid)
        
                            if !gang_pl then
                                return
                            end
        
                            if gang_pl:GetNWBool('fated_gang_arena_ready', false) then
                                if table.Count(arena_table.players[t]) < 4 then
                                    table.insert(arena_table.players[t], gang_pl:SteamID64())
                                end
                            end
                        end
                    end

                    PlayerCheckReady(1)
                    PlayerCheckReady(2)

                    if table.Count(arena_table.players[2]) < table.Count(arena_table.players[1]) then
                        arena_table.winner = ''
                        arena_table.players[2] = {}
                        arena_table.gangs[2] = {}
                        arena_table.status = 1
                        arena_table.time_start = 0

                        timer.Remove('FatedGang.Arena-' .. arena_table.gangs[1])
                        timer.Remove('FatedGang.Arena-' .. arena_table.gangs[1] .. '-S')
                    end

                    net.Start('FatedGang-ToClientArena')
                        net.WriteTable(FatedGang.arenas)
                    net.Broadcast()
                end)

                local function StartGamePly(steamid64, arena_type)
                    local pl = player.GetBySteamID64(steamid64)

                    if !IsValid(pl) then
                        return
                    end

                    pl:SetGangArenaType(arena_type)
                    pl:SetGangActiveArena(arena_id)
                    pl:SetGangArenaPlayerDeath(false)

                    local valid_vectors = {}

                    for k, arena_spawn in pairs(arena_table.spawns[arena_type]) do
                        if !arena_spawn[2] then
                            table.insert(valid_vectors, k)
                        end
                    end

                    arena_table.spawns[arena_type][table.Random(valid_vectors)][2] = steamid64

                    pl:Spawn()
                end

                local function ArenaRoundStart(round)
                    arena_table.round = arena_table.round + 1
                    arena_table.arena_time = CurTime() + FatedGang.config.arena_round_time
                    arena_table.alive = {0, 0}
                    
                    local function PairGangsTable(t)
                        for _, steamid64 in pairs(arena_table.players[t]) do
                            StartGamePly(steamid64, t)
                        end
                    end

                    local function CheckGangAlive(t)
                        for _, steamid64 in pairs(arena_table.players[t]) do
                            local pl = player.GetBySteamID64(steamid64)
        
                            if IsValid(pl) and !pl:GetGangArenaPlayerDeath() then
                                if t == 1 then
                                    arena_table.alive[1] = arena_table.alive[1] + 1
                                else
                                    arena_table.alive[2] = arena_table.alive[2] + 1
                                end
                            end
                        end
                    end

                    CheckGangAlive(1)
                    CheckGangAlive(2)

                    local function AddWin(t)
                        if arena_table.round == 1 then
                            return
                        end

                        arena_table.wins[t] = arena_table.wins[t] + 1
                    end

                    if arena_table.alive[1] > arena_table.alive[2] then
                        AddWin(1)
                    elseif arena_table.alive[2] > arena_table.alive[1] then
                        AddWin(2)
                    end

                    if arena_table.round == FatedGang.config.arena_rounds + 1 or arena_table.wins[1] > FatedGang.config.arena_rounds * 0.5 or arena_table.wins[2] > FatedGang.config.arena_rounds * 0.5 then
                        arena_table.status = 4
                        arena_table.time_start = 0
                        arena_table.arena_time = 0
                        arena_table.round = 0

                        local function RemovePlayersFromArena(t)
                            for _, steamid64 in pairs(arena_table.players[t]) do
                                local pl = player.GetBySteamID64(steamid64)

                                if IsValid(pl) then
                                    pl:SetGangArenaType('0')
                                    pl:SetGangActiveArena('0')
                                    pl:SetGangArenaPlayerDeath(false)
                                    pl:Spawn()
                                end
                            end
                        end

                        RemovePlayersFromArena(1)
                        RemovePlayersFromArena(2)

                        arena_table.players = {
                            {},
                            {}
                        }

                        local function SaveGangWin(t)
                            local gang_id_winner = arena_table.gangs[t]
                            local gang_winner_table = FatedGang.data[gang_id_winner]

                            gang_winner_table.arena_wins = gang_winner_table.arena_wins + 1
                            arena_table.winner = gang_id_winner

                            local lose_info = arena_table.gangs[3 - t]

                            print(lose_info)

                            table.insert(arena_table.loser, lose_info)
                        end

                        if arena_table.wins[1] > arena_table.wins[2] then
                            SaveGangWin(1)
                        elseif arena_table.wins[2] > arena_table.wins[1] then
                            SaveGangWin(2)
                        end

                        arena_table.wins = {0, 0}
                        arena_table.gangs = {
                            '',
                            ''
                        }
                        arena_table.alive = {0, 0}

                        if timer.Exists('FatedGang.Arena-' .. arena_table.id) then
                            timer.Remove('FatedGang.Arena-' .. arena_table.id)
                        end

                        net.Start('FatedGang-ToClientArena')
                            net.WriteTable(FatedGang.arenas)
                        net.Broadcast()

                        FatedGang.initializationSendGangData()
                        net.Broadcast()

                        if timer.Exists('FatedGang.Arena.Game-' .. arena_id) then
                            timer.Remove('FatedGang.Arena.Game-' .. arena_id)
                        end

                        return
                    end

                    PairGangsTable(1)
                    PairGangsTable(2)

                    local function ResetSpawnTeam(t)
                        for k, spawn in pairs(arena_table.spawns[t]) do
                            spawn[2] = nil
                        end
                    end

                    ResetSpawnTeam(1)
                    ResetSpawnTeam(2)

                    net.Start('FatedGang-ToClientArena')
                        net.WriteTable(FatedGang.arenas)
                    net.Broadcast()
                end

                timer.Create('FatedGang.Arena-' .. arena_table.gangs[1] .. '-S', FatedGang.config.arena_waiting_time, 1, function()
                    arena_table.status = 3
                    arena_table.weapon = table.Random(FatedGang.config.arena_weapons)

                    ArenaRoundStart(arena_table.round)

                    timer.Create('FatedGang.Arena.Game-' .. arena_id, FatedGang.config.arena_round_time + 1, FatedGang.config.arena_rounds, function()
                        ArenaRoundStart(arena_table.round)
                    end)
                end)
            end

            if arena_table.gangs[1] == '' then
                arena_table.gangs[1] = pl:GetGangId()
                
                if arena_table.winner != '' then
                    TwoPlayerJoin(arena_table.winner)
                else
                    arena_table.status = 1
                end
            elseif arena_table.gangs[2] == '' and pl:GetGangId() != arena_table.gangs[1] then
                TwoPlayerJoin(pl:GetGangId())
            end

            net.Start('FatedGang-ToClientArena')
                net.WriteTable(FatedGang.arenas)
            net.Broadcast()
        end)
    end
end

if CLIENT then
    net.Receive('FatedGang-ToClient', function()
        local bytes_amount = net.ReadUInt(16)
        local compressed_data = net.ReadData(bytes_amount)
        local data = util.JSONToTable(util.Decompress(compressed_data))

        FatedGang.data = data
    end)

    if FatedGang.config.arena_enabled then
        net.Receive('FatedGang-ToClientArena', function()
            local data = net.ReadTable()

            FatedGang.arenas = data
        end)
    end

    local color_green_1 = Color(58, 116, 91)
    local color_green_2 = Color(68, 85, 78)

    net.Receive('FatedGang-Msg', function()
        local txt = net.ReadString()
    
        chat.AddText(color_green_1, '[', color_green_2, 'FatedGang', color_green_1, '] ', color_white, txt)
        chat.PlaySound()
    end)
end
