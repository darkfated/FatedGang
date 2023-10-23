if SERVER then
    util.AddNetworkString('FatedGang-ToClient')
    util.AddNetworkString('FatedGang-Msg')
    util.AddNetworkString('FatedGang-ChangeGang')
    util.AddNetworkString('FatedGang-InviteFeedback')
    util.AddNetworkString('FatedGang-SetColor')
    util.AddNetworkString('FatedGang-CreateGang')

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

        net.Start('FatedGang-ToClient')
            net.WriteTable(FatedGang.data)
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
        local gang_id = FatedGang.data.invites[pl:SteamID64()][invite_id].id

        if !FatedGang.data[gang_id] then
            FatedGang.notify(pl, 'Банда не существует.')

            FatedGang.data.invites[pl:SteamID64()][invite_id] = nil

            net.Start('FatedGang-ToClient')
                net.WriteTable(FatedGang.data)
            net.Broadcast()
            
            return
        end

        if invite_feedback_bool then
            FatedGang.data[gang_id].players[pl:SteamID64()] = {
                nick = pl:Name(),
                steamid = pl:SteamID(),
                rank = 'Участник'
            }

            pl:SetGangId(FatedGang.data.invites[pl:SteamID64()][invite_id].id)

            for gang_pl_steamid, _ in pairs(pl:GetGangTable().players) do
                local gang_pl = player.GetBySteamID64(gang_pl_steamid)

                FatedGang.notify(gang_pl, string.format('%s вступил в банду!', pl:Name()))
            end
        end

        FatedGang.data.invites[pl:SteamID64()][invite_id] = nil

        net.Start('FatedGang-ToClient')
            net.WriteTable(FatedGang.data)
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

        local color_r, color_g, color_b = net.ReadInt(9), net.ReadInt(9), net.ReadInt(9)

        pl:GetGangTable().color = Color(color_r, color_g, color_b)
        
        FatedGang.notify(pl, 'Вы сменили цвет банды.')

        net.Start('FatedGang-ToClient')
            net.WriteTable(FatedGang.data)
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
    
        FatedGang.data[pl:SteamID64()] = {
            id = pl:SteamID64(),
            name = gang_name,
            desc = gang_desc,
            color = gang_color,
            img = gang_img != '' and gang_img or 'neqfF6C',
            players = {
                [pl:SteamID64()] = {
                    nick = pl:Name(),
                    steamid = pl:SteamID(),
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
            }
        }
    
        pl:SetGangId(pl:SteamID64())
    
        net.Start('FatedGang-ToClient')
            net.WriteTable(FatedGang.data)
        net.Broadcast()
    end)
end

if CLIENT then
    net.Receive('FatedGang-ToClient', function()
        local data = net.ReadTable()

        FatedGang.data = data
    end)

    local color_green_1 = Color(58, 116, 91)
    local color_green_2 = Color(68, 85, 78)

    net.Receive('FatedGang-Msg', function()
        local txt = net.ReadString()
    
        chat.AddText(color_green_1, '[', color_green_2, 'FatedGang', color_green_1, '] ', color_white, txt)
        chat.PlaySound()
    end)
end
