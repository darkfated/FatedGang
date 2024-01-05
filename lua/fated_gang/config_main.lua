// Цена создания банды
FatedGang.config.cost_create = 5000000

// Включены ли арены или нет (арены - место сражений банд)
FatedGang.config.arena_enabled = false

if !FatedGang.config.arena_enabled then
    return
end

// Список арен на примере gm_construct
function FatedGang.CreateArenaList()
    FatedGang.arena_create('Водный пейзаж', 'Неплохая арена с видом на водоём.', 'water', {
        [1] = {
            {Vector(675, 4313, 32)},
            {Vector(1109, 4318, 32)}
        },
        [2] = {
            {Vector(1649, 6246, 32)},
            {Vector(970, 6219, 32)}
        }
    })
end

FatedGang.CreateArenaList()

// Сколько времени происходит набор участников до захвата
FatedGang.config.arena_waiting_time = 10

// Доступное оружие на арене
FatedGang.config.arena_weapons = {
    'weapon_shotgun',
    'weapon_ar2',
    'weapon_357'
}

// Модели для арены
FatedGang.config.arena_models = {
    'models/player/dod_american.mdl',
    'models/player/hostage/hostage_02.mdl'
}

// Количество раундов на захвате
FatedGang.config.arena_rounds = 3

// Длительность раундов
FatedGang.config.arena_round_time = 60

// Точки возраждения для тех, кто умер в раунде (находится в месте ожидания)
FatedGang.config.arena_spawns_waiting = {
    Vector(-1838, -2540, 3040),
    Vector(-1835, -3023, 3040),
    Vector(-2765, -3024, 3040),
    Vector(-2771, -2545, 3040)
}
