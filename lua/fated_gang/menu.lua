FatedGang.ui = FatedGang.ui or {}

local function CreateGang()
    if IsValid(FatedGang.ui.CreateGang) then
        FatedGang.ui.CreateGang:Remove()
    end

    FatedGang.ui.CreateGang = vgui.Create('DFrame')
    Mantle.ui.frame(FatedGang.ui.CreateGang, 'Создать банду', 360, 320, true)
    FatedGang.ui.CreateGang:Center()
    FatedGang.ui.CreateGang:MakePopup()
    FatedGang.ui.CreateGang.color = Color(59, 91, 45)
    FatedGang.ui.CreateGang.icon = ''

    FatedGang.ui.CreateGang.panel_content = vgui.Create('DPanel', FatedGang.ui.CreateGang)
    FatedGang.ui.CreateGang.panel_content:Dock(FILL)
    FatedGang.ui.CreateGang.panel_content.Paint = nil
    PrintTable(FatedGang.data)
    local gang_invite_table = FatedGang.data.invites[LocalPlayer():SteamID64()] or {}

    local function CreateContentInvite()
        FatedGang.ui.CreateGang.f_title = 'Список приглашений'

        FatedGang.ui.CreateGang.btn_invite:Remove()
        FatedGang.ui.CreateGang.panel_content:Remove()

        FatedGang.ui.CreateGang.sp = vgui.Create('DScrollPanel', FatedGang.ui.CreateGang)
        Mantle.ui.sp(FatedGang.ui.CreateGang.sp)
        FatedGang.ui.CreateGang.sp:Dock(FILL)

        for i, invite in pairs(gang_invite_table) do
            local panel_invite = vgui.Create('DPanel', FatedGang.ui.CreateGang.sp)
            panel_invite:Dock(TOP)
            panel_invite:DockMargin(0, 0, 0, 6)
            panel_invite:SetTall(60)

            http.DownloadMaterial('https://i.imgur.com/' .. invite.img .. '.png', invite.img .. '.png', function(gang_icon)
                if IsValid(FatedGang.ui.CreateGang) and IsValid(panel_invite) then
                    panel_invite.Paint = function(_, w, h)
                        draw.RoundedBox(6, 6, 6, w - 12, h - 12, Mantle.color.panel[3])

                        draw.RoundedBox(4, 10, 10, 40, 40, Mantle.color.background)
                        surface.SetDrawColor(color_white)
                        surface.SetMaterial(gang_icon)
                        surface.DrawTexturedRect(12, 12, 36, 36)
        
                        draw.SimpleText(invite.name, 'Fated.22', 56, h * 0.5, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    end
                end
            end)

            panel_invite.panel_right = vgui.Create('DPanel', panel_invite)
            panel_invite.panel_right:Dock(RIGHT)
            panel_invite.panel_right:SetWide(160)
            panel_invite.panel_right.Paint = nil

            panel_invite.panel_right.btn_accept = vgui.Create('DButton', panel_invite.panel_right)
            Mantle.ui.btn(panel_invite.panel_right.btn_accept, nil, nil, Color(83, 167, 65))
            panel_invite.panel_right.btn_accept:Dock(LEFT)
            panel_invite.panel_right.btn_accept:SetWide(80)
            panel_invite.panel_right.btn_accept:SetText('Принять')
            panel_invite.panel_right.btn_accept.DoClick = function()
                Mantle.func.sound()

                net.Start('FatedGang-InviteFeedback')
                    net.WriteInt(i, 5)
                    net.WriteBool(true)
                net.SendToServer()

                FatedGang.ui.CreateGang:Remove()
            end

            panel_invite.panel_right.btn_deny = vgui.Create('DButton', panel_invite.panel_right)
            Mantle.ui.btn(panel_invite.panel_right.btn_deny, nil, nil, Color(232, 105, 105))
            panel_invite.panel_right.btn_deny:Dock(RIGHT)
            panel_invite.panel_right.btn_deny:SetWide(80)
            panel_invite.panel_right.btn_deny:SetText('Отклонить')
            panel_invite.panel_right.btn_deny.DoClick = function()
                Mantle.func.sound()

                net.Start('FatedGang-InviteFeedback')
                    net.WriteInt(i, 5)
                    net.WriteBool(false)
                net.SendToServer()

                panel_invite:Remove()
            end
        end
    end

    FatedGang.ui.CreateGang.btn_invite = vgui.Create('DButton', FatedGang.ui.CreateGang)
    Mantle.ui.btn(FatedGang.ui.CreateGang.btn_invite)
    FatedGang.ui.CreateGang.btn_invite:SetSize(120, 20)
    FatedGang.ui.CreateGang.btn_invite:SetText('Приглашений: ' .. #gang_invite_table)
    FatedGang.ui.CreateGang.btn_invite:SetPos(FatedGang.ui.CreateGang:GetWide() - FatedGang.ui.CreateGang.btn_invite:GetWide() - 24, 2)
    FatedGang.ui.CreateGang.btn_invite.DoClick = function()
        if #gang_invite_table != 0 then
            CreateContentInvite()
        else
            chat.AddText(Color(255, 73, 73), 'Нету приглашений.')
            chat.PlaySound()
        end
    end

    local entry_name = Mantle.ui.desc_entry(FatedGang.ui.CreateGang.panel_content, 'Название:', 'Как ваша банда будет называться')
    local entry_desc = Mantle.ui.desc_entry(FatedGang.ui.CreateGang.panel_content, 'Краткое описание:', 'Расскажите немного о вашей банде')

    local color_select = vgui.Create('DButton', FatedGang.ui.CreateGang.panel_content)
    color_select:Dock(TOP)
    color_select:DockMargin(0, 21, 0, 0)
    color_select:SetTall(30)
    color_select:SetText('')
    color_select.Paint = function(_, w, h)
        draw.RoundedBox(6, 0, 0, w, h, FatedGang.ui.CreateGang.color)
        draw.SimpleText('Цвет', 'Fated.16', w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    color_select.DoClick = function()
        Mantle.ui.color_picker(function(col)
            FatedGang.ui.CreateGang.color = col
        end, FatedGang.ui.CreateGang.color)
    end

    local icon_select = vgui.Create('DButton', FatedGang.ui.CreateGang.panel_content)
    icon_select:Dock(TOP)
    icon_select:DockMargin(0, 21, 0, 0)
    icon_select:SetTall(64)
    icon_select:SetText('')
    icon_select.Paint = function(self, w, h)
        draw.RoundedBox(6, w * 0.5 - 32, 0, 64, 64, Mantle.color.panel[1])
    end
    icon_select.PaintOver = function(_, w, h)
        draw.SimpleText('Иконка', 'Fated.16', w * 0.5 - 1, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    icon_select.DoClick = function()
        Mantle.func.sound()

        Derma_StringRequest('Установить иконку', 'Вставьте ссылку на imgur-картинку', FatedGang.ui.CreateGang.icon, function(img_url)
            local img_code = img_url

            if string.len(img_code) != 7 then
                img_code = string.sub(img_url, 21, 27)
            end

            FatedGang.ui.CreateGang.icon = img_code

            http.DownloadMaterial('https://i.imgur.com/' .. FatedGang.ui.CreateGang.icon .. '.png', FatedGang.ui.CreateGang.icon .. '.png', function(gang_icon)
                if IsValid(FatedGang.ui.CreateGang) then
                    icon_select.Paint = function(_, w, h)
                        surface.SetDrawColor(color_white)
                        surface.SetMaterial(gang_icon)
                        surface.DrawTexturedRect(w * 0.5 - 32, 0, 64, h)
                    end
                end
            end)
        end, nil, 'Поставить', 'Отмена')
    end

    FatedGang.ui.CreateGang.panel_content.btn_create = vgui.Create('DButton', FatedGang.ui.CreateGang.panel_content)
    Mantle.ui.btn(FatedGang.ui.CreateGang.panel_content.btn_create)
    FatedGang.ui.CreateGang.panel_content.btn_create:Dock(BOTTOM)
    FatedGang.ui.CreateGang.panel_content.btn_create:SetText('ПРИНЯТЬ')
    FatedGang.ui.CreateGang.panel_content.btn_create.DoClick = function()
        Mantle.func.sound()

        FatedGang.ui.CreateGang:Remove()

        net.Start('FatedGang-CreateGang')
            net.WriteString(entry_name:GetValue())
            net.WriteString(entry_desc:GetValue())
            net.WriteTable(FatedGang.ui.CreateGang.color)
            net.WriteString(FatedGang.ui.CreateGang.icon)
        net.SendToServer()

        timer.Simple(1, function()
            if LocalPlayer():GetGangId() != '0' then
                RunConsoleCommand('fated_gang_open')
            end
        end)
    end
end

concommand.Add('fated_gang_create', CreateGang)

local function OpenGang()
    if IsValid(FatedGang.ui.OpenGang) then
        FatedGang.ui.OpenGang:Remove()
    end

    local ply = LocalPlayer()
    local ply_gang_id = ply:GetGangId()
    
    if ply_gang_id == '0' then
        chat.AddText(Color(255, 73, 73), 'У вас нет банды.')
        chat.PlaySound()

        return
    end

    local gang_table = ply:GetGangTable()

    FatedGang.ui.OpenGang = vgui.Create('DFrame')
    Mantle.ui.frame(FatedGang.ui.OpenGang, 'FatedGang - ' .. gang_table.name, 782, 440, true)
    FatedGang.ui.OpenGang:Center()
    FatedGang.ui.OpenGang:MakePopup()
    FatedGang.ui.OpenGang:SetKeyBoardInputEnabled(false)

    FatedGang.ui.OpenGang.panel_content = vgui.Create('DPanel', FatedGang.ui.OpenGang)
    FatedGang.ui.OpenGang.panel_content:Dock(FILL)
    FatedGang.ui.OpenGang.panel_content.Paint = nil

    local color_shadow = Color(0, 0, 0, 110)

    FatedGang.ui.OpenGang.panel_left = vgui.Create('DPanel', FatedGang.ui.OpenGang)
    FatedGang.ui.OpenGang.panel_left:Dock(LEFT)
    FatedGang.ui.OpenGang.panel_left:DockMargin(0, 0, 8, 0)
    FatedGang.ui.OpenGang.panel_left:SetWide(170)
    FatedGang.ui.OpenGang.panel_left.Paint = function(_, w, h)
        draw.RoundedBox(8, 0, 0, w, h, color_shadow)
        draw.RoundedBox(8, 0, 0, w - 1, h - 1, Mantle.color.panel[2])
    end

    local mat_image = Material('fated_gang/menu/image-set.png')

    FatedGang.ui.OpenGang.panel_left.top = vgui.Create('DPanel', FatedGang.ui.OpenGang.panel_left)
    FatedGang.ui.OpenGang.panel_left.top:Dock(TOP)
    FatedGang.ui.OpenGang.panel_left.top:SetTall(100)
    FatedGang.ui.OpenGang.panel_left.top.Paint = function(self, w, h)
        draw.RoundedBox(4, 8, 8, 84, 84, Mantle.color.background)

        draw.SimpleText('Участники', 'Fated.14', 130, 10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

        draw.RoundedBox(6, 100, 27, 61, 24, Mantle.color.panel[1])
        draw.SimpleText(table.Count(gang_table.players), 'Fated.20', 131, 38, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local mat_color = Material('fated_gang/menu/color.png')

    FatedGang.ui.OpenGang.panel_left.top.color = vgui.Create('DButton', FatedGang.ui.OpenGang.panel_left.top)
    FatedGang.ui.OpenGang.panel_left.top.color:SetSize(36, 36)
    FatedGang.ui.OpenGang.panel_left.top.color:SetPos(113, 54)
    FatedGang.ui.OpenGang.panel_left.top.color:SetText('')
    FatedGang.ui.OpenGang.panel_left.top.color.Paint = function(_, w, h)
        local col = ply:GetGangTable().color

        draw.RoundedBox(100, 6, 6, w - 12, h - 12, col)

        surface.SetDrawColor(color_white)
        surface.SetMaterial(mat_color)
        surface.DrawTexturedRect(0, 0, w, h)
    end
    FatedGang.ui.OpenGang.panel_left.top.color:SetTooltip('Цвет банды')
    FatedGang.ui.OpenGang.panel_left.top.color.DoClick = function()
        Mantle.ui.color_picker(function(col)
            net.Start('FatedGang-SetColor')
                net.WriteInt(col.r, 9)
                net.WriteInt(col.g, 9)
                net.WriteInt(col.b, 9)
            net.SendToServer()
        end, gang_table.color)
    end

    FatedGang.ui.OpenGang.panel_left.top.img = vgui.Create('DButton', FatedGang.ui.OpenGang.panel_left.top)
    FatedGang.ui.OpenGang.panel_left.top.img:SetSize(76, 76)
    FatedGang.ui.OpenGang.panel_left.top.img:SetPos(12, 12)
    FatedGang.ui.OpenGang.panel_left.top.img:SetText('')

    local function CreateGangImg(img)
        http.DownloadMaterial('https://i.imgur.com/' .. img .. '.png', img .. '.png', function(gang_icon)
            FatedGang.ui.OpenGang.panel_left.top.img.Paint = function(self, w, h)
                surface.SetDrawColor(color_white)
                surface.SetMaterial(gang_icon)
                surface.DrawTexturedRect(0, 0, w, h)

                if self:IsHovered() then
                    draw.RoundedBox(0, 0, 0, w, h, color_shadow)

                    surface.SetDrawColor(color_white)
                    surface.SetMaterial(mat_image)
                    surface.DrawTexturedRect(6, 6, w - 12, h - 12)
                end
            end
        end)
    end

    CreateGangImg(gang_table.img)

    FatedGang.ui.OpenGang.panel_left.top.img.DoClick = function()
        Mantle.func.sound()

        Derma_StringRequest('Установить иконку', 'Вставьте ссылку на imgur-картинку', 'https://i.imgur.com/' .. gang_table.img .. '.png', function(img_url)
            local img_code = img_url

            if string.len(img_code) != 7 then
                img_code = string.sub(img_url, 21, 27)
            end

            RunConsoleCommand('fated_gang_command_img', img_code)

            CreateGangImg(img_code)
        end, nil, 'Поставить', 'Отмена')
    end

    FatedGang.ui.OpenGang.panel_left.sp = vgui.Create('DScrollPanel', FatedGang.ui.OpenGang.panel_left)
    Mantle.ui.sp(FatedGang.ui.OpenGang.panel_left.sp)
    FatedGang.ui.OpenGang.panel_left.sp:Dock(FILL)
    FatedGang.ui.OpenGang.panel_left.sp:DockMargin(0, 0, 1, 0)

    local function CreatePageMain()
        FatedGang.ui.OpenGang.navbar = vgui.Create('DHorizontalScroller', FatedGang.ui.OpenGang.panel_content)
        FatedGang.ui.OpenGang.navbar:Dock(TOP)
        FatedGang.ui.OpenGang.navbar:SetTall(36)
        FatedGang.ui.OpenGang.navbar:SetOverlap(-8)
        FatedGang.ui.OpenGang.navbar.Paint = function(_, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Mantle.color.panel[1])
        end

        local list_gang_commands = {}

        if LocalPlayer():IsGangBoss() or LocalPlayer():GetGangTableRank().access.edit then
            table.insert(list_gang_commands, {
                name = 'Настройки банды',
                icon = Material('fated_gang/menu/edit.png'),
                color = Color(143, 143, 107),
                func = function()
                    FatedGang.ui.OpenGang:SetKeyBoardInputEnabled(true)
                    
                    FatedGang.ui.OpenGang.menu_splash = vgui.Create('DPanel', FatedGang.ui.OpenGang)
                    FatedGang.ui.OpenGang.menu_splash:SetSize(FatedGang.ui.OpenGang:GetWide() - 190, FatedGang.ui.OpenGang:GetTall() - 36)
                    FatedGang.ui.OpenGang.menu_splash:SetPos(184, 30)
                    FatedGang.ui.OpenGang.menu_splash.Paint = function(_, w, h)
                        draw.RoundedBox(6, 0, 0, w, h, Mantle.color.panel[2])

                        draw.RoundedBoxEx(6, 0, 0, w, 36, Mantle.color.panel[1], true, true, false, false)

                        local text_settings_gang = 'Настройки банды'

                        surface.SetFont('Fated.22')

                        local text_settings_gang_wide = surface.GetTextSize(text_settings_gang)

                        draw.RoundedBox(0, w * 0.5 - text_settings_gang_wide * 0.5 - 10, 0, text_settings_gang_wide + 20, 36, Mantle.color.button)
                        Mantle.func.gradient(w * 0.5 - text_settings_gang_wide * 0.5 - 10, 0, text_settings_gang_wide + 20, 36, 1, Mantle.color.button_shadow)
                        draw.SimpleText('Настройки банды', 'Fated.22', w * 0.5, 18, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end

                    FatedGang.ui.OpenGang.menu_splash.content = vgui.Create('DPanel', FatedGang.ui.OpenGang.menu_splash)
                    FatedGang.ui.OpenGang.menu_splash.content:Dock(FILL)
                    FatedGang.ui.OpenGang.menu_splash.content:DockMargin(6, 44, 6, 6)
                    FatedGang.ui.OpenGang.menu_splash.content.Paint = nil

                    FatedGang.ui.OpenGang.menu_splash.content.left = vgui.Create('DPanel', FatedGang.ui.OpenGang.menu_splash.content)
                    FatedGang.ui.OpenGang.menu_splash.content.left:Dock(LEFT)
                    FatedGang.ui.OpenGang.menu_splash.content.left:SetWide(FatedGang.ui.OpenGang.menu_splash:GetWide() * 0.5 - 16)
                    FatedGang.ui.OpenGang.menu_splash.content.left.Paint = nil

                    local entry_name = Mantle.ui.desc_entry(FatedGang.ui.OpenGang.menu_splash.content.left, 'Название:', 'Клуб весёлых и находчивых')
                    entry_name:SetValue(gang_table.name)
                    local entry_desc = Mantle.ui.desc_entry(FatedGang.ui.OpenGang.menu_splash.content.left, 'Описание:', 'Здесь очень весело.')
                    entry_desc:SetValue(gang_table.desc)
                    entry_desc:SetMultiline(true)
                    entry_desc:SetTall(120)

                    FatedGang.ui.OpenGang.menu_splash.content.right = vgui.Create('DPanel', FatedGang.ui.OpenGang.menu_splash.content)
                    FatedGang.ui.OpenGang.menu_splash.content.right:Dock(RIGHT)
                    FatedGang.ui.OpenGang.menu_splash.content.right:DockMargin(6, 6, 6, 6)
                    FatedGang.ui.OpenGang.menu_splash.content.right:SetWide(FatedGang.ui.OpenGang.menu_splash:GetWide() * 0.5 - 16)
                    FatedGang.ui.OpenGang.menu_splash.content.right.Paint = nil

                    local GangRanks = {}

                    for rank_name_save, rank_table_save in pairs(LocalPlayer():GetGangTable().ranks) do
                        GangRanks[rank_name_save] = rank_table_save
                    end

                    FatedGang.ui.OpenGang.menu_splash.content.right.sp = vgui.Create('DScrollPanel', FatedGang.ui.OpenGang.menu_splash.content.right)
                    Mantle.ui.sp(FatedGang.ui.OpenGang.menu_splash.content.right.sp)
                    FatedGang.ui.OpenGang.menu_splash.content.right.sp:Dock(FILL)
                    FatedGang.ui.OpenGang.menu_splash.content.right.sp:DockMargin(0, 6, 0, 0)
                    
                    local function BuildRanks()
                        FatedGang.ui.OpenGang.menu_splash.content.right.sp:Clear()

                        for rank_name, _ in pairs(GangRanks) do
                            if rank_name == 'Участник' then
                                continue
                            end

                            local rank_panel = vgui.Create('DButton', FatedGang.ui.OpenGang.menu_splash.content.right.sp)
                            rank_panel:Dock(TOP)
                            rank_panel:DockMargin(0, 0, 0, 6)
                            rank_panel:SetText('')
                            rank_panel:SetTall(28)
                            rank_panel.name = rank_name

                            local rank_users = ''

                            for _, pl_table in pairs(LocalPlayer():GetGangTable().players) do
                                if pl_table.rank == rank_panel.name then
                                    rank_users = rank_users .. (rank_users != '' and '\n' or '') .. pl_table.nick
                                end
                            end

                            if rank_users == '' then
                                rank_users = 'Ни у кого нет такого ранга.'
                            end

                            rank_panel:SetTooltip(rank_users)
                            rank_panel.DoClick = function()
                                local DM = DermaMenu()
                                DM:AddOption('Изменить названия', function()
                                    Derma_StringRequest('Изменить название', 'Какое название ранга желаете?', rank_panel.name, function(s)
                                        if string.len(s) > 20 then
                                            chat.AddText(Color(255, 73, 73), 'Длинное название у ранга.')
                                    
                                            return
                                        end

                                        local tbl = {
                                            color = GangRanks[rank_panel.name].color,
                                            access = GangRanks[rank_panel.name].access
                                        }

                                        GangRanks[rank_panel.name] = nil
                                        GangRanks[s] = tbl
                                        rank_panel.name = s

                                        PrintTable(GangRanks)
                                    end, nil, 'Применить', 'Отменить')
                                end):SetIcon('icon16/text_signature.png')
                                DM:AddOption('Изменить цвет', function()
                                    Mantle.ui.color_picker(function(col)
                                        GangRanks[rank_panel.name].color = col
                                    end, GangRanks[rank_panel.name].color)
                                end):SetIcon('icon16/color_swatch.png')
                                DM:AddOption('Возможность приглашать', function()
                                    GangRanks[rank_panel.name].access.invite = !GangRanks[rank_panel.name].access.invite
                                end):SetIcon(GangRanks[rank_panel.name].access.invite and 'icon16/bullet_green.png' or 'icon16/bullet_red.png')
                                DM:AddOption('Возможность выгонять', function()
                                    GangRanks[rank_panel.name].access.kick = !GangRanks[rank_panel.name].access.kick
                                end):SetIcon(GangRanks[rank_panel.name].access.kick and 'icon16/bullet_green.png' or 'icon16/bullet_red.png')
                                DM:AddOption('Возможность давать ранг', function()
                                    GangRanks[rank_panel.name].access.rank = !GangRanks[rank_panel.name].access.rank
                                end):SetIcon(GangRanks[rank_panel.name].access.rank and 'icon16/bullet_green.png' or 'icon16/bullet_red.png')
                                DM:AddOption('Удалить ранг', function()
                                    rank_panel:Remove()

                                    GangRanks[rank_panel.name] = nil
                                end):SetIcon('icon16/delete.png')
                                DM:Open()
                            end

                            rank_panel.Paint = function(self, w, h)
                                draw.RoundedBox(4, 0, 0, w, h, GangRanks[rank_panel.name].color)
                                draw.SimpleText(self.name, 'Fated.16', w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                            end
                        end
                    end

                    BuildRanks()

                    FatedGang.ui.OpenGang.menu_splash.content.right.btn_create = vgui.Create('DButton', FatedGang.ui.OpenGang.menu_splash.content.right)
                    Mantle.ui.btn(FatedGang.ui.OpenGang.menu_splash.content.right.btn_create)
                    FatedGang.ui.OpenGang.menu_splash.content.right.btn_create:Dock(TOP)
                    FatedGang.ui.OpenGang.menu_splash.content.right.btn_create:SetTall(42)
                    FatedGang.ui.OpenGang.menu_splash.content.right.btn_create:SetText('Создать ранг')
                    FatedGang.ui.OpenGang.menu_splash.content.right.btn_create.DoClick = function()
                        GangRanks['Безымянный ранг'] = {
                            color = Color(106, 130, 101),
                            access = {
                                invite = false,
                                kick = false,
                                edit = false,
                                rank = false
                            }
                        }

                        BuildRanks()
                    end

                    FatedGang.ui.OpenGang.menu_splash.footer = vgui.Create('DPanel', FatedGang.ui.OpenGang.menu_splash)
                    FatedGang.ui.OpenGang.menu_splash.footer:Dock(BOTTOM)
                    FatedGang.ui.OpenGang.menu_splash.footer:DockMargin(6, 6, 6, 6)
                    FatedGang.ui.OpenGang.menu_splash.footer:DockPadding(6, 6, 6, 6)
                    FatedGang.ui.OpenGang.menu_splash.footer:SetTall(50)
                    FatedGang.ui.OpenGang.menu_splash.footer.Paint = function(_, w, h)
                        draw.RoundedBox(6, 0, 0, w, h, Mantle.color.background)
                    end

                    FatedGang.ui.OpenGang.menu_splash.footer.btn_left = vgui.Create('DButton', FatedGang.ui.OpenGang.menu_splash.footer)
                    Mantle.ui.btn(FatedGang.ui.OpenGang.menu_splash.footer.btn_left)
                    FatedGang.ui.OpenGang.menu_splash.footer.btn_left:Dock(LEFT)
                    FatedGang.ui.OpenGang.menu_splash.footer.btn_left:SetWide(250)
                    FatedGang.ui.OpenGang.menu_splash.footer.btn_left:SetText('Подтвердить')
                    FatedGang.ui.OpenGang.menu_splash.footer.btn_left.DoClick = function()
                        FatedGang.ui.OpenGang:Remove()
                        FatedGang.ui.OpenGang.menu_splash:Remove()
                        
                        net.Start('FatedGang-ChangeGang')
                            net.WriteString(entry_name:GetValue())
                            net.WriteString(entry_desc:GetValue())
                            net.WriteTable(GangRanks)
                        net.SendToServer()
                    end

                    FatedGang.ui.OpenGang.menu_splash.footer.btn_right = vgui.Create('DButton', FatedGang.ui.OpenGang.menu_splash.footer)
                    Mantle.ui.btn(FatedGang.ui.OpenGang.menu_splash.footer.btn_right)
                    FatedGang.ui.OpenGang.menu_splash.footer.btn_right:Dock(RIGHT)
                    FatedGang.ui.OpenGang.menu_splash.footer.btn_right:SetWide(250)
                    FatedGang.ui.OpenGang.menu_splash.footer.btn_right:SetText('Отмена')
                    FatedGang.ui.OpenGang.menu_splash.footer.btn_right.DoClick = function()
                        FatedGang.ui.OpenGang:SetKeyBoardInputEnabled(false)

                        FatedGang.ui.OpenGang.menu_splash:Remove()
                    end
                end
            })
        end

        if LocalPlayer():IsGangBoss() or LocalPlayer():GetGangTableRank().access.invite then
            table.insert(list_gang_commands, {
                name = 'Пригласить',
                icon = Material('fated_gang/menu/member.png'),
                color = Color(66, 79, 100),
                func = function()
                    Mantle.ui.player_selector(function(pl)
                        RunConsoleCommand('fated_gang_command_invite', pl:SteamID64())
                    end, function(pl)
                        return pl:GetGangId() != '0'
                    end)
                end
            })
        end

        table.insert(list_gang_commands, {
            name = 'Покинуть',
            icon = Material('fated_gang/menu/leave.png'),
            color = Color(100, 66, 66),
            func = function()
                RunConsoleCommand('fated_gang_command_leave')

                FatedGang.ui.OpenGang:Remove()
            end
        })

        for i, command in pairs(list_gang_commands) do
            local btn_gang_command = vgui.Create('DButton', FatedGang.ui.OpenGang.navbar)
            Mantle.ui.btn(btn_gang_command, command.icon, 32, nil, nil, nil, command.color)

            surface.SetFont('Fated.18')

            btn_gang_command:SetWide(surface.GetTextSize(command.name) + 48)
            btn_gang_command:SetText(command.name)
            btn_gang_command.DoClick = function()
                Mantle.func.sound()

                command.func()
            end

            FatedGang.ui.OpenGang.navbar:AddPanel(btn_gang_command)
        end

        FatedGang.ui.OpenGang.list_users = vgui.Create('DPanel', FatedGang.ui.OpenGang.panel_content)
        FatedGang.ui.OpenGang.list_users:Dock(FILL)
        FatedGang.ui.OpenGang.list_users:DockMargin(0, 8, 0, 0)
        FatedGang.ui.OpenGang.list_users.Paint = function(_, w, h)
            draw.RoundedBox(8, 0, 0, w, h, color_shadow)
            draw.RoundedBox(8, 0, 0, w - 1, h - 1, Mantle.color.panel[2])
        end

        FatedGang.ui.OpenGang.list_users.sp = vgui.Create('DScrollPanel', FatedGang.ui.OpenGang.list_users)
        Mantle.ui.sp(FatedGang.ui.OpenGang.list_users.sp)
        FatedGang.ui.OpenGang.list_users.sp:Dock(FILL)
        FatedGang.ui.OpenGang.list_users.sp:DockMargin(6, 6, 6, 6)

        local function CreateListPlayers()
            FatedGang.ui.OpenGang.list_users.sp:Clear()

            local function AddPlayer(pl, steamid64)
                local table_rank = GetGangTableRank(pl.rank, gang_table.id)

                local panel_player = vgui.Create('DButton', FatedGang.ui.OpenGang.list_users.sp)
                panel_player:Dock(TOP)
                panel_player:DockMargin(0, 0, 0, 6)
                panel_player:SetTall(40)
                panel_player:SetText('')
                panel_player.Paint = function(_, w, h)
                    draw.RoundedBox(6, 0, 0, w, h, table_rank and table_rank.color or color_black)

                    draw.SimpleText(pl.nick, 'Fated.22', 42, h * 0.5, table_rank and color_black or color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText(table_rank and (pl.rank .. (pl.boss and ' (Босс)' or '')) or 'Ранг недействителен!', 'Fated.22', w - 6, h * 0.5, table_rank and color_black or color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                end
                panel_player.DoClick = function()
                    Mantle.func.sound()

                    local DM = DermaMenu()

                    if LocalPlayer():IsGangBoss() or LocalPlayer():GetGangTableRank().access.rank then
                        local Child, Parent = DM:AddSubMenu('Назначить ранг')
                        Parent:SetIcon('icon16/key.png')
                    
                        for rank_name, rank_table in pairs(gang_table.ranks) do
                            Child:AddOption(rank_name, function()
                                RunConsoleCommand('fated_gang_command_rank', steamid64, rank_name)

                                CreateListPlayers()
                            end):SetTextColor(rank_table.color)
                        end
                    end

                    if LocalPlayer():IsGangBoss() or LocalPlayer():GetGangTableRank().access.kick then
                        DM:AddOption('Выгнать из банды', function()
                            RunConsoleCommand('fated_gang_command_kick', steamid64)
                        end):SetIcon('icon16/cancel.png')
                    end

                    if LocalPlayer():IsGangBoss() then
                        DM:AddOption('Передать владельца', function()
                            RunConsoleCommand('fated_gang_command_boss', steamid64)
                        end):SetIcon('icon16/user_go.png')
                    end

                    DM:AddOption('Скопировать SteamID', function()
                        SetClipboardText(pl.steamid)
                    end):SetIcon('icon16/disk.png')

                    DM:AddOption('Открыть профиль', function()
                        gui.OpenURL('https://steamcommunity.com/profiles/' .. steamid64)
                    end):SetIcon('icon16/layout_content.png')

                    DM:Open()
                end

                panel_player.avatar = vgui.Create('AvatarImage', panel_player)
                panel_player.avatar:SetSize(32, 32)
                panel_player.avatar:SetPos(4, 4)
                panel_player.avatar:SetSteamID(steamid64)
            end

            for i, gang_player in pairs(gang_table.players) do
                AddPlayer(gang_player, i) 
            end
        end

        CreateListPlayers()

        FatedGang.ui.OpenGang.panel_description = vgui.Create('DPanel', FatedGang.ui.OpenGang.panel_content)
        FatedGang.ui.OpenGang.panel_description:Dock(RIGHT)
        FatedGang.ui.OpenGang.panel_description:DockMargin(8, 8, 0, 0)
        FatedGang.ui.OpenGang.panel_description:SetWide(FatedGang.ui.OpenGang:GetWide() * 0.25)
        FatedGang.ui.OpenGang.panel_description.Paint = function(_, w, h)
            draw.RoundedBox(8, 0, 0, w, h, color_shadow)
            draw.RoundedBox(8, 0, 0, w - 1, h - 1, Mantle.color.panel[2])
        end

        FatedGang.ui.OpenGang.panel_description.text = vgui.Create('RichText', FatedGang.ui.OpenGang.panel_description)
        FatedGang.ui.OpenGang.panel_description.text:Dock(FILL)
        FatedGang.ui.OpenGang.panel_description.text:DockMargin(8, 8, 8, 8)
        FatedGang.ui.OpenGang.panel_description.text.PerformLayout = function(self)
            self:SetFontInternal('Fated.16')
            self:InsertColorChange(255, 255, 255, 255)
        end
        FatedGang.ui.OpenGang.panel_description.text:AppendText(gang_table.desc)
    end

    local function CreatePageGangList()
        FatedGang.ui.OpenGang.right_content = vgui.Create('DPanel', FatedGang.ui.OpenGang.panel_content)
        FatedGang.ui.OpenGang.right_content:Dock(FILL)
        FatedGang.ui.OpenGang.right_content:DockMargin(6, 0, 0, 0)
        FatedGang.ui.OpenGang.right_content.gang_id = ''
        FatedGang.ui.OpenGang.right_content.Paint = function(self, w, h)
            if self.gang_id == '' then
                draw.SimpleText('Выберете банду...', 'Fated.24', w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            else
                draw.RoundedBox(8, 0, 0, w, h, color_shadow)
                draw.RoundedBox(8, 0, 0, w - 1, h - 1, Mantle.color.panel[2])

                local gang_target = FatedGang.data[self.gang_id]
                
                draw.RoundedBoxEx(8, 0, 0, w - 1, 40, Mantle.color.panel[1], true, true, false, false)
                draw.SimpleText(gang_target.name, 'Fated.26', w * 0.5 - 1, 19, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                draw.RoundedBox(8, 6, 46, w - 13, 80, Mantle.color.panel[3])
                draw.RoundedBox(0, 6, 46 + 8 + 18, w - 13, 2, Mantle.color.panel[2])
                draw.SimpleText('Информация', 'Fated.22', w * 0.5 - 1, 46, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                draw.SimpleText('Босс: ' .. gang_target.players[self.gang_id].nick, 'Fated.20', 13, 77, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                draw.SimpleText('Число участников: ' .. table.Count(gang_target.players), 'Fated.20', 13, 99, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            end
        end

        local function CreateGangVguiInfo()
            FatedGang.ui.OpenGang.right_content.sp_players = vgui.Create('DScrollPanel', FatedGang.ui.OpenGang.right_content)
            Mantle.ui.sp(FatedGang.ui.OpenGang.right_content.sp_players)
            FatedGang.ui.OpenGang.right_content.sp_players:SetSize(170, 264)
            FatedGang.ui.OpenGang.right_content.sp_players:SetPos(6, 132)

            for steamid64, pl in pairs(FatedGang.data[FatedGang.ui.OpenGang.right_content.gang_id].players) do
                local ply_panel = vgui.Create('DButton', FatedGang.ui.OpenGang.right_content.sp_players)
                ply_panel:Dock(TOP)
                ply_panel:SetTall(40)
                ply_panel:SetText('')
                ply_panel.Paint = function(_, w, h)
                    draw.RoundedBox(8, 0, 0, w, h, Mantle.color.panel[1])
                    draw.SimpleText(pl.nick, 'Fated.20', w * 0.5 + 15, h * 0.5 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                ply_panel.DoClick = function()
                    local DM = DermaMenu()

                    DM:AddOption('Скопировать SteamID', function()
                        SetClipboardText(pl.steamid)
                    end):SetIcon('icon16/disk.png')

                    DM:AddOption('Открыть профиль', function()
                        gui.OpenURL('https://steamcommunity.com/profiles/' .. steamid64)
                    end):SetIcon('icon16/layout_content.png')

                    DM:Open()
                end

                ply_panel.avatar = vgui.Create('AvatarImage', ply_panel)
                ply_panel.avatar:SetSize(32, 32)
                ply_panel.avatar:SetPos(4, 4)
                ply_panel.avatar:SetSteamID(steamid64)
            end
        end

        FatedGang.ui.OpenGang.sp_gangs = vgui.Create('DScrollPanel', FatedGang.ui.OpenGang.panel_content)
        Mantle.ui.sp(FatedGang.ui.OpenGang.sp_gangs)
        FatedGang.ui.OpenGang.sp_gangs:Dock(LEFT)
        FatedGang.ui.OpenGang.sp_gangs:SetWide(200)

        for gang_id, gang_table in pairs(FatedGang.data) do
            if gang_id == 'invites' then
                continue
            end

            local panel_gang = vgui.Create('DPanel', FatedGang.ui.OpenGang.sp_gangs)
            panel_gang:Dock(TOP)
            panel_gang:DockMargin(0, 0, 0, 6)
            panel_gang:SetTall(200)
            panel_gang.img_size = 0

            http.DownloadMaterial('https://i.imgur.com/' .. gang_table.img .. '.png', gang_table.img .. '.png', function(gang_icon)
                if IsValid(FatedGang.ui.OpenGang) and IsValid(panel_gang) then
                    panel_gang.Paint = function(self, w, h)
                        draw.RoundedBox(8, 0, 0, w, h, color_shadow)
                        draw.RoundedBox(8, 0, 0, w - 1, h - 1, Mantle.color.panel[1])
        
                        draw.RoundedBoxEx(8, 6, 6, w - 13, 26, gang_table.color, true, true, false, false)
                        draw.RoundedBox(0, 6, 32, w - 13, 4, Mantle.color.panel[3])
                        draw.SimpleText(gang_table.name, 'Fated.22', w * 0.5, 19, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                        draw.RoundedBox(4, w * 0.5 - 58, h * 0.5 - 58, 115, 115, Mantle.color.background)
                        surface.SetDrawColor(color_white)
                        surface.SetMaterial(gang_icon)

                        if FatedGang.ui.OpenGang.right_content.gang_id == gang_id then
                            self.img_size = Lerp(0.05, self.img_size, 40)
                        else
                            self.img_size = Lerp(0.05, self.img_size, 54)
                        end

                        surface.DrawTexturedRect(w * 0.5 - self.img_size + 0.5, h * 0.5 - self.img_size + 0.5, self.img_size * 2, self.img_size * 2)
                    end
                end
            end)

            panel_gang.btn_profile = vgui.Create('DButton', panel_gang)
            Mantle.ui.btn(panel_gang.btn_profile, nil, nil, gang_table.color, nil, true, nil, true)
            panel_gang.btn_profile:Dock(BOTTOM)
            panel_gang.btn_profile:DockMargin(6, 6, 6, 6)
            panel_gang.btn_profile:SetTall(30)
            panel_gang.btn_profile:SetText('Посмотреть инфу')
            panel_gang.btn_profile.DoClick = function()
                Mantle.func.sound()

                FatedGang.ui.OpenGang.right_content.gang_id = gang_id

                CreateGangVguiInfo()
            end
        end
    end

    CreatePageGangList()

    local ConfigPage = {
        {
            name = 'Главная',
            icon = Material('fated_gang/menu/pages/main.png'),
            func = function()
                FatedGang.ui.OpenGang.panel_content:Clear()

                CreatePageMain()
            end
        },
        {
            name = 'Список банд',
            icon = Material('fated_gang/menu/pages/gang_list.png'),
            func = function()
                FatedGang.ui.OpenGang.panel_content:Clear()

                CreatePageGangList()
            end
        },
        {
            name = 'Арены',
            icon = Material('fated_gang/menu/pages/gang_list.png'),
            func = function()
                FatedGang.ui.OpenGang.panel_content:Clear()
            end
        }
    }

    for i, page in pairs(ConfigPage) do
        local button_page = vgui.Create('DButton', FatedGang.ui.OpenGang.panel_left.sp)
        Mantle.ui.btn(button_page, nil, nil, nil, 0, true)
        button_page:Dock(TOP)
        button_page:DockMargin(0, 0, 0, 6)
        button_page:SetTall(36)
        button_page:SetText(page.name)
        button_page.DoClick = function()
            Mantle.func.sound()

            page.func()
        end
        button_page.PaintOver = function()
            surface.SetDrawColor(color_white)
            surface.SetMaterial(page.icon)
            surface.DrawTexturedRect(6, 6, 24, 24)
        end
    end
end

concommand.Add('fated_gang_open', OpenGang)
