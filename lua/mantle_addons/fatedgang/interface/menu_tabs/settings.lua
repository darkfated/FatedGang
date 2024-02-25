FatedGang.add_tab(6, 'Настройки', 'fatedgang/tab_settings.png', function(self)
    local gang_table = FatedGang.gangs[FatedGang.menu.active_id]
    local info_table = util.JSONToTable(gang_table.info)

    local panel_ranks = vgui.Create('DPanel', self)
    panel_ranks:Dock(RIGHT)
    panel_ranks:SetWide(250)
    panel_ranks.Paint = function(_, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Mantle.color.panel_alpha[2])
        draw.SimpleText('Ранги', 'Fated.20', w * 0.5, 8, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    panel_ranks.sp = vgui.Create('DScrollPanel', panel_ranks)
    Mantle.ui.sp(panel_ranks.sp)
    panel_ranks.sp:Dock(FILL)
    panel_ranks.sp:DockMargin(8, 36, 8, 8)

    local function CreateRanks()
        panel_ranks.sp:Clear()

        gang_table = FatedGang.gangs[FatedGang.menu.active_id]
        info_table = util.JSONToTable(gang_table.info)

        for k, rank in ipairs(info_table.ranks) do
            local rank_btn = vgui.Create('DButton', panel_ranks.sp)
            rank_btn:Dock(TOP)
            rank_btn:DockMargin(0, 0, 0, 8)
            rank_btn:SetTall(30)
            rank_btn:SetText('')
            rank_btn.Paint = function(_, w, h)
                draw.RoundedBox(8, 0, 0, w, h, Mantle.color.panel_alpha[1])
                draw.RoundedBox(8, 4, 4, 22, 22, rank.col)
                draw.SimpleText(rank.name, 'Fated.18', w * 0.5, h * 0.5 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            rank_btn.DoRightClick = function()
                local DM = Mantle.ui.derma_menu()
                DM:AddOption('Изменить название', function()
                    Mantle.ui.text_box('Изменить название', 'На какое хочешь изменить?', function(name)
                        RunConsoleCommand('fatedgang_command_rename_rank', gang_table.id, k, name)

                        timer.Simple(0.2, function()
                            CreateRanks()
                        end)
                    end)
                end)
                DM:AddOption('Изменить цвет', function()
                    Mantle.ui.color_picker(function(col)
                        net.Start('FatedGang-ColorRank')
                            net.WriteString(gang_table.id)
                            net.WriteUInt(k, 6)
                            net.WriteColor(col)
                        net.SendToServer()

                        timer.Simple(0.2, function()
                            CreateRanks()
                        end)
                    end)
                end)
                DM:AddOption('Удалить', function()
                    RunConsoleCommand('fatedgang_command_remove_rank', gang_table.id, k)

                    timer.Simple(0.2, function()
                        CreateRanks()
                    end)
                end)
            end
        end
    end

    CreateRanks()

    panel_ranks.btn_create = vgui.Create('DButton', panel_ranks)
    Mantle.ui.btn(panel_ranks.btn_create)
    panel_ranks.btn_create:Dock(BOTTOM)
    panel_ranks.btn_create:SetText('Создать ранг')
    panel_ranks.btn_create.DoClick = function()
        Mantle.ui.text_box('Создать ранг', 'Какое имя желаешь назначить?', function(name)
            RunConsoleCommand('fatedgang_command_add_rank', gang_table.id, name)

            timer.Simple(0.2, function()
                CreateRanks()
            end)
        end)
    end

    local panel_main = vgui.Create('DScrollPanel', self)
    panel_main:Dock(FILL)
    panel_main:DockMargin(0, 0, 8, 0)

    local function focus_text_entry(self)
        self.OnGetFocus = function()
            self:RequestFocus()
    
            FatedGang.menu:SetKeyBoardInputEnabled(true)
        end
        self.OnLoseFocus = function(self)
            FatedGang.menu:SetKeyBoardInputEnabled(false)
        end
    end

    local settings_name, settings_name_back = Mantle.ui.desc_entry(panel_main, 'Название банды:', 'Что-угодно...')
    settings_name:SetValue(info_table.name)
    focus_text_entry(settings_name)

    local settings_color = vgui.Create('DButton', panel_main)
    settings_color:Dock(TOP)
    settings_color:DockMargin(14, 12, 14, 6)
    settings_color:SetTall(36)
    settings_color:SetText('')
    settings_color.col = info_table.col
    settings_color.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Mantle.color.gray)

        if self.col then
            draw.RoundedBox(8, 1, 1, w - 2, h - 2, self.col)
        end

        draw.SimpleText('Отображаемый цвет', 'Fated.16', w * 0.5, h * 0.5 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    settings_color.DoClick = function(self)
        Mantle.ui.color_picker(function(col)
            self.col = col
        end, self.col)
    end

    local settings_desc, settings_desc_back = Mantle.ui.desc_entry(panel_main, 'Описание:', 'Чтобы сделать перенос - напишите \\n')
    settings_desc:SetValue(info_table.desc)
    focus_text_entry(settings_desc)

    local settings_btn_img = vgui.Create('DButton', panel_main)
    Mantle.ui.btn(settings_btn_img)
    settings_btn_img:Dock(TOP)
    settings_btn_img:DockMargin(4, 12, 4, 0)
    settings_btn_img:SetText('Поменять аватарку')
    settings_btn_img.DoClick = function()
        Mantle.ui.text_box('Поменять аватарку', 'Вставьте ссылку на imgur-картинку', function(s)
            s = string.Replace(s, '.jpeg', '.jpg')

            if string.len(s) == 31 then
                s = string.sub(s, 21, 31)
            else
                return
            end

            RunConsoleCommand('fatedgang_command_img', gang_table.id, s)

            timer.Simple(0.2, function()
                FatedGang.menu.create_top_panel(gang_table.id)
            end)
        end)
    end

    local btn_save = vgui.Create('DButton', self)
    Mantle.ui.btn(btn_save)
    btn_save:Dock(BOTTOM)
    btn_save:DockMargin(0, 0, 8, 0)
    btn_save:SetText('Сохранить вышеперечисленные настройки')
    btn_save.DoClick = function()
        net.Start('FatedGang-ChangeInfo')
            net.WriteString(gang_table.id)
            net.WriteString(settings_name:GetValue())
            net.WriteString(settings_desc:GetValue())
            net.WriteTable(settings_color.col)
        net.SendToServer()

        timer.Simple(0.2, function()
            FatedGang.menu.create_top_panel(gang_table.id)

            CreateRanks()
        end)
    end
end)
