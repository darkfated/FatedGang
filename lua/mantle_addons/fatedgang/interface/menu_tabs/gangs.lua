FatedGang.add_tab(2, 'Все банды', 'fatedgang/tab_gangs.png', function(self)
    local sp = vgui.Create('DScrollPanel', self)
    Mantle.ui.sp(sp)
    sp:Dock(FILL)
    sp:DockMargin(0, 38, 0, 0)

    local function CreateList(search_text)
        sp:Clear()

        for k, gang_table in pairs(FatedGang.gangs) do
            local info_table = util.JSONToTable(gang_table.info)

            if !string.find(string.lower(info_table.name), string.lower(search_text)) then
                continue
            end

            local players_table = util.JSONToTable(gang_table.players)
    
            local gang_btn = vgui.Create('DButton', sp)
            gang_btn:Dock(TOP)
            gang_btn:DockMargin(0, 0, 0, 8)
            gang_btn:SetTall(94)
            gang_btn:SetText('')
    
            http.DownloadMaterial('https://i.imgur.com/' .. info_table.img, info_table.img, function(img)
                if IsValid(gang_btn) then
                    gang_btn.img = img
                end
            end)
    
            local players_count = table.Count(players_table)
    
            gang_btn.Paint = function(self, w, h)
                draw.RoundedBox(8, 0, 12, w, h - 24, Mantle.color.panel_alpha[2])
    
                if self.img then
                    surface.SetDrawColor(color_white)
                    surface.SetMaterial(self.img)
                    surface.DrawTexturedRect(0, 0, h, h)
                end
    
                draw.SimpleText('Название банды', 'Fated.20', h + 14, 26, Mantle.color.gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                draw.SimpleText(info_table.name, 'Fated.18', h + 14, h - 26, info_table.col, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
    
                draw.SimpleText('Кол-во участников', 'Fated.16', w - 16, 26, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
                draw.SimpleText(players_count .. ' из ' .. FatedGang.config.max_players, 'Fated.16', w - 16, h - 26, Mantle.color.theme, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
            end
            gang_btn.DoClick = function()
                if !FatedGang.gangs[k] then
                    return
                end
            
                FatedGang.menu.create_top_panel(gang_table.id)
    
                FatedGang.menu.main_panel:Clear()
                FatedGang.menu_tabs[1].func(FatedGang.menu.main_panel)

                FatedGang.menu.tabs_sp.active_tab = 1
            end
        end
    end

    local panel_search = vgui.Create('DPanel', self)
    panel_search:SetSize(200, 32)
    panel_search:DockMargin(0, 0, 0, 8)
    panel_search.Paint = nil

    local panel_search_text_entry, panel_search_text_entry_back = Mantle.ui.desc_entry(panel_search, '', 'Поиск по названию', true)
    panel_search_text_entry.OnGetFocus = function(self)
        self:RequestFocus()

        FatedGang.menu:SetKeyBoardInputEnabled(true)
    end
    panel_search_text_entry.OnLoseFocus = function(self)
        CreateList(self:GetValue())

        FatedGang.menu:SetKeyBoardInputEnabled(false)
    end

    CreateList('')
end)
