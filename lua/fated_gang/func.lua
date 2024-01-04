FatedGang.arenas = {}

function FatedGang.arena_create(id, desc, arena_id, spawns_vector)
    FatedGang.arenas = {
        [id] = {
            id = arena_id,
            description = desc,
            spawns = spawns_vector,
            status = 0,
            gangs = {
                '',
                ''
            },
            time_start = 0,
            players = {
                {},
                {}
            },
            arena_time = 0,
            arena_winner_time = 0,
            round = 0,
            wins = {0, 0},
            alive = {0, 0},
            winner = '',
            loser = {}
        }
    }
end

// Проверка на правильность ссылки
function isValidImageLink(link)
    local pattern = 'https://i%.imgur%.com/.+%.png'

    return string.match(link, pattern) != nil
end

function FatedGang.GanToString(sum)
    local lastDigit = sum % 10
    local lastTwoDigits = sum % 100
    local text

    if lastTwoDigits >= 11 and lastTwoDigits <= 19 then
        text = 'ганов'
    elseif lastDigit == 1 then
        text = 'ган'
    elseif lastDigit >= 2 and lastDigit <= 4 then
        text = 'гана'
    else
        text = 'ганов'
    end

    return sum .. ' ' .. text
end

function FatedGang.initializationSendGangData()
    net.Start('FatedGang-ToClient')

    local compressed_data = util.Compress(util.TableToJSON(FatedGang.data))
    local bytes_amount = #compressed_data

    net.WriteUInt(bytes_amount, 16)
    net.WriteData(compressed_data, bytes_amount)
end
