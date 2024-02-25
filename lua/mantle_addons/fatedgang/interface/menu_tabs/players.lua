FatedGang.add_tab(1, 'Игроки банды', 'fatedgang/tab_players.png', function(self)
    local gang_table = FatedGang.gangs[FatedGang.menu.active_id]
    local players_table = util.JSONToTable(gang_table.players)
    local info_table = util.JSONToTable(gang_table.info)
    local lp = LocalPlayer()

    if info_table.desc != '' then
        local panel_right = vgui.Create('DPanel', self)
        panel_right:Dock(RIGHT)
        panel_right:DockMargin(8, 0, 0, 0)
        panel_right:SetWide(228)
        panel_right.Paint = function(_, w, h)
            surface.SetDrawColor(Mantle.color.panel_alpha[2])
            surface.DrawOutlinedRect(0, 0, w, h, 2)
        end

        info_table.desc = string.gsub(info_table.desc, '\\n', '\n')

        panel_right.text = vgui.Create('RichText', panel_right)
        panel_right.text:Dock(FILL)
        panel_right.text:DockMargin(6, 8, 6, 8)
        panel_right.text.PerformLayout = function(self)
            self:SetFontInternal('Fated.16')
        end
        panel_right.text:InsertColorChange(255, 255, 255, 255)
        panel_right.text:AppendText(info_table.desc)
    end

    local sp = vgui.Create('DScrollPanel', self)
    Mantle.ui.sp(sp)
    sp:Dock(FILL)

    for pl_steamid, pl_data in pairs(players_table) do
        local pl_rank_table = info_table.ranks[pl_data.rank] and info_table.ranks[pl_data.rank] or info_table.ranks[1]

        local pl_btn = vgui.Create('DButton', sp)
        pl_btn:Dock(TOP)
        pl_btn:DockMargin(0, 0, 0, 8)
        pl_btn:SetTall(40)
        pl_btn:SetText('')

        surface.SetFont('Fated.18')
        local rank_text = pl_rank_table.name

        if pl_data.boss then
            rank_text = rank_text .. ' - Босс'
        end

        local rank_wide = surface.GetTextSize(rank_text)
 
        pl_btn.Paint = function(_, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Mantle.color.panel_alpha[1])

            draw.SimpleText(pl_data.nick, 'Fated.18', 45, h * 0.5 - 1, Mantle.color.gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(pl_data.nick, 'Fated.18', 44, h * 0.5 - 1, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

            draw.RoundedBox(8, w * 0.5 - rank_wide * 0.5 - 8, 6, rank_wide + 16, h - 12, pl_rank_table.col)
            draw.SimpleText(rank_text, 'Fated.18', w * 0.5, h * 0.5 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        pl_btn.DoRightClick = function()
            local DM = Mantle.ui.derma_menu()
            DM:AddOption('Скопировать SteamID', function()
                SetClipboardText(pl_steamid)
            end, 'icon16/disk.png')
            DM:AddOption('Открыть Steam', function()
                gui.OpenURL('https://steamcommunity.com/profiles/' .. pl_data.steamid64)
            end, 'icon16/layout_content.png')
            DM:AddOption('Игровой профиль', function()
                RunConsoleCommand('gameprofile_get_player', pl_steamid)
                
                timer.Simple(0.2, function()
                    FatedGang.menu:Remove()

                    GameProfile.open_profile(true)
                end)
            end, 'icon16/contrast.png')

            if lp:IsSuperAdmin() or pl_gang == id then
                DM:AddSpacer()
                DM:AddOption('Назначить ранг', function()
                    timer.Simple(0.1, function()
                        local RankDM = Mantle.ui.derma_menu()

                        for k, rank in ipairs(info_table.ranks) do
                            RankDM:AddOption(rank.name, function()
                                RunConsoleCommand('fatedgang_command_set_rank', gang_table.id, pl_steamid, k)
                            end)
                        end
                    end)
                end, 'icon16/key.png')
                DM:AddOption('Кикнуть', function()
                    RunConsoleCommand('fatedgang_command_kick', gang_table.id, pl_steamid)
                end, 'icon16/cancel.png')
            end
        end

        pl_btn.avatar = vgui.Create('AvatarImage', pl_btn)
        pl_btn.avatar:Dock(LEFT)
        pl_btn.avatar:DockMargin(4, 4, 4, 4)
        pl_btn.avatar:SetWide(32)
        pl_btn.avatar:SetSteamID(pl_data.steamid64, 128)

        pl_btn.game_profile = vgui.Create('DButton', pl_btn)
        Mantle.ui.btn(pl_btn.game_profile, nil, nil, Color(44, 44, 44), 8, true, Color(34, 34, 34))
        pl_btn.game_profile:Dock(RIGHT)
        pl_btn.game_profile:DockMargin(6, 6, 6, 6)
        pl_btn.game_profile:SetWide(140)
        pl_btn.game_profile:SetText('Игровой профиль')
        pl_btn.game_profile.DoClick = function()
            RunConsoleCommand('gameprofile_get_player', pl_steamid)
            
            timer.Simple(0.2, function()
                FatedGang.menu:Remove()
                
                GameProfile.open_profile(true)
            end)
        end
    end
end)
