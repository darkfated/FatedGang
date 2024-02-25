if SERVER then
    util.AddNetworkString('FatedGang-Create')
    util.AddNetworkString('FatedGang-ToClientAll')
    util.AddNetworkString('FatedGang-ToClient')
    util.AddNetworkString('FatedGang-ColorRank')
    util.AddNetworkString('FatedGang-ChangeInfo')
    util.AddNetworkString('FatedGang-ClientRemove')
    util.AddNetworkString('FatedGang-ClientPlayerRemove')
    util.AddNetworkString('FatedGang-SendInvite')
    util.AddNetworkString('FatedGang-AcceptInvite')
    
    net.Receive('FatedGang-Create', function(_, pl)
        local name = net.ReadString()
        local col = net.ReadColor()

        if !name or !col then
            return
        end

        if string.len(name) < 3 then
            Mantle.notify(pl, Color(102, 49, 138), 'Банды', 'Название должно быть больше 2.')

            return
        end

        if string.len(name) > 32 then
            Mantle.notify(pl, Color(102, 49, 138), 'Банды', 'Название должно быть меньше 33.')

            return
        end

        if !pl:canAfford(FatedGang.config.create_cost) then
            Mantle.notify(pl, Color(102, 49, 138), 'Банды', 'Не хватает денег (требуется ' .. DarkRP.formatMoney(FatedGang.config.create_cost) .. ')')

            return
        end

        local tabl_info = {
            name = name,
            desc = '',
            col = col,
            img = 'bmdKtlc.png',
            ranks = {
                {
                    name = 'Участник',
                    col = Color(51, 74, 43),
                    access = {
                        invite = true
                    }
                }
            }
        }

        local tabl_players = {
            [pl:SteamID()] = {
                nick = pl:Name(),
                steamid64 = pl:SteamID64(),
                rank = 1,
                boss = true
            }
        }

        tabl_info = util.TableToJSON(tabl_info)
        tabl_players = util.TableToJSON(tabl_players)

        sql.Query("INSERT INTO fatedgang (id, info, players) VALUES ('" .. pl:SteamID() .. "', '" .. tabl_info .. "', '" .. tabl_players .. "')")

        pl:SetNWString('fatedgang_id', pl:SteamID())
        pl:addMoney(-FatedGang.config.create_cost)

        Mantle.notify(pl, Color(102, 49, 138), 'Банды', 'Ваша банда успешно создана!')
        GameProfile.add_achievement(pl, 'create_gang', 1)

        net.Start('FatedGang-ToClient')
            net.WriteString(pl:SteamID())
            net.WriteTable({id = pl:SteamID(), info = tabl_info, players = tabl_players, score = 0})
        net.Broadcast()
    end)

    net.Receive('FatedGang-ColorRank', function(_, pl)
        local id = net.ReadString()
        local k = net.ReadUInt(6)
        local rank_color = net.ReadColor()
        local pl_gang = pl:GangId()

        if !pl_gang then
            return
        end

        if !pl:IsSuperAdmin() and pl:SteamID() != pl_gang then
            Mantle.notify(pl, Color(102, 49, 138), 'Банды', 'У вас нету прав на совершение этого действия.')
    
            return
        end

        local querySelect = string.format("SELECT * FROM fatedgang WHERE id = '%s'", id)
        local resultSelect = sql.Query(querySelect)

        if resultSelect then
            local gang_table = resultSelect[1]
            local info_table = util.JSONToTable(gang_table.info)
            info_table.ranks[k].col = rank_color
            info_table = util.TableToJSON(info_table)

            local queryUpdate = string.format("UPDATE fatedgang SET info = '%s' WHERE id = '%s'", info_table, id)
            sql.Query(queryUpdate)

            gang_table.info = info_table

            net.Start('FatedGang-ToClient')
                net.WriteString(pl_gang)
                net.WriteTable(gang_table)
            net.Broadcast()
        end
    end)

    net.Receive('FatedGang-ChangeInfo', function(_, pl)
        local id = net.ReadString()
        local new_name = net.ReadString()
        local new_desc = net.ReadString()
        local new_col = net.ReadTable()
        local pl_gang = pl:GangId()

        if !pl_gang then
            return
        end

        if string.len(new_name) < 3 then
            Mantle.notify(pl, Color(102, 49, 138), 'Банды', 'Название должно быть больше 2.')

            return
        end

        if string.len(new_name) > 32 then
            Mantle.notify(pl, Color(102, 49, 138), 'Банды', 'Название должно быть меньше 33.')

            return
        end

        if !pl:IsSuperAdmin() and pl:SteamID() != pl_gang then
            Mantle.notify(pl, Color(102, 49, 138), 'Банды', 'У вас нету прав на совершение этого действия.')
    
            return
        end

        local querySelect = string.format("SELECT * FROM fatedgang WHERE id = '%s'", id)
        local resultSelect = sql.Query(querySelect)

        if resultSelect then
            local gang_table = resultSelect[1]
            local info_table = util.JSONToTable(gang_table.info)
            info_table.name = new_name
            info_table.desc = new_desc
            info_table.col = new_col
            info_table = util.TableToJSON(info_table)

            local queryUpdate = string.format("UPDATE fatedgang SET info = '%s' WHERE id = '%s'", info_table, id)
            sql.Query(queryUpdate)

            gang_table.info = info_table

            net.Start('FatedGang-ToClient')
                net.WriteString(id)
                net.WriteTable(gang_table)
            net.Broadcast()

            Mantle.notify(pl, Color(102, 49, 138), 'Банды', 'Настройки применены.')
        end
    end)

    net.Receive('FatedGang-AcceptInvite', function(_, pl)
        local gang_id = net.ReadString()
        local querySelect = string.format("SELECT * FROM fatedgang WHERE id = '%s'", gang_id)
        local resultSelect = sql.Query(querySelect)

        if resultSelect then
            local gang_table = resultSelect[1]
            local players_table = util.JSONToTable(gang_table.players)

            if !players_table[pl:SteamID()] then
                players_table[pl:SteamID()] = {
                    nick = pl:Name(),
                    steamid64 = pl:SteamID64(),
                    rank = 1
                }
                players_table = util.TableToJSON(players_table)
    
                local queryUpdate = string.format("UPDATE fatedgang SET players = '%s' WHERE id = '%s'", players_table, id)
                sql.Query(queryUpdate)
    
                gang_table.players = players_table
    
                net.Start('FatedGang-ToClient')
                    net.WriteString(gang_id)
                    net.WriteTable(gang_table)
                net.Broadcast()

                pl:SetGangId(gang_id)
            end
        end
    end)
else
    net.Receive('FatedGang-ToClientAll', function()
        local data_size = net.ReadUInt(32)
        local data = net.ReadData(data_size)

        FatedGang.gangs = util.JSONToTable(util.Decompress(data))
    end)

    net.Receive('FatedGang-ToClient', function()
        local new_gang_id = net.ReadString()
        local new_gang_data = net.ReadTable()

        FatedGang.gangs[new_gang_id] = new_gang_data
    end)

    net.Receive('FatedGang-ClientRemove', function()
        local gang_id = net.ReadString()
        
        FatedGang.gangs[gang_id] = nil
    end)

    net.Receive('FatedGang-ClientPlayerRemove', function()
        local gang_id = net.ReadString()
        local gang_players = net.ReadTable()
        
        FatedGang.gangs[gang_id].players = util.TableToJSON(gang_players)
    end)

    net.Receive('FatedGang-SendInvite', function()
        local gang_id = net.ReadString()

        local InviteMenu = vgui.Create('DPanel')
        InviteMenu:SetSize(280, 122)
        InviteMenu:SetPos(ScrW() * 0.5 - InviteMenu:GetWide() * 0.5, ScrH() - InviteMenu:GetTall() - 10)

        local gang_table = FatedGang.gangs[gang_id]
        local info_table = util.JSONToTable(gang_table.info)

        InviteMenu.Paint = function(self, w, h)
            local x, y = self:LocalToScreen()

            BSHADOWS.BeginShadow()
                draw.RoundedBoxEx(16, x, y, w, h, Mantle.color.panel[2], true, true, false, false)
                draw.SimpleText('Вы были приглашены в банду', 'Fated.22', x + w * 0.5, y + 8, Mantle.color.gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                draw.SimpleText(info_table.name, 'Fated.20', x + w * 0.5, y + 34, info_table.col, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            BSHADOWS.EndShadow(1, 2, 2, 255, 0, 0)
        end

        InviteMenu.btn_close = vgui.Create('DButton', InviteMenu)
        Mantle.ui.btn(InviteMenu.btn_close)
        InviteMenu.btn_close:Dock(BOTTOM)
        InviteMenu.btn_close:DockMargin(4, 4, 4, 4)
        InviteMenu.btn_close:SetTall(26)
        InviteMenu.btn_close:SetText('Отклонить')
        InviteMenu.btn_close.DoClick = function()
            InviteMenu:Remove()
        end

        InviteMenu.btn_accept = vgui.Create('DButton', InviteMenu)
        Mantle.ui.btn(InviteMenu.btn_accept)
        InviteMenu.btn_accept:Dock(BOTTOM)
        InviteMenu.btn_accept:DockMargin(4, 4, 4, 0)
        InviteMenu.btn_accept:SetTall(26)
        InviteMenu.btn_accept:SetText('Принять')
        InviteMenu.btn_accept.DoClick = function()
            net.Start('FatedGang-AcceptInvite')
                net.WriteString(gang_id)
            net.SendToServer()

            InviteMenu:Remove()
        end
    end)
end
