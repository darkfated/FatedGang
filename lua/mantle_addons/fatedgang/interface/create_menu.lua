local function Create()
    if IsValid(FatedGang.create_menu) then
        FatedGang.create_menu:Remove()
    end

    if LocalPlayer():GangId() then
        chat.AddText('Перед созданием банды, выйди из нынешней.')

        return
    end

    FatedGang.create_menu = vgui.Create('DFrame')
    Mantle.ui.frame(FatedGang.create_menu, 'FatedGang', 350, 210, true)
    FatedGang.create_menu:Center()
    FatedGang.create_menu:MakePopup()
    FatedGang.create_menu.center_title = 'Создание банды'

    local name_entry = Mantle.ui.desc_entry(FatedGang.create_menu, 'Название', 'Например: КотоGang')

    local btn_color = vgui.Create('DButton', FatedGang.create_menu)
    btn_color:Dock(TOP)
    btn_color:DockMargin(14, 12, 14, 0)
    btn_color:SetTall(36)
    btn_color:SetText('')
    btn_color.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Mantle.color.gray)

        if self.col then
            draw.RoundedBox(8, 1, 1, w - 2, h - 2, self.col)
        end

        draw.SimpleText('Отображаемый цвет', 'Fated.16', w * 0.5, h * 0.5 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    btn_color.DoClick = function(self)
        Mantle.ui.color_picker(function(col)
            self.col = col
        end, self.col)
    end

    local text_info = vgui.Create('DPanel', FatedGang.create_menu)
    text_info:Dock(TOP)
    text_info:DockMargin(0, 10, 0, 0)
    text_info:SetTall(16)
    text_info.Paint = function(_, w, h)
        draw.SimpleText('Остальное настраивается в меню самой банды', 'Fated.16', w * 0.5, h * 0.5 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local btn_create = vgui.Create('DButton', FatedGang.create_menu)
    Mantle.ui.btn(btn_create)
    btn_create:Dock(TOP)
    btn_create:DockMargin(14, 8, 14, 0)
    btn_create:SetTall(36)
    btn_create:SetText('Создать за ' .. DarkRP.formatMoney(FatedGang.config.create_cost))
    btn_create.DoClick = function()
        net.Start('FatedGang-Create')
            net.WriteString(name_entry:GetValue())
            net.WriteColor(btn_color.col and btn_color.col or Color(25, 25, 25))
        net.SendToServer()

        FatedGang.create_menu:Remove()
    end
end

concommand.Add('fatedgang_create_menu', Create)
