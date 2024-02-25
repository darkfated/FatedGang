function FatedGang.add_tab(id, name, icon, func)
    FatedGang.menu_tabs[id] = {
        name = name,
        icon = icon,
        func = func
    }
end
