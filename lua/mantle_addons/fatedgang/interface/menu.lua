function FatedGang.open_menu(standart_id)
    if IsValid(FatedGang.menu) then
        FatedGang.menu:Remove()
    end

    local lp = LocalPlayer()
    local lp_id = lp:GangId()

    if !lp_id then
        RunConsoleCommand('fatedgang_create_menu')

        return
    end

    FatedGang.menu = vgui.Create('DFrame')
    Mantle.ui.frame(FatedGang.menu, 'FatedGang', 900, 550, true)
    FatedGang.menu:Center()
    FatedGang.menu:MakePopup()
    FatedGang.menu:SetKeyBoardInputEnabled(false)
    FatedGang.menu.center_title = 'Меню банд'
    FatedGang.menu.background_alpha = false

    function FatedGang.menu.create_top_panel(id)
        FatedGang.menu.active_id = id

        if !IsValid(FatedGang.menu.top_panel) then
            FatedGang.menu.top_panel = vgui.Create('DPanel', FatedGang.menu)
            FatedGang.menu.top_panel:Dock(TOP)
            FatedGang.menu.top_panel:DockMargin(0, 0, 0, 6)
            FatedGang.menu.top_panel:DockPadding(16, 8, 16, 8)
            FatedGang.menu.top_panel:SetTall(110)
        end

        local gang_table = FatedGang.gangs[id]
        local info_table = util.JSONToTable(gang_table.info)
        local players_table = util.JSONToTable(gang_table.players)

        http.DownloadMaterial('https://i.imgur.com/' .. info_table.img, info_table.img, function(img)
            if IsValid(FatedGang.menu.top_panel) then
                FatedGang.menu.top_panel.img = img
            end
        end)

        local color_shadow = Color(0, 0, 0, 100)
        local color_back = Color(0, 0, 0)
        local players_count = table.Count(players_table)

        local function draw_text(txt, font, x, y, col, align_x, align_y)
            draw.SimpleText(txt, font, x + 1, y + 1, color_back, align_x, align_y)
            draw.SimpleText(txt, font, x, y, col, align_x, align_y)
        end

        FatedGang.menu.top_panel.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, color_black)
            draw.RoundedBox(8, 8, 0, w - 16, h, Mantle.color.panel_alpha[2])
            Mantle.func.gradient(8, h * 0.7, w - 16, h * 0.3, 1, color_shadow)

            draw.RoundedBox(0, w * 0.5 - h * 0.5 + 7, 7, h - 14, h - 14, info_table.col)

            if self.img then
                surface.SetDrawColor(color_white)
                surface.SetMaterial(self.img)
                surface.DrawTexturedRect(w * 0.5 - h * 0.5 + 8, 8, h - 16, h - 16)
            end

            draw_text(info_table.name, 'Fated.22', w * 0.5 - h * 0.5 - 8, h * 0.5 - 1, info_table.col, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            draw_text('Число участников:', 'Fated.20', w * 0.5 + h * 0.5 + 8, 26, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw_text(players_count, 'Fated.20', w * 0.5 + h * 0.5 + 152, 26, Mantle.color.theme, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw_text('Очки банды:', 'Fated.20', w * 0.5 + h * 0.5 + 8, h - 26, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
            draw_text(gang_table.score, 'Fated.20', w * 0.5 + h * 0.5 + 105, h - 26, Mantle.color.theme, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        end

        if IsValid(FatedGang.menu.top_panel.btn_leave) then
            FatedGang.menu.top_panel.btn_leave:Remove()
        end

        if IsValid(FatedGang.menu.top_panel.btn_invite) then
            FatedGang.menu.top_panel.btn_invite:Remove()
        end

        if IsValid(FatedGang.menu.top_panel.btn_remove) then
            FatedGang.menu.top_panel.btn_remove:Remove()
        end

        if IsValid(FatedGang.menu.top_panel.left_gang) then
            FatedGang.menu.top_panel.left_gang:Remove()
        end

        if players_table[lp:SteamID()] then
            FatedGang.menu.top_panel.btn_leave = vgui.Create('DButton', FatedGang.menu.top_panel)
            Mantle.ui.btn(FatedGang.menu.top_panel.btn_leave)
            FatedGang.menu.top_panel.btn_leave:Dock(LEFT)
            FatedGang.menu.top_panel.btn_leave:SetWide(96)
            FatedGang.menu.top_panel.btn_leave:SetText('Покинуть')
            FatedGang.menu.top_panel.btn_leave.DoClick = function()
                Derma_Query('Вы выходите из банды. Точно желаете покинуть?', 'Выйти из банды', 'Да', function()
                    RunConsoleCommand('fatedgang_command_leave')

                    FatedGang.menu:Remove()
                end, 'Отмена')
            end
        elseif lp:IsSuperAdmin() then
            FatedGang.menu.top_panel.btn_remove = vgui.Create('DButton', FatedGang.menu.top_panel)
            Mantle.ui.btn(FatedGang.menu.top_panel.btn_remove)
            FatedGang.menu.top_panel.btn_remove:Dock(LEFT)
            FatedGang.menu.top_panel.btn_remove:SetWide(96)
            FatedGang.menu.top_panel.btn_remove:SetText('Удалить')
            FatedGang.menu.top_panel.btn_remove.DoClick = function()
                Derma_Query('Вы уверены, что хотите удалить банду?', 'Удалить банду', 'Осознаю действие', function()
                    RunConsoleCommand('fatedgang_command_delete', id)

                    FatedGang.menu:Remove()
                end, 'Отмена')
            end
        end

        if id != lp:GangId() then
            FatedGang.menu.top_panel.left_gang = vgui.Create('DButton', FatedGang.menu.top_panel)
            Mantle.ui.btn(FatedGang.menu.top_panel.left_gang)
            FatedGang.menu.top_panel.left_gang:Dock(LEFT)
            FatedGang.menu.top_panel.left_gang:SetWide(96)
            FatedGang.menu.top_panel.left_gang:SetText('Вернуться')
            FatedGang.menu.top_panel.left_gang.DoClick = function()
                FatedGang.menu.create_top_panel(lp:GangId())

                FatedGang.menu.tabs_sp.active_tab = 1
                
                FatedGang.menu.main_panel:Clear()
                FatedGang.menu_tabs[1].func(FatedGang.menu.main_panel)
            end
        end

        if players_table[lp:SteamID()] and players_table[lp:SteamID()].boss or lp:IsSuperAdmin() then
            FatedGang.menu.top_panel.btn_invite = vgui.Create('DButton', FatedGang.menu.top_panel)
            Mantle.ui.btn(FatedGang.menu.top_panel.btn_invite)
            FatedGang.menu.top_panel.btn_invite:Dock(RIGHT)
            FatedGang.menu.top_panel.btn_invite:SetWide(96)
            FatedGang.menu.top_panel.btn_invite:SetText('Пригласить')
            FatedGang.menu.top_panel.btn_invite.DoClick = function()
                Mantle.ui.player_selector(function(pl)
                    RunConsoleCommand('fatedgang_command_invite', pl:SteamID())
                end, function(pl)
                    return pl:GangId()
                end)
            end
        end
    end

    FatedGang.menu.create_top_panel(standart_id)

    FatedGang.menu.main_panel = vgui.Create('DPanel', FatedGang.menu)
    FatedGang.menu.main_panel:Dock(FILL)
    FatedGang.menu.main_panel:DockMargin(0, 0, 2, 2)
    FatedGang.menu.main_panel.Paint = nil

    FatedGang.menu.tabs_sp = vgui.Create('DScrollPanel', FatedGang.menu)
    FatedGang.menu.tabs_sp:Dock(LEFT)
    FatedGang.menu.tabs_sp:DockMargin(0, 0, 6, 0)
    FatedGang.menu.tabs_sp:SetWide(180)
    FatedGang.menu.tabs_sp.active_tab = 1

    local color_btn_hovered = Color(255, 255, 255, 10)

    for i, tab in pairs(FatedGang.menu_tabs) do
        local btn_tab = vgui.Create('DButton', FatedGang.menu.tabs_sp)
        btn_tab:Dock(TOP)
        btn_tab:DockMargin(0, 0, 0, 6)
        btn_tab:SetTall(36)
        btn_tab:SetText('')

        local mat_tab = Material(tab.icon)

        btn_tab.Paint = function(self, w, h)
            if self:IsHovered() then
                draw.RoundedBox(8, 0, 0, w, h, color_btn_hovered)
            end

            surface.SetDrawColor(FatedGang.menu.tabs_sp.active_tab == i and Mantle.color.theme or color_white)
            surface.SetMaterial(mat_tab)
            surface.DrawTexturedRect(4, 4, 28, 28)

            draw.SimpleText(tab.name, 'Fated.20', 42, h * 0.5 - 1, FatedGang.menu.tabs_sp.active_tab == i and Mantle.color.theme or color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        btn_tab.DoClick = function()
            Mantle.func.sound()
            
            FatedGang.menu.main_panel:Clear()

            tab.func(FatedGang.menu.main_panel)

            FatedGang.menu.tabs_sp.active_tab = i
        end
    end

    FatedGang.menu_tabs[1].func(FatedGang.menu.main_panel)
end

concommand.Add('fatedgang_menu', function()
    FatedGang.open_menu(LocalPlayer():GangId())
end)
