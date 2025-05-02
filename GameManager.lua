class('GameManager').extends()

local player_count = 1

function GameManager:setPlayerCount(count)
    player_count = count
    print("New player count: ", player_count)
end