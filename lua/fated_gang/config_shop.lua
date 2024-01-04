FatedGang.config.shop_items = {
    ['Оружие'] = {
        icon = 'icon16/gun.png',
        items = {
            ['Colt 1911'] = {
                cost = 460,
                cost_for_use = 5000,
                func = function(pl)
                    pl:Give('tfa_colt1911')
                end
            },
            ['DV.A GUN'] = {
                cost = 500,
                cost_for_use = 5000,
                func = function(pl)
                    pl:Give('tfa_dvaredux_nope')
                end
            },
            ['Люгер'] = {
                cost = 480,
                cost_for_use = 5000,
                func = function(pl)
                    pl:Give('tfa_akos_luger')
                end
            },
            ['Бочи глок'] = {
                cost = 540,
                cost_for_use = 5000,
                func = function(pl)
                    pl:Give('weapon_bocchitheglock')
                end
            },
            ['Заппер'] = {
                cost = 360,
                cost_for_use = 5000,
                func = function(pl)
                    pl:Give('tfa_zapper_orange')
                end
            },
            ['Коса'] = {
                cost = 340,
                cost_for_use = 5000,
                func = function(pl)
                    pl:Give('tfa_osiris')
                end
            },
            ['Нунчаки'] = {
                cost = 260,
                cost_for_use = 5000,
                func = function(pl)
                    pl:Give('tfa_tfre_nunchucks')
                end
            },
            ['Пожарнй топор'] = {
                cost = 240,
                cost_for_use = 5000,
                func = function(pl)
                    pl:Give('tfa_nmrih_fireaxe')
                end
            },
            ['Мачете'] = {
                cost = 300,
                cost_for_use = 5000,
                func = function(pl)
                    pl:Give('tfa_nmrih_machete')
                end
            }
        }
    },
    ['Плюхи'] = {
        icon = 'icon16/rosette.png',
        items = {
            ['Мед. Вейп'] = {
                cost = 300,
                cost_for_use = 5000,
                wep = 'weapon_vape_medicinal'
            },
            ['Энерго Вейп'] = {
                cost = 240,
                cost_for_use = 5000,
                func = function(pl)
                    pl:Give('weapon_vape_tank')
                end
            },
            ['Драк. Вейп'] = {
                cost = 300,
                cost_for_use = 5000,
                func = function(pl)
                    pl:Give('weapon_vape_dragon')
                end
            },
            ['Аптечка'] = {
                cost = 360,
                cost_for_use = 5000,
                func = function(pl)
                    pl:Give('weapon_medkit')
                end
            },
            ['Крылья'] = {
                cost = 360,
                cost_for_use = 10000,
                func = function(pl)
                    pl.gang_fly = true

                    FatedGang.notify(pl, 'Готово. Используйте команду !fly')
                end
            }
        }
    },
    ['Побрякушки'] = {
        icon = 'icon16/hourglass.png',
        items = {
            ['Шепалах'] = {
                cost = 300,
                cost_for_use = 5000,
                func = function(pl)
                    pl:Give('slapper')
                end
            },
            ['Отмычка'] = {
                cost = 300,
                cost_for_use = 5000,
                func = function(pl)
                    pl:Give('lockpick')
                end
            },
            ['Говорилка'] = {
                cost = 1000,
                cost_for_use = 10000,
                func = function(pl)
                    pl.gang_govorilka = true
                end
            },
            ['Не голодай'] = {
                cost = 300,
                cost_for_use = 10000,
                func = function(pl)
                    pl.igs_disable_hunger = true
                end
            },
            ['VIP'] = {
                cost = 400,
                cost_for_use = 25000,
                func = function(pl)
                    if pl:GetUserGroup() != 'user' then
                        pl:SetUserGroup('vip')
                    end
                end
            },
            ['VIP+'] = {
                cost = 700,
                cost_for_use = 26500,
                func = function(pl)
                    if pl:GetUserGroup() != 'user' then
                        pl:SetUserGroup('vip_plus')
                    end
                end
            }
        }
    }
}