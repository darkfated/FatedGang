local convar_fated_gang_arena_ready = CreateClientConVar('fated_gang_arena_ready', 1, false, false)

FatedGang.ui = FatedGang.ui or {}

local function SortedPairsByNestedValue(tbl, key, reverse)
    local sortedKeys = {}

    for k, v in pairs(tbl) do
        if type(v) == 'table' and v[key] then
            table.insert(sortedKeys, {key = k, value = v[key]})
        end
    end

    table.sort(sortedKeys, function(a, b)
        if reverse then
            return a.value > b.value
        else
            return a.value < b.value
        end
    end)

    local i = 0

    return function()
        i = i + 1
        
        if sortedKeys[i] then
            return sortedKeys[i].key, tbl[sortedKeys[i].key]
        end
    end
end

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

    local gang_invite_table = FatedGang.data.invites[LocalPlayer():SteamID()] or {}

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

        Mantle.ui.text_box('Установить иконку', 'Вставьте ссылку на imgur-картинку', function(img_url)
            local img_code = img_url

            if string.len(img_code) == 31 then
                img_code = string.sub(img_code, 21, 27)
            else
                return
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
        end)
    end

    FatedGang.ui.CreateGang.panel_content.btn_create = vgui.Create('DButton', FatedGang.ui.CreateGang.panel_content)
    Mantle.ui.btn(FatedGang.ui.CreateGang.panel_content.btn_create)
    FatedGang.ui.CreateGang.panel_content.btn_create:Dock(BOTTOM)
    FatedGang.ui.CreateGang.panel_content.btn_create:SetText('КУПИТЬ за ' .. DarkRP.formatMoney(FatedGang.config.cost_create))
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
        RunConsoleCommand('fated_gang_create')

        return
    end

    local gang_table = ply:GetGangTable()

    if table.IsEmpty(gang_table) then
        return
    end

    FatedGang.ui.OpenGang = vgui.Create('DFrame')
    Mantle.ui.frame(FatedGang.ui.OpenGang, 'FatedGang', 782, 440, true)
    FatedGang.ui.OpenGang:Center()
    FatedGang.ui.OpenGang:MakePopup()
    FatedGang.ui.OpenGang:SetKeyBoardInputEnabled(false)
    FatedGang.ui.OpenGang.center_title = gang_table.name

    FatedGang.ui.OpenGang.panel_content = vgui.Create('DPanel', FatedGang.ui.OpenGang)
    FatedGang.ui.OpenGang.panel_content:Dock(FILL)
    FatedGang.ui.OpenGang.panel_content.Paint = nil

    local color_shadow = Color(0, 0, 0, 110)

    FatedGang.ui.OpenGang.panel_left = vgui.Create('DPanel', FatedGang.ui.OpenGang)
    FatedGang.ui.OpenGang.panel_left:Dock(LEFT)
    FatedGang.ui.OpenGang.panel_left:DockMargin(0, 0, 6, 0)
    FatedGang.ui.OpenGang.panel_left:SetWide(170)
    FatedGang.ui.OpenGang.panel_left.Paint = function(_, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Mantle.color.panel_alpha[2])
    end

    local mat_image = Material('fated_gang/menu/icon-set.png')

    FatedGang.ui.OpenGang.panel_left.top = vgui.Create('DPanel', FatedGang.ui.OpenGang.panel_left)
    FatedGang.ui.OpenGang.panel_left.top:Dock(TOP)
    FatedGang.ui.OpenGang.panel_left.top:SetTall(100)
    FatedGang.ui.OpenGang.panel_left.top.Paint = function(self, w, h)
        draw.RoundedBox(4, 8, 8, 84, 84, Mantle.color.panel_alpha[1])

        draw.SimpleText('Участники', 'Fated.14', 130, 10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

        draw.RoundedBox(4, 100, 27, 61, 24, Mantle.color.panel_alpha[1])
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
                net.WriteColor(col, false)
            net.SendToServer()

            gang_table.color = col
        end, gang_table.color)
    end

    FatedGang.ui.OpenGang.panel_left.top.img = vgui.Create('DButton', FatedGang.ui.OpenGang.panel_left.top)
    FatedGang.ui.OpenGang.panel_left.top.img:SetSize(76, 76)
    FatedGang.ui.OpenGang.panel_left.top.img:SetPos(12, 12)
    FatedGang.ui.OpenGang.panel_left.top.img:SetText('')

    local function CreateGangImg(img)
        http.DownloadMaterial('https://i.imgur.com/' .. img .. '.png', img .. '.png', function(gang_icon)
            local colorShadowAlpha = 0

            FatedGang.ui.OpenGang.panel_left.top.img.Paint = function(self, w, h)
                surface.SetDrawColor(color_white)
                surface.SetMaterial(gang_icon)
                surface.DrawTexturedRect(0, 0, w, h)
            
                if self:IsHovered() then
                    colorShadowAlpha = Lerp(FrameTime() * 8, colorShadowAlpha, 200)
            
                    draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, colorShadowAlpha))
            
                    surface.SetDrawColor(color_white)
                    surface.SetMaterial(mat_image)
                    surface.DrawTexturedRect(6, 6, w - 12, h - 12)
                else
                    colorShadowAlpha = 0
                end
            end
        end)
    end

    CreateGangImg(gang_table.img)

    FatedGang.ui.OpenGang.panel_left.top.img.DoClick = function()
        Mantle.func.sound()

        Mantle.ui.text_box('Установить иконку', 'Вставьте ссылку на imgur_картинку', function(img_url)
            local img_code = img_url

            if string.len(img_code) == 31 then
                img_code = string.sub(img_code, 21, 27)
            else
                return
            end

            RunConsoleCommand('fated_gang_command_img', img_code)

            CreateGangImg(img_code)
        end)
    end

    FatedGang.ui.OpenGang.panel_left.sp = vgui.Create('DScrollPanel', FatedGang.ui.OpenGang.panel_left)
    Mantle.ui.sp(FatedGang.ui.OpenGang.panel_left.sp)
    FatedGang.ui.OpenGang.panel_left.sp:Dock(FILL)
    FatedGang.ui.OpenGang.panel_left.sp:DockMargin(0, 0, 1, 0)

    local function CreatePageMain()
        FatedGang.ui.OpenGang.navbar_back = vgui.Create('DPanel', FatedGang.ui.OpenGang.panel_content)
        FatedGang.ui.OpenGang.navbar_back:Dock(TOP)
        FatedGang.ui.OpenGang.navbar_back:SetTall(36)
        FatedGang.ui.OpenGang.navbar_back.Paint = function(_, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Mantle.color.panel_alpha[2])
        end

        FatedGang.ui.OpenGang.navbar = vgui.Create('DHorizontalScroller', FatedGang.ui.OpenGang.navbar_back)
        FatedGang.ui.OpenGang.navbar:Dock(FILL)
        FatedGang.ui.OpenGang.navbar:DockMargin(4, 4, 4, 4)
        FatedGang.ui.OpenGang.navbar:SetOverlap(-4)

        FatedGang.ui.OpenGang.panel_content.panel_main = vgui.Create('DPanel', FatedGang.ui.OpenGang.panel_content)
        FatedGang.ui.OpenGang.panel_content.panel_main:Dock(FILL)
        FatedGang.ui.OpenGang.panel_content.panel_main.Paint = nil

        local function CreateMainContent()
            FatedGang.ui.OpenGang.panel_content.panel_main:Clear()

            FatedGang.ui.OpenGang.list_users_sp = vgui.Create('DScrollPanel', FatedGang.ui.OpenGang.panel_content.panel_main)
            Mantle.ui.sp(FatedGang.ui.OpenGang.list_users_sp)
            FatedGang.ui.OpenGang.list_users_sp:Dock(FILL)
            FatedGang.ui.OpenGang.list_users_sp:DockMargin(0, 6, 0, 0)

            local function CreateListPlayers()
                FatedGang.ui.OpenGang.list_users_sp:Clear()

                local function AddPlayer(pl, steamid)
                    local table_rank = GetGangTableRank(pl.rank, gang_table.steamid)
                    local pl_color = table_rank and table_rank.color or color_black
                    pl_color.a = 120
                    local pl_rank = table_rank and (pl.rank .. (pl.boss and ' (Босс)' or '')) or 'Ранг недействителен!'

                    local panel_player = vgui.Create('DButton', FatedGang.ui.OpenGang.list_users_sp)
                    panel_player:Dock(TOP)
                    panel_player:DockMargin(0, 0, 0, 6)
                    panel_player:SetTall(40)
                    panel_player:SetText('')
                    panel_player.Paint = function(_, w, h)
                        draw.RoundedBox(6, 0, 0, w, h, pl_color)

                        draw.SimpleText(pl.nick, 'Fated.17', 42, h * 0.5 - 1, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        draw.SimpleText(pl_rank, 'Fated.17', w - 6, h * 0.5 - 1, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                    end
                    panel_player.DoClick = function()
                        Mantle.func.sound()

                        local DM = DermaMenu()

                        if LocalPlayer():IsGangBoss() or LocalPlayer():GetGangTableRank().access.rank then
                            local Child, Parent = DM:AddSubMenu('Назначить ранг')
                            Parent:SetIcon('icon16/key.png')
                        
                            for rank_name, rank_table in pairs(gang_table.ranks) do
                                Child:AddOption(rank_name, function()
                                    gang_table.players[steamid].rank = rank_name
                                    
                                    RunConsoleCommand('fated_gang_command_rank', steamid, rank_name)

                                    CreateListPlayers()
                                end):SetTextColor(rank_table.color)
                            end
                        end

                        if LocalPlayer():IsGangBoss() or LocalPlayer():GetGangTableRank().access.kick then
                            DM:AddOption('Выгнать из банды', function()
                                RunConsoleCommand('fated_gang_command_kick', steamid)
                            end):SetIcon('icon16/cancel.png')
                        end

                        if LocalPlayer():IsGangBoss() then
                            DM:AddOption('Передать владельца', function()
                                RunConsoleCommand('fated_gang_command_boss', steamid)
                            end):SetIcon('icon16/user_go.png')
                        end

                        DM:AddOption('Скопировать SteamID', function()
                            SetClipboardText(steamid)
                        end):SetIcon('icon16/disk.png')

                        DM:AddOption('Открыть профиль', function()
                            gui.OpenURL('https://steamcommunity.com/profiles/' .. pl.steamid64)
                        end):SetIcon('icon16/layout_content.png')

                        DM:Open()
                    end

                    panel_player.avatar = vgui.Create('AvatarImage', panel_player)
                    panel_player.avatar:SetSize(32, 32)
                    panel_player.avatar:SetPos(4, 4)
                    panel_player.avatar:SetSteamID(pl.steamid64)
                end

                for i, gang_player in pairs(gang_table.players) do
                    AddPlayer(gang_player, i) 
                end
            end

            CreateListPlayers()

            FatedGang.ui.OpenGang.panel_description = vgui.Create('DPanel', FatedGang.ui.OpenGang.panel_content.panel_main)
            FatedGang.ui.OpenGang.panel_description:Dock(RIGHT)
            FatedGang.ui.OpenGang.panel_description:DockMargin(6, 6, 0, 0)
            FatedGang.ui.OpenGang.panel_description:SetWide(250)
            FatedGang.ui.OpenGang.panel_description.Paint = function(_, w, h)
                draw.RoundedBox(6, 0, 0, w, h, Mantle.color.panel_alpha[2])
                
                draw.RoundedBoxEx(6, 0, 0, w, 30, gang_table.color, true, true, false, false)
                draw.SimpleText('Описание банды', 'Fated.20', w * 0.5, 14, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            FatedGang.ui.OpenGang.panel_description.text = vgui.Create('RichText', FatedGang.ui.OpenGang.panel_description)
            FatedGang.ui.OpenGang.panel_description.text:Dock(FILL)
            FatedGang.ui.OpenGang.panel_description.text:DockMargin(6, 36, 6, 6)
            FatedGang.ui.OpenGang.panel_description.text.PerformLayout = function(self)
                self:SetFontInternal('Fated.16')
                self:InsertColorChange(255, 255, 255, 255)
            end
            FatedGang.ui.OpenGang.panel_description.text:AppendText(gang_table.desc)
        end

        local list_gang_commands = {}

        if LocalPlayer():IsGangBoss() or LocalPlayer():GetGangTableRank().access.edit then
            table.insert(list_gang_commands, {
                name = 'Настройки банды',
                icon = Material('fated_gang/menu/edit.png'),
                color = Color(30, 68, 37),
                func = function()
                    FatedGang.ui.OpenGang:SetKeyBoardInputEnabled(true)

                    FatedGang.ui.OpenGang.panel_content.panel_main:Clear()

                    FatedGang.ui.OpenGang.panel_content.panel_main.content = vgui.Create('DPanel', FatedGang.ui.OpenGang.panel_content.panel_main)
                    FatedGang.ui.OpenGang.panel_content.panel_main.content:Dock(FILL)
                    FatedGang.ui.OpenGang.panel_content.panel_main.content:DockMargin(0, 4, 0, 0)
                    FatedGang.ui.OpenGang.panel_content.panel_main.content.Paint = nil

                    FatedGang.ui.OpenGang.panel_content.panel_main.content.left = vgui.Create('DPanel', FatedGang.ui.OpenGang.panel_content.panel_main.content)
                    FatedGang.ui.OpenGang.panel_content.panel_main.content.left:Dock(LEFT)
                    FatedGang.ui.OpenGang.panel_content.panel_main.content.left:SetWide(FatedGang.ui.OpenGang.panel_content.panel_main:GetWide() * 0.5 - 16)
                    FatedGang.ui.OpenGang.panel_content.panel_main.content.left.Paint = nil

                    local entry_name = Mantle.ui.desc_entry(FatedGang.ui.OpenGang.panel_content.panel_main.content.left, 'Название:', 'Клуб весёлых и находчивых')
                    entry_name:SetValue(gang_table.name)
                    local entry_desc = Mantle.ui.desc_entry(FatedGang.ui.OpenGang.panel_content.panel_main.content.left, 'Описание:', 'Здесь очень весело.')
                    entry_desc:SetValue(gang_table.desc)
                    entry_desc:SetMultiline(true)
                    entry_desc:SetTall(120)

                    FatedGang.ui.OpenGang.panel_content.panel_main.content.right = vgui.Create('DPanel', FatedGang.ui.OpenGang.panel_content.panel_main.content)
                    FatedGang.ui.OpenGang.panel_content.panel_main.content.right:Dock(RIGHT)
                    FatedGang.ui.OpenGang.panel_content.panel_main.content.right:DockMargin(0, 2, 0, 6)
                    FatedGang.ui.OpenGang.panel_content.panel_main.content.right:DockPadding(4, 4, 4, 4)
                    FatedGang.ui.OpenGang.panel_content.panel_main.content.right:SetWide(FatedGang.ui.OpenGang.panel_content.panel_main:GetWide() * 0.5 - 16)
                    FatedGang.ui.OpenGang.panel_content.panel_main.content.right.Paint = function(_, w, h)
                        draw.RoundedBox(6, 0, 0, w, h, Mantle.color.panel_alpha[2])
                    end

                    local GangRanks = {}

                    for rank_name_save, rank_table_save in pairs(LocalPlayer():GetGangTable().ranks) do
                        GangRanks[rank_name_save] = rank_table_save
                    end

                    FatedGang.ui.OpenGang.panel_content.panel_main.content.right.sp = vgui.Create('DScrollPanel', FatedGang.ui.OpenGang.panel_content.panel_main.content.right)
                    Mantle.ui.sp(FatedGang.ui.OpenGang.panel_content.panel_main.content.right.sp)
                    FatedGang.ui.OpenGang.panel_content.panel_main.content.right.sp:Dock(FILL)
                    FatedGang.ui.OpenGang.panel_content.panel_main.content.right.sp:DockMargin(0, 6, 0, 0)
                    
                    local function BuildRanks()
                        FatedGang.ui.OpenGang.panel_content.panel_main.content.right.sp:Clear()

                        for rank_name, _ in pairs(GangRanks) do
                            if rank_name == 'Участник' then
                                continue
                            end

                            local rank_panel = vgui.Create('DButton', FatedGang.ui.OpenGang.panel_content.panel_main.content.right.sp)
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
                                local DM = Mantle.ui.derma_menu()
                                DM:AddOption('Изменить названия', function()
                                    Mantle.ui.text_box('Изменить название', 'Какое название ранга желаете?', function(s)
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
                                    end)
                                end, 'icon16/text_signature.png')
                                DM:AddOption('Изменить цвет', function()
                                    Mantle.ui.color_picker(function(col)
                                        GangRanks[rank_panel.name].color = col
                                    end, GangRanks[rank_panel.name].color)
                                end, 'icon16/color_swatch.png')
                                DM:AddOption('Возможность приглашать', function()
                                    GangRanks[rank_panel.name].access.invite = !GangRanks[rank_panel.name].access.invite
                                end, GangRanks[rank_panel.name].access.invite and 'icon16/bullet_green.png' or 'icon16/bullet_red.png')
                                DM:AddOption('Возможность выгонять', function()
                                    GangRanks[rank_panel.name].access.kick = !GangRanks[rank_panel.name].access.kick
                                end, GangRanks[rank_panel.name].access.kick and 'icon16/bullet_green.png' or 'icon16/bullet_red.png')
                                DM:AddOption('Возможность давать ранг', function()
                                    GangRanks[rank_panel.name].access.rank = !GangRanks[rank_panel.name].access.rank
                                end, GangRanks[rank_panel.name].access.rank and 'icon16/bullet_green.png' or 'icon16/bullet_red.png')
                                DM:AddOption('Удалить ранг', function()
                                    rank_panel:Remove()

                                    GangRanks[rank_panel.name] = nil
                                end, 'icon16/delete.png')
                            end

                            rank_panel.Paint = function(self, w, h)
                                draw.RoundedBox(4, 0, 0, w, h, Mantle.color.panel_alpha[1])
                                draw.RoundedBox(4, 4, 4, h - 8, h - 8, GangRanks[rank_panel.name].color)

                                draw.SimpleText(self.name, 'Fated.16', w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                            end
                        end
                    end

                    BuildRanks()

                    FatedGang.ui.OpenGang.panel_content.panel_main.content.right.btn_create = vgui.Create('DButton', FatedGang.ui.OpenGang.panel_content.panel_main.content.right)
                    Mantle.ui.btn(FatedGang.ui.OpenGang.panel_content.panel_main.content.right.btn_create)
                    FatedGang.ui.OpenGang.panel_content.panel_main.content.right.btn_create:Dock(TOP)
                    FatedGang.ui.OpenGang.panel_content.panel_main.content.right.btn_create:SetTall(30)
                    FatedGang.ui.OpenGang.panel_content.panel_main.content.right.btn_create:SetText('Создать ранг')
                    FatedGang.ui.OpenGang.panel_content.panel_main.content.right.btn_create.DoClick = function()
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

                    FatedGang.ui.OpenGang.panel_content.panel_main.footer = vgui.Create('DPanel', FatedGang.ui.OpenGang.panel_content.panel_main)
                    FatedGang.ui.OpenGang.panel_content.panel_main.footer:Dock(BOTTOM)
                    FatedGang.ui.OpenGang.panel_content.panel_main.footer:DockPadding(4, 4, 4, 4)
                    FatedGang.ui.OpenGang.panel_content.panel_main.footer:SetTall(50)
                    FatedGang.ui.OpenGang.panel_content.panel_main.footer.Paint = function(_, w, h)
                        draw.RoundedBox(6, 0, 0, w, h, Mantle.color.panel_alpha[2])
                    end

                    FatedGang.ui.OpenGang.panel_content.panel_main.footer.btn_left = vgui.Create('DButton', FatedGang.ui.OpenGang.panel_content.panel_main.footer)
                    Mantle.ui.btn(FatedGang.ui.OpenGang.panel_content.panel_main.footer.btn_left)
                    FatedGang.ui.OpenGang.panel_content.panel_main.footer.btn_left:Dock(LEFT)
                    FatedGang.ui.OpenGang.panel_content.panel_main.footer.btn_left:SetWide(250)
                    FatedGang.ui.OpenGang.panel_content.panel_main.footer.btn_left:SetText('Сохранить')
                    FatedGang.ui.OpenGang.panel_content.panel_main.footer.btn_left.DoClick = function()
                        FatedGang.ui.OpenGang:Remove()
                        
                        net.Start('FatedGang-ChangeGang')
                            net.WriteString(entry_name:GetValue())
                            net.WriteString(entry_desc:GetValue())
                            net.WriteTable(GangRanks)
                        net.SendToServer()
                    end

                    FatedGang.ui.OpenGang.panel_content.panel_main.footer.btn_right = vgui.Create('DButton', FatedGang.ui.OpenGang.panel_content.panel_main.footer)
                    Mantle.ui.btn(FatedGang.ui.OpenGang.panel_content.panel_main.footer.btn_right)
                    FatedGang.ui.OpenGang.panel_content.panel_main.footer.btn_right:Dock(RIGHT)
                    FatedGang.ui.OpenGang.panel_content.panel_main.footer.btn_right:SetWide(250)
                    FatedGang.ui.OpenGang.panel_content.panel_main.footer.btn_right:SetText('Отмена')
                    FatedGang.ui.OpenGang.panel_content.panel_main.footer.btn_right.DoClick = function()
                        FatedGang.ui.OpenGang:SetKeyBoardInputEnabled(false)

                        CreateMainContent()
                    end
                end
            })
        end

        CreateMainContent()

        if LocalPlayer():IsGangBoss() or LocalPlayer():GetGangTableRank().access.invite then
            table.insert(list_gang_commands, {
                name = 'Пригласить',
                icon = Material('fated_gang/menu/member.png'),
                color = Color(45, 67, 103),
                func = function()
                    Mantle.ui.player_selector(function(pl)
                        RunConsoleCommand('fated_gang_command_invite', pl:SteamID())
                    end, function(pl)
                        return pl:GetGangId() != '0'
                    end)
                end
            })
        end

        table.insert(list_gang_commands, {
            name = 'Покинуть',
            icon = Material('fated_gang/menu/leave.png'),
            color = Color(116, 39, 39),
            func = function()
                RunConsoleCommand('fated_gang_command_leave')

                FatedGang.ui.OpenGang:Remove()
            end
        })

        for i, command in pairs(list_gang_commands) do
            surface.SetFont('Fated.20')

            local color_btn_gang_command = Color(222, 222, 222)

            local btn_gang_command = vgui.Create('DButton', FatedGang.ui.OpenGang.navbar)
            btn_gang_command:SetWide(surface.GetTextSize(command.name) + 12)
            btn_gang_command:SetText('')
            btn_gang_command.Paint = function(self, w, h)
                draw.RoundedBox(6, 0, 0, w, h, self:IsHovered() and color_btn_gang_command or command.color)
                draw.SimpleText(command.name, 'Fated.20', w * 0.5, h * 0.5 - 1, self:IsHovered() and command.color or color_btn_gang_command, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            btn_gang_command.DoClick = function()
                Mantle.func.sound()

                command.func()
            end

            FatedGang.ui.OpenGang.navbar:AddPanel(btn_gang_command)
        end
    end

    local function CreatePageGangList()
        FatedGang.ui.OpenGang.tab_information = vgui.Create('DPanel', FatedGang.ui.OpenGang.panel_content)
        FatedGang.ui.OpenGang.tab_information:Dock(FILL)
        FatedGang.ui.OpenGang.tab_information.Paint = nil
        
        FatedGang.ui.OpenGang.tab_information.left_content = vgui.Create('DPanel', FatedGang.ui.OpenGang.tab_information)
        FatedGang.ui.OpenGang.tab_information.left_content:Dock(FILL)
        FatedGang.ui.OpenGang.tab_information.left_content:DockMargin(0, 0, 6, 0)
        FatedGang.ui.OpenGang.tab_information.left_content.gang_id = ''
        FatedGang.ui.OpenGang.tab_information.left_content.Paint = nil

        FatedGang.ui.OpenGang.tab_information.right_content = vgui.Create('DPanel', FatedGang.ui.OpenGang.tab_information)
        FatedGang.ui.OpenGang.tab_information.right_content:Dock(RIGHT)
        FatedGang.ui.OpenGang.tab_information.right_content:SetWide(250)
        FatedGang.ui.OpenGang.tab_information.right_content.Paint = nil

        local function CreateGangInfo(id)
            FatedGang.ui.OpenGang.tab_information.left_content.gang_id = id

            FatedGang.ui.OpenGang.tab_information.right_content:Clear()

            local gang_target = FatedGang.data[id]

            FatedGang.ui.OpenGang.tab_information.right_content.panel_info = vgui.Create('DPanel', FatedGang.ui.OpenGang.tab_information.right_content)
            FatedGang.ui.OpenGang.tab_information.right_content.panel_info:Dock(TOP)
            FatedGang.ui.OpenGang.tab_information.right_content.panel_info:SetTall(148)
            FatedGang.ui.OpenGang.tab_information.right_content.panel_info.Paint = function(_, w, h)
                draw.RoundedBox(6, 0, 0, w, h, Mantle.color.panel_alpha[2])

                draw.RoundedBoxEx(6, 0, 0, w - 1, 26, gang_target.color, true, true, false, false)
                draw.SimpleText(gang_target.name, 'Fated.20', w * 0.5 - 1, 12, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            local tabl_info = {
                'Босс: ' .. gang_target.players[id].nick,
                'Число участников: ' .. table.Count(gang_target.players),
                'Всего рангов: ' .. table.Count(gang_target.ranks),
                'Побед на арене: ' .. gang_target.arena_wins,
                'Лучший на арене: ' .. 'скоро',
                'Всего убийств на арене: ' .. gang_target.arena_kills,
                'Баланс: ' .. FatedGang.GanToString(gang_target.balance)
            }

            FatedGang.ui.OpenGang.tab_information.right_content.panel_info.sp = vgui.Create('DScrollPanel', FatedGang.ui.OpenGang.tab_information.right_content.panel_info)
            Mantle.ui.sp(FatedGang.ui.OpenGang.tab_information.right_content.panel_info.sp)
            FatedGang.ui.OpenGang.tab_information.right_content.panel_info.sp:Dock(FILL)
            FatedGang.ui.OpenGang.tab_information.right_content.panel_info.sp:DockMargin(6, 32, 6, 6)

            for _, txt in ipairs(tabl_info) do
                local panel_info = vgui.Create('DPanel', FatedGang.ui.OpenGang.tab_information.right_content.panel_info.sp)
                panel_info:Dock(TOP)
                panel_info:DockMargin(0, 0, 0, 6)
                panel_info:SetTall(17)
                panel_info.Paint = function(_, w, h)
                    draw.SimpleText(txt, 'Fated.17', 0, h * 0.5 - 1, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end
            end

            FatedGang.ui.OpenGang.tab_information.right_content.panel_players = vgui.Create('DPanel', FatedGang.ui.OpenGang.tab_information.right_content)
            FatedGang.ui.OpenGang.tab_information.right_content.panel_players:Dock(FILL)
            FatedGang.ui.OpenGang.tab_information.right_content.panel_players:DockMargin(0, 6, 0, 0)
            FatedGang.ui.OpenGang.tab_information.right_content.panel_players.Paint = function(_, w, h)
                draw.RoundedBox(6, 0, 0, w, h, Mantle.color.panel_alpha[2])
            end

            FatedGang.ui.OpenGang.tab_information.right_content.panel_players.sp = vgui.Create('DScrollPanel', FatedGang.ui.OpenGang.tab_information.right_content.panel_players)
            Mantle.ui.sp(FatedGang.ui.OpenGang.tab_information.right_content.panel_players.sp)
            FatedGang.ui.OpenGang.tab_information.right_content.panel_players.sp:Dock(FILL)
            FatedGang.ui.OpenGang.tab_information.right_content.panel_players.sp:DockMargin(6, 6, 6, 6)

            for pl_steamid, pl_data in pairs(gang_target.players) do
                local btn_pl = vgui.Create('DButton', FatedGang.ui.OpenGang.tab_information.right_content.panel_players.sp)
                btn_pl:Dock(TOP)
                btn_pl:DockMargin(0, 0, 0, 6)
                btn_pl:SetTall(40)
                btn_pl:SetText('')
                btn_pl.DoClick = function()
                    local DM = Mantle.ui.derma_menu()
                    DM:AddOption('Скопировать SteamID', function()
                        SetClipboardText(pl_steamid)
                    end, 'icon16/disk.png')
                    DM:AddOption('Открыть профиль', function()
                        gui.OpenURL('https://steamcommunity.com/profiles/' .. pl_data.steamid64)
                    end, 'icon16/layout_content.png')
                end

                local table_rank = GetGangTableRank(pl_data.rank, gang_target.steamid)
                local pl_color = table_rank and table_rank.color or color_black
                pl_color.a = 120
                local pl_rank = table_rank and (pl_data.rank .. (pl_data.boss and ' (Босс)' or '')) or 'Ранг недействителен!'

                btn_pl.Paint = function(_, w, h)
                    draw.RoundedBox(0, 0, 0, w - 6, h, Mantle.color.panel_alpha[3])
                    draw.SimpleText(pl_data.nick, 'Fated.15', 44, 3, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                    
                    draw.RoundedBoxEx(4, w - 6, 0, 6, h, pl_color, false, true, false, true)
                    draw.SimpleText(pl_rank, 'Fated.15', 44, h - 3, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
                end

                btn_pl.avatar = vgui.Create('AvatarImage', btn_pl)
                btn_pl.avatar:SetSize(40, 40)
                btn_pl.avatar:SetSteamID(pl_data.steamid64, 64)
            end
        end

        FatedGang.ui.OpenGang.tab_information.left_content.sp_gangs = vgui.Create('DScrollPanel', FatedGang.ui.OpenGang.tab_information.left_content)
        Mantle.ui.sp(FatedGang.ui.OpenGang.tab_information.left_content.sp_gangs)
        FatedGang.ui.OpenGang.tab_information.left_content.sp_gangs:Dock(FILL)
        FatedGang.ui.OpenGang.tab_information.left_content.sp_gangs:DockMargin(0, 6, 0, 0)

        local function CreateGangList(search_text)
            FatedGang.ui.OpenGang.tab_information.left_content.sp_gangs:Clear()

            for gang_id, gang_table in pairs(FatedGang.data) do
                if gang_id == 'invites' then
                    continue
                end

                if !string.find(string.lower(gang_table.name), string.lower(search_text), 1, true) then
                    continue
                end

                local panel_gang = vgui.Create('DPanel', FatedGang.ui.OpenGang.tab_information.left_content.sp_gangs)
                panel_gang:Dock(TOP)
                panel_gang:DockMargin(0, 0, 0, 6)
                panel_gang:SetTall(100)
                panel_gang.img_size = 0
                panel_gang.Paint = function(self, w, h)
                    if self:IsVisible() and !self.mat then
                        http.DownloadMaterial('https://i.imgur.com/' .. gang_table.img .. '.png', gang_table.img .. '.png', function(gang_icon)
                            self.mat = gang_icon
                        end)
                    end

                    draw.RoundedBox(6, 0, 0, w, h, Mantle.color.panel_alpha[2])
                    draw.RoundedBox(4, 6, 6, 50, 50, gang_table.color, true, false, true, false)

                    if self.mat then
                        surface.SetDrawColor(color_white)
                        surface.SetMaterial(self.mat)
                        
                        if FatedGang.ui.OpenGang.tab_information.left_content.gang_id == gang_id then
                            self.img_size = Lerp(0.1, self.img_size, 46)
                        else
                            self.img_size = Lerp(0.1, self.img_size, 38)
                        end
                        
                        surface.DrawTexturedRect(32 - self.img_size * 0.5, 32 - self.img_size * 0.5, self.img_size - 1, self.img_size - 1)
                    end

                    draw.SimpleText(gang_table.name, 'Fated.17', 64, 12, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                    draw.SimpleText('Кол-во: ' .. table.Count(gang_table.players), 'Fated.17', 64, 50, Mantle.color.theme, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
                end

                if LocalPlayer():IsSuperAdmin() then
                    panel_gang.btn_admin = vgui.Create('DButton', panel_gang)
                    Mantle.ui.btn(panel_gang.btn_admin)
                    panel_gang.btn_admin:SetSize(60, 52)
                    panel_gang.btn_admin:SetPos(260, 6)
                    panel_gang.btn_admin:SetText('Админ')
                    panel_gang.btn_admin.DoClick = function()
                        local DM = Mantle.ui.derma_menu()
                        DM:AddOption('Сменить название банды', function()
                            Mantle.ui.text_box('Сменить название банды', 'На какое желаете?', function(s)
                                RunConsoleCommand('fated_gang_admin_command_name', gang_id, s)

                                timer.Simple(0.5, function()
                                    FatedGang.ui.OpenGang.panel_content:Clear()

                                    CreatePageGangList()
                                end)
                            end)
                        end, 'icon16/table.png')
                        DM:AddOption('Удалить банду', function()
                            RunConsoleCommand('fated_gang_admin_command_delete', gang_id)

                            if gang_id != LocalPlayer():GetGangId() then
                                timer.Simple(0.5, function()
                                    FatedGang.ui.OpenGang.panel_content:Clear()

                                    CreatePageGangList()
                                end)
                            else
                                FatedGang.ui.OpenGang:Remove()
                            end
                        end, 'icon16/delete.png')
                        DM:AddOption('Удалить иконку', function()
                            RunConsoleCommand('fated_gang_admin_command_delete_img', gang_id)

                            timer.Simple(0.5, function()
                                FatedGang.ui.OpenGang.panel_content:Clear()

                                CreatePageGangList()
                            end)
                        end, 'icon16/picture.png')
                        DM:AddOption('Выдать ганов', function()
                            Mantle.ui.text_box('Выдать ганов', 'Сколько желаешь?', function(gan)
                                RunConsoleCommand('fated_gang_admin_command_give_gan', gang_id, gan)

                                timer.Simple(0.5, function()
                                    FatedGang.ui.OpenGang.panel_content:Clear()
    
                                    CreatePageGangList()
                                end)
                            end)
                        end, 'icon16/sport_tennis.png')
                    end
                end
                
                panel_gang.btn_profile = vgui.Create('DButton', panel_gang)
                Mantle.ui.btn(panel_gang.btn_profile, nil, nil, gang_table.color, nil, true, nil, true)
                panel_gang.btn_profile:Dock(BOTTOM)
                panel_gang.btn_profile:DockMargin(6, 6, 6, 6)
                panel_gang.btn_profile:SetTall(30)
                panel_gang.btn_profile:SetText('Посмотреть инфу')
                panel_gang.btn_profile.DoClick = function()
                    Mantle.func.sound()

                    CreateGangInfo(gang_id)
                end
            end
        end

        CreateGangList('')

        FatedGang.ui.OpenGang.tab_information.left_content.seacrh, FatedGang.ui.OpenGang.tab_information.left_content.seacrh_back = Mantle.ui.desc_entry(FatedGang.ui.OpenGang.tab_information.left_content, '', 'Поиск', true)
        FatedGang.ui.OpenGang.tab_information.left_content.seacrh_back:DockMargin(0, 0, 0, 0)
        FatedGang.ui.OpenGang.tab_information.left_content.seacrh:DockMargin(0, 0, 0, 0)
        FatedGang.ui.OpenGang.tab_information.left_content.seacrh.OnGetFocus = function()
            FatedGang.ui.OpenGang.tab_information.left_content.seacrh:RequestFocus()
            
            FatedGang.ui.OpenGang:SetKeyBoardInputEnabled(true)
        end
        FatedGang.ui.OpenGang.tab_information.left_content.seacrh.OnLoseFocus = function(self)
            CreateGangList(self:GetValue())

            FatedGang.ui.OpenGang:SetKeyBoardInputEnabled(false)
        end
    end

    local function CreatePageArena()
        FatedGang.ui.OpenGang.panel_content.left_panel = vgui.Create('DPanel', FatedGang.ui.OpenGang.panel_content)
        FatedGang.ui.OpenGang.panel_content.left_panel:Dock(FILL)
        FatedGang.ui.OpenGang.panel_content.left_panel.Paint = function(_, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Mantle.color.panel_alpha[2])

            draw.RoundedBoxEx(6, 0, 0, w, 30, gang_table.color, true, true, false, false)
            draw.SimpleText('Список доступных арен', 'Fated.20', w * 0.5, 14, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        FatedGang.ui.OpenGang.panel_content.left_panel.sp = vgui.Create('DScrollPanel', FatedGang.ui.OpenGang.panel_content)
        Mantle.ui.sp(FatedGang.ui.OpenGang.panel_content.left_panel.sp)
        FatedGang.ui.OpenGang.panel_content.left_panel.sp:Dock(FILL)
        FatedGang.ui.OpenGang.panel_content.left_panel.sp:DockMargin(6, 36, 6, 6)

        FatedGang.ui.OpenGang.panel_content.right_panel = vgui.Create('DPanel', FatedGang.ui.OpenGang.panel_content)
        FatedGang.ui.OpenGang.panel_content.right_panel:Dock(RIGHT)
        FatedGang.ui.OpenGang.panel_content.right_panel:DockMargin(6, 0, 0, 0)
        FatedGang.ui.OpenGang.panel_content.right_panel:SetWide(250)
        FatedGang.ui.OpenGang.panel_content.right_panel.Paint = nil

        FatedGang.ui.OpenGang.panel_content.checkbox_ready, FatedGang.ui.OpenGang.panel_content.checkbox_ready_btn = Mantle.ui.checkbox(FatedGang.ui.OpenGang.panel_content, 'Автоматическое сражение', 'fated_gang_arena_ready')
        FatedGang.ui.OpenGang.panel_content.checkbox_ready:SetTall(30)
        FatedGang.ui.OpenGang.panel_content.checkbox_ready:DockMargin(0, 0, 0, 6)
        FatedGang.ui.OpenGang.panel_content.checkbox_ready_btn.DoClick = function()
            RunConsoleCommand('fated_gang_arena_ready', FatedGang.ui.OpenGang.panel_content.checkbox_ready_btn.enabled and 0 or 1)
            RunConsoleCommand('fated_gang_command_arena_ready')

            FatedGang.ui.OpenGang.panel_content.checkbox_ready_btn.enabled = !FatedGang.ui.OpenGang.panel_content.checkbox_ready_btn.enabled
        end

        local colors_status = {
            [0] = Mantle.color.button,
            [1] = Color(172, 101, 38),
            [2] = Color(45, 98, 158),
            [3] = Color(158, 54, 54),
            [4] = Color(40, 38, 38)
        }

        local texts_status = {
            [0] = 'Не захвачено',
            [1] = 'Ожидание',
            [2] = 'Набор участников',
            [3] = 'Идёт захват',
            [4] = 'Захвачено'
        }

        local function CreateArenaInfo(arena_id)
            FatedGang.ui.OpenGang.panel_content.right_panel:Clear()

            FatedGang.ui.OpenGang.panel_content.right_panel.panel = vgui.Create('DPanel', FatedGang.ui.OpenGang.panel_content.right_panel)
            FatedGang.ui.OpenGang.panel_content.right_panel.panel:Dock(FILL)
            FatedGang.ui.OpenGang.panel_content.right_panel.panel.Paint = function(self, w, h)
                local arena_table = FatedGang.arenas[arena_id]

                draw.RoundedBoxEx(6, 0, 0, w, h, Mantle.color.panel_alpha[2], true, true, false, false)

                draw.RoundedBoxEx(6, 0, 0, w, 30, colors_status[arena_table.status], true, true, false, false)
                draw.SimpleText(arena_id, 'Fated.20', w * 0.5, 14, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                draw.RoundedBox(6, 6, 36, w - 12, 155, Mantle.color.panel_alpha[1])
                draw.RoundedBox(6, 6, 197, w - 12, 155, Mantle.color.panel_alpha[1])

                if arena_table.status == 4 and arena_table.winner != '' then
                    local gang_winner = FatedGang.data[arena_table.winner]

                    draw.SimpleText('Владелец: ' .. gang_winner.name, 'Fated.20', w * 0.5, h * 0.5 - 80, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                else
                    local function CreateGangInfo(id, x, y)
                        local gang_current_table = FatedGang.data[arena_table.gangs[id]]

                        if !gang_current_table then
                            return
                        end

                        draw.RoundedBoxEx(6, x, y, w - 12, 76, gang_current_table.color, true, true, false, false)

                        http.DownloadMaterial('https://i.imgur.com/' .. gang_current_table.img .. '.png', gang_current_table.img .. '.png', function(gang_icon)
                            surface.SetDrawColor(color_white)
                            surface.SetMaterial(gang_icon)
                            surface.DrawTexturedRect(x + 6, y + 6, 64, 64)
                        end)

                        draw.SimpleText(id == 1 and 'Первая банда' or 'Вторая банда', 'Fated.20', x + 76, y + 27, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        draw.SimpleText(gang_current_table.name, 'Fated.17', x + 76, y + 47, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                        draw.SimpleText('Готовых участников: ' .. table.Count(arena_table.players[id]), 'Fated.15', w * 0.5, y + 112, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                    
                    if arena_table.gangs[1] != '' then
                        CreateGangInfo(1, 6, 36)
                    end
            
                    if arena_table.gangs[2] != '' then
                        CreateGangInfo(2, 6, 197)
                    end
                end
            end

            FatedGang.ui.OpenGang.panel_content.right_panel.btn = vgui.Create('DButton', FatedGang.ui.OpenGang.panel_content.right_panel)
            Mantle.ui.btn(FatedGang.ui.OpenGang.panel_content.right_panel.btn)
            FatedGang.ui.OpenGang.panel_content.right_panel.btn:Dock(BOTTOM)
            FatedGang.ui.OpenGang.panel_content.right_panel.btn:DockMargin(0, 6, 0, 0)
            FatedGang.ui.OpenGang.panel_content.right_panel.btn:SetTall(40)
            FatedGang.ui.OpenGang.panel_content.right_panel.btn:SetText('')
            FatedGang.ui.OpenGang.panel_content.right_panel.btn.PaintOver = function(_, w, h)
                local arena_table = FatedGang.arenas[arena_id]

                draw.SimpleText(texts_status[arena_table.status], 'Fated.20', w * 0.5, h * 0.5 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            FatedGang.ui.OpenGang.panel_content.right_panel.btn.DoClick = function()
                net.Start('FatedGang-SelectArena')
                    net.WriteString(arena_id)
                net.SendToServer()
            end
        end

        for arena_id, arena_table in pairs(FatedGang.arenas) do
            local btn_arena = vgui.Create('DButton', FatedGang.ui.OpenGang.panel_content.left_panel.sp)
            btn_arena:Dock(TOP)
            btn_arena:DockMargin(0, 0, 0, 6)
            btn_arena:SetTall(40)
            btn_arena:SetText('')
            btn_arena.DoClick = function()
                Mantle.func.sound()

                CreateArenaInfo(arena_id)
            end

            btn_arena.Paint = function(_, w, h)
                local arena_table = FatedGang.arenas[arena_id]
                local arena_color = colors_status[arena_table.status]
                arena_color.a = 210

                draw.RoundedBox(6, 0, 0, w, h, arena_color)
                draw.SimpleText(arena_id, 'Fated.17', w * 0.5, h * 0.5 - 10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText(arena_table.description, 'Fated.15', w * 0.5, h * 0.5 + 8, Mantle.color.gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
    end

    local function CreatePageShop()
        FatedGang.ui.OpenGang.panel_content.panel_right = vgui.Create('DPanel', FatedGang.ui.OpenGang.panel_content)
        FatedGang.ui.OpenGang.panel_content.panel_right:Dock(RIGHT)
        FatedGang.ui.OpenGang.panel_content.panel_right:SetWide(250)
        FatedGang.ui.OpenGang.panel_content.panel_right.Paint = function(_, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Mantle.color.panel_alpha[2])

            draw.RoundedBoxEx(6, 0, 0, w, 30, gang_table.color, true, true, false, false)
            draw.SimpleText('Инвентарь', 'Fated.20', w * 0.5, 14, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        FatedGang.ui.OpenGang.panel_content.panel_right.sp = vgui.Create('DScrollPanel', FatedGang.ui.OpenGang.panel_content.panel_right)
        Mantle.ui.sp(FatedGang.ui.OpenGang.panel_content.panel_right.sp)
        FatedGang.ui.OpenGang.panel_content.panel_right.sp:Dock(FILL)
        FatedGang.ui.OpenGang.panel_content.panel_right.sp:DockMargin(6, 36, 6, 6)

        for inv_item in pairs(gang_table.inventory) do
            local panel_inv_item = vgui.Create('DButton', FatedGang.ui.OpenGang.panel_content.panel_right.sp)
            panel_inv_item:Dock(TOP)
            panel_inv_item:DockMargin(0, 0, 0, 6)
            panel_inv_item:SetTall(30)
            panel_inv_item:SetText('')
            panel_inv_item.Paint = function(_, w, h)
                draw.RoundedBox(6, 0, 2, w, h - 4, Mantle.color.panel_alpha[1])
                draw.SimpleText(inv_item, 'Fated.15', 10, h * 0.5 - 1, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            for _, cat_data in pairs(FatedGang.config.shop_items) do
                local item_tabl = cat_data.items[inv_item]
        
                if !item_tabl then
                    continue
                end
            
                panel_inv_item.btn = vgui.Create('DButton', panel_inv_item)
                panel_inv_item.btn:Dock(RIGHT)
                panel_inv_item.btn:SetWide(70)
                panel_inv_item.btn:SetText('')

                local text_cost = DarkRP.formatMoney(item_tabl.cost_for_use)

                panel_inv_item.btn.Paint = function(self, w, h)
                    draw.RoundedBox(6, 0, 0, w, h, self:IsHovered() and Mantle.color.panel[3] or Mantle.color.panel_alpha[3])
    
                    draw.SimpleText(text_cost, 'Fated.15', w * 0.5, h * 0.5 - 1, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                panel_inv_item.btn.DoClick = function()
                    RunConsoleCommand('fated_gang_command_use', inv_item)
                end
        
                break
            end
        end

        FatedGang.ui.OpenGang.panel_content.panel_top = vgui.Create('DPanel', FatedGang.ui.OpenGang.panel_content)
        FatedGang.ui.OpenGang.panel_content.panel_top:Dock(TOP)
        FatedGang.ui.OpenGang.panel_content.panel_top:DockMargin(0, 0, 6, 0)
        FatedGang.ui.OpenGang.panel_content.panel_top:SetTall(36)
        FatedGang.ui.OpenGang.panel_content.panel_top.Paint = function(_, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Mantle.color.panel_alpha[2])
            draw.SimpleText('Баланс банды: ' .. FatedGang.GanToString(gang_table.balance), 'Fated.20', w * 0.5, h * 0.5 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        FatedGang.ui.OpenGang.panel_content.panel_tabs = Mantle.ui.panel_tabs(FatedGang.ui.OpenGang.panel_content)
        FatedGang.ui.OpenGang.panel_content.panel_tabs:DockMargin(0, 6, 6, 0)

        for cat, cat_tabl in pairs(FatedGang.config.shop_items) do
            local panel_cat = vgui.Create('DScrollPanel')
            Mantle.ui.sp(panel_cat)

            local item_size = 330 / 2

            panel_cat.grid = vgui.Create('DGrid', panel_cat)
            panel_cat.grid:Dock(TOP)
            panel_cat.grid:SetCols(2)
            panel_cat.grid:SetColWide(item_size)
            panel_cat.grid:SetRowHeight(item_size * 0.4)
            
            for item, item_tabl in pairs(cat_tabl.items) do
                local panel_item = vgui.Create('DPanel')
                panel_item:SetPos(3, 3, 3, 3)
                panel_item:SetSize(item_size - 6, item_size * 0.4 - 6)
                panel_item:SetText('')

                local gradientWidth = 0

                panel_item.Paint = function(self, w, h)
                    draw.RoundedBox(6, 0, 0, w, h, Mantle.color.theme)
                
                    if self.btn:IsHovered() then
                        gradientWidth = Lerp(FrameTime() * 5, gradientWidth, w)
 
                        Mantle.func.gradient(w - gradientWidth + 1, 0, gradientWidth, h, 4, color_shadow)
                    else
                        gradientWidth = 0
                    end

                    draw.SimpleText(item, 'Fated.15', 8, 11, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                    draw.SimpleText(FatedGang.GanToString(item_tabl.cost), 'Fated.14', 8, h - 11, Mantle.color.gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
                end
        
                panel_cat.grid:AddItem(panel_item)

                panel_item.btn = vgui.Create('DButton', panel_item)
                Mantle.ui.btn(panel_item.btn)
                panel_item.btn:Dock(RIGHT)
                panel_item.btn:DockMargin(4, 32, 4, 4)
                panel_item.btn:SetWide(48)
                panel_item.btn:SetText('Купить')
                panel_item.btn.btn_font = 'Fated.14'
                panel_item.btn.DoClick = function()
                    Mantle.ui.text_box('Покупка ' .. item, 'Введи название банды для подтверждения', function(s)
                        if string.lower(s) != string.lower(gang_table.name) then
                            return
                        end

                        RunConsoleCommand('fated_gang_command_buy', item)

                        timer.Simple(0.5, function()
                            gang_table = ply:GetGangTable()
                            FatedGang.ui.OpenGang.panel_content:Clear()

                            CreatePageShop()
                        end)
                    end)
                end
            end
            
            FatedGang.ui.OpenGang.panel_content.panel_tabs:AddTab(cat, panel_cat, cat_tabl.icon)
        end

        FatedGang.ui.OpenGang.panel_content.panel_tabs:ActiveTab(FatedGang.config.shop_items[1])
    end

    local function CreatePageLeaders()
        FatedGang.ui.OpenGang.panel_content.panel_tabs = Mantle.ui.panel_tabs(FatedGang.ui.OpenGang.panel_content)

        FatedGang.ui.OpenGang.panel_content.btn_reset = vgui.Create('DButton', FatedGang.ui.OpenGang.panel_content)
        Mantle.ui.btn(FatedGang.ui.OpenGang.panel_content.btn_reset)
        FatedGang.ui.OpenGang.panel_content.btn_reset:SetSize(60, 20)
        FatedGang.ui.OpenGang.panel_content.btn_reset:SetPos(FatedGang.ui.OpenGang.panel_content:GetWide() - 66, 2)
        FatedGang.ui.OpenGang.panel_content.btn_reset:SetText('Очистка')
        FatedGang.ui.OpenGang.panel_content.btn_reset.DoClick = function()
            local DM = Mantle.ui.derma_menu()
            DM:AddOption('Сбросить статистику всем', function()
                RunConsoleCommand('fated_gang_admin_command_reset_stat')
            end)
            DM:AddOption('Сбросить инвентарь всем', function()
                RunConsoleCommand('fated_gang_admin_command_reset_inv')
            end)
        end

        local function CreateList(panel, seacrh_type)
            panel.sp = vgui.Create('DScrollPanel', panel)
            panel.sp:Dock(FILL)
            panel.sp:DockMargin(6, 6, 6, 6)

            local place = 1
            
            for _, place_gang in SortedPairsByMemberValue(FatedGang.data, seacrh_type, true) do
                if _ == 'invites' then
                    continue
                end

                local panel_gang = vgui.Create('DPanel', panel.sp)
                panel_gang:Dock(TOP)
                panel_gang:DockMargin(0, 0, 0, 6)
                panel_gang:SetTall(50)
                panel_gang.place = place

                http.DownloadMaterial('https://i.imgur.com/' .. place_gang.img .. '.png', place_gang.img .. '.png', function(gang_icon)
                    panel_gang.mat = gang_icon
                end)

                panel_gang.Paint = function(self, w, h)
                    draw.RoundedBox(6, 0, 0, w, h, Mantle.color.panel_alpha[1])
                    draw.SimpleText(place_gang.name, 'Fated.17', 56, h * 0.5 - 1, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText(place_gang[seacrh_type], 'Fated.17', w * 0.5, h * 0.5 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                    if self:IsVisible() and self.mat then
                        surface.SetDrawColor(color_white)
                        surface.SetMaterial(self.mat)
                        surface.DrawTexturedRect(0, 0, 50, 50)
                    end

                    draw.RoundedBoxEx(4, w - 60, 0, 60, h, place_gang.color, false, true, false, true)
                    draw.SimpleText(self.place, 'Fated.20', w - 29, h * 0.5 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end

                place = place + 1
            end
        end

        FatedGang.ui.OpenGang.panel_content.tab_win = vgui.Create('DPanel')
        FatedGang.ui.OpenGang.panel_content.tab_win.Paint = function(_, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Mantle.color.panel_alpha[2])
        end

        CreateList(FatedGang.ui.OpenGang.panel_content.tab_win, 'arena_wins')

        FatedGang.ui.OpenGang.panel_content.panel_tabs:AddTab('Топ по победам', FatedGang.ui.OpenGang.panel_content.tab_win)
        FatedGang.ui.OpenGang.panel_content.panel_tabs:ActiveTab('Топ по победам')

        FatedGang.ui.OpenGang.panel_content.tab_balance = vgui.Create('DPanel')
        FatedGang.ui.OpenGang.panel_content.tab_balance.Paint = function(_, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Mantle.color.panel_alpha[2])
        end

        CreateList(FatedGang.ui.OpenGang.panel_content.tab_balance, 'balance')

        FatedGang.ui.OpenGang.panel_content.panel_tabs:AddTab('Топ по балансу', FatedGang.ui.OpenGang.panel_content.tab_balance)
    end

    CreatePageMain()

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
    }

    local ConfigArenaPage = {
        {
            name = 'Магазин',
            icon = Material('fated_gang/menu/pages/shop.png'),
            func = function()
                FatedGang.ui.OpenGang.panel_content:Clear()

                CreatePageShop()
            end,
            dop_text = 'Новое',
            block = false
        },
        {
            name = 'Арены',
            icon = Material('fated_gang/menu/pages/arena.png'),
            func = function()
                FatedGang.ui.OpenGang.panel_content:Clear()

                CreatePageArena()
            end,
            dop_text = 'Новое',
            block = false
        },
        {
            name = 'Лидеры',
            icon = Material('fated_gang/menu/pages/top.png'),
            func = function()
                FatedGang.ui.OpenGang.panel_content:Clear()

                CreatePageLeaders()
            end,
            dop_text = 'Бета',
            block = false
        }
    }

    if FatedGang.config.arena_enabled then
        table.Add(ConfigPage, ConfigArenaPage)
    end

    for i, page in pairs(ConfigPage) do
        local button_page = vgui.Create('DButton', FatedGang.ui.OpenGang.panel_left.sp)
        button_page:Dock(TOP)
        button_page:DockMargin(4, 0, 4, 8)
        button_page:SetTall(36)
        button_page:SetText('')
        button_page.DoClick = function()
            Mantle.func.sound()

            if page.block then
                return
            end

            FatedGang.ui.OpenGang:SetKeyBoardInputEnabled(false)

            page.func()
        end
        button_page.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Mantle.color.panel_alpha[1])

            if self:IsHovered() then
                draw.RoundedBox(6, 0, 0, w, h, color_shadow)
            end

            surface.SetDrawColor(color_white)
            surface.SetMaterial(page.icon)
            surface.DrawTexturedRect(6, 6, 24, 24)

            draw.SimpleText(page.name, 'Fated.17', w * 0.5, h * 0.5 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            if page.dop_text then
                draw.SimpleText(page.dop_text, 'Fated.13', w - 4, h - 4, Color(255, 77, 77), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
            end
        end
    end
end

concommand.Add('fated_gang_open', OpenGang)
