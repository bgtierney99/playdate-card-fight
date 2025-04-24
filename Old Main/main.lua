import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"

local gfx <const> = playdate.graphics
local geo <const> = playdate.geometry

local mode = "title"
local game_mode = 1
local player_mode = 1
local game_start = true

local cards = {}

local game_background = gfx.image.new("images/game_background")
local blank_card_image = gfx.image.new("images/blank_card")

cards = {
    {name = "fire", image = gfx.image.new("images/fire_card"), strengths = {"grass", "snow", "metal"}},
    {name = "water", image = gfx.image.new("images/water_card"), strengths = {"fire", "metal", "earth"}},
    {name = "grass", image = gfx.image.new("images/grass_card"), strengths = {"water", "earth", "lightning"}},
    {name = "snow", image = gfx.image.new("images/snow_card"), strengths = {"water", "grass", "lightning"}},
    {name = "earth", image = gfx.image.new("images/earth_card"), strengths = {"fire", "metal", "snow"}},
    {name = "air", image = gfx.image.new("images/air_card"), strengths = {"fire", "grass", "water"}},
    {name = "metal", image = gfx.image.new("images/metal_card"), strengths = {"earth", "snow", "grass"}},
    {name = "lightning", image = gfx.image.new("images/lightning_card"), strengths = {"water", "metal", "air"}},
    {name = "block", image = gfx.image.new("images/block_card"), strengths = {"everything"}}
}

local deck = {}
local discard = {}
local player1_hand = {}
local player2_hand = {}
local player1_card = {}
local player2_card = {}
local active_hand = {}
local non_active_hand = {}
local winner = ""
local active_card_y = 140
local active_card = 1
local player2_index = 1
local active_player = 1
local player1_hp = 100
local player2_hp = 100
local showMenu = false

local title_index = 1
local menu_index = 1

--create deck
for i=1,#cards do
    for j=1,5 do
        table.insert(deck, cards[i])
    end
end

--helper functions
local function shuffleDeck()
    --shuffle deck
    local deck_size = #deck
    for i = deck_size, 2, -1 do
        local j = math.random(i)
        deck[i], deck[j] = deck[j], deck[i]
    end
end

local function resetGame()
    for i = 1, #player1_hand do
        table.insert(deck, player1_hand[i])
    end
    for i = 1, #player2_hand do
        table.insert(deck, player2_hand[i])
    end
    for i = 1, #discard do
        table.insert(deck, discard[i])
    end
    showMenu = false
    player1_hand = {}
    player2_hand = {}
    discard = {}
    player1_hp = 100
    player2_hp = 100
    active_card = 1
    active_player = 1
    gfx.clear()
    game_start = true
end

local function contains(list, x)
	for _, v in pairs(list) do
		if v == x then return true end
	end
	return false
end

local function swapPlayers()
    active_player = (active_player%2)+1
end

local function getplayer2Card()
    --use a block card if you have any
    for i=1, #player2_hand do
        if player2_hand[i].name == "block" then
            return i
        end
    end
    --if this pass fails, either choose a random result or base it on previous results
    return math.random(#player2_hand)
end

--mode-dependent controls functions
local function  title_controls()
    if playdate.buttonJustPressed("up") then
        title_index = ((title_index-2)%2)+1
    elseif playdate.buttonJustPressed("down") then
        title_index = (title_index%2)+1
    end
    if playdate.buttonJustPressed("a") then
        player_mode = title_index
        mode = "menu"
    end
end

local mode_list = {"game", "rps"}

local function menu_controls()
    if playdate.buttonJustPressed("up") then
        menu_index = ((menu_index-2)%2)+1
    elseif playdate.buttonJustPressed("down") then
        menu_index = (menu_index%2)+1
    end
    if playdate.buttonJustPressed("a") then
        game_mode = menu_index
        mode = mode_list[game_mode]
    elseif playdate.buttonJustPressed("b") then
        mode = "title"
    end
end

local function game_controls()
    --move through hand
    if not showMenu then
        if playdate.buttonJustPressed("right") or (playdate.getCrankTicks(5) == 1) then
            active_card = (active_card % 5)+1
        elseif playdate.buttonJustPressed("left") or (playdate.getCrankTicks(5) == -1) then
            active_card = ((active_card-2) % 5)+1
        end
    end
    --bring up strengths menu
    if playdate.buttonJustPressed("up") then
        showMenu = true
    elseif playdate.buttonJustPressed("down") then
        showMenu = false
    end
    if playdate.buttonJustPressed("a") then
        showMenu = false
        if player_mode == 1 then
            player1_card = player1_hand[active_card]
            --remove cards from players
            table.remove(player1_hand, active_card)
            table.remove(player2_hand, player2_index)
            active_card_y = 175
        else
            if active_player == 1 then
                --pick player card
                player1_card = active_hand[active_card]
                table.remove(player1_hand, active_card)
            else
                player2_card = active_hand[active_card]
                table.remove(player2_hand, player2_index)
                active_card_y = 175
            end
            swapPlayers()
        end
    end
    if playdate.buttonJustPressed("b") then
        resetGame()
        mode = "menu"
    end
end

local function rps_controls()
    if playdate.getCrankTicks(3) == -1 then
        print(playdate.getCrankTicks(3))
    end
    if playdate.getCrankTicks(3) == 1 then
        print(playdate.getCrankTicks(3))
    end
    if playdate.buttonJustPressed("right") or (playdate.getCrankTicks(3) == 1) then
        active_card = (active_card % 3)+1
    elseif playdate.buttonJustPressed("left") or (playdate.getCrankTicks(3) == -1) then
        active_card = ((active_card-2) % 3)+1
    end
    if playdate.buttonJustPressed("a") then
        if player_mode == 1 then
            player1_card = player1_hand[active_card]
        else
            if active_player == 1 then
                --pick player card
                player1_card = active_hand[active_card]
            else
                player2_card = active_hand[active_card]
            end
            swapPlayers()
        end
        active_card = 1
    end
    --Testing
    if playdate.buttonJustPressed("b") then
        resetGame()
        mode = "menu"
    end
end

local function end_controls()
    if playdate.buttonJustPressed("a") then
        resetGame()
        mode = "title"
    end
end

--mode-dependent update functions
local function title_update()
    gfx.drawText("Card Fight", 145, 10)
    gfx.drawText("1-Player", 145, 150)
    gfx.drawText("2-Player", 145, 200)
    --draw arrow
    local arrow = gfx.image.new("images/arrow")
    arrow:draw(130, 152+((title_index-1)*50))
end

local function menu_update()
    gfx.drawText("Mode", 145, 10)
    gfx.drawText("Fight", 145, 150)
    gfx.drawText("Rock, Paper, Scissors", 145, 200)
    --draw arrow
    local arrow = gfx.image.new("images/arrow")
    arrow:draw(130, 152+((menu_index-1)*50))
end

local function game_update()
    --background
    game_background:draw(0, 0)
    local hp_bar_image = gfx.image.new("images/hp_bar")
    local hp_val_image = gfx.image.new("images/hp_val")
    local player1_hp_val = gfx.sprite.new(hp_val_image)
    local player2_hp_val = gfx.sprite.new(hp_val_image)
    --drawing HP values
    -- player1_hp_val:setCenter(0, 0)
    -- player2_hp_val:setCenter(0, 0)
    -- player1_hp_val:moveTo(5, 5)
    -- player2_hp_val:moveTo(275, 5)
    -- player1_hp_val:add()
    -- player2_hp_val:add()
    --decrease hp bar display
    -- local player1_hp_calc = 120*(player1_hp/100)
    -- local player2_hp_calc = 120*(player2_hp/100)
    -- player1_hp_val:setClipRect(5, 5, player1_hp_calc, 20)
    -- player2_hp_val:setClipRect(275, 5, player2_hp_calc, 20)
    hp_bar_image:draw(5, 5)
    hp_bar_image:draw(275, 5)
    if game_start then
        shuffleDeck()
        --distribute cards
        for i=1,5 do
            local card_1 = deck[1]
            local card_2 = deck[2]
            table.insert(player1_hand, card_1)
            table.insert(player2_hand, card_2)
            table.remove(deck, 1)
            table.remove(deck, 2)
        end
        game_start = false
    end
    --HP bar logic
    if player1_hp < 0 then player1_hp = 0 end
    if player2_hp < 0 then player2_hp = 0 end
    gfx.drawText("HP: "..tostring(player1_hp), 5, 25)
    gfx.drawText("HP: "..tostring(player2_hp), 275, 25)
    --active hand
    if active_player == 1 then
        active_hand = player1_hand
        non_active_hand = player2_hand
    else
        active_hand = player2_hand
        non_active_hand = player1_hand
    end
    local deck_size = #deck
    local discard_size = #discard
    --draw right side
    if active_player == 1 then
        for i=1, deck_size do
            blank_card_image:draw(323, 110-(i*2)+2)
        end
    else
        for i=1, discard_size do
            discard[i].image:draw(323, 110-(i*2)+2, "flipY")
        end
    end
    --draw left side
    if discard_size > 0 then
        if active_player == 1 then
            for i=1, discard_size do
                discard[i].image:draw(42, 110-(i*2)+2)
            end
        else
            for i=1, deck_size do
                blank_card_image:draw(42, 110-(i*2)+2)
            end
        end
    end
    --draw active hand
    for i=#active_hand, 1, -1 do
        if i ~= active_card then
            active_hand[i].image:draw(171+5*(i-1), 175)
        else
            active_hand[i].image:draw(171+5*(i-1), active_card_y)
        end
    end
    --draw non-active hand
    for i=1,#non_active_hand do
        blank_card_image:draw(171+5*(i-1), 15)
    end
    --info menu
    if showMenu then
        local current_card = active_hand[active_card]
        local info_menu = gfx.image.new("images/info_menu")
        info_menu:draw(135, 10)
        gfx.drawTextAligned("Strengths:", 200, 18, kTextAlignment.center)
        if current_card.name ~= "block" then
            --draw cards
            local str_cards = {}
            for k, v in ipairs(cards) do
                for _, val in ipairs(current_card.strengths) do
                    if v.name == val then
                        table.insert(str_cards, v)
                    end
                end
            end
            local card1 = str_cards[1].image
            local card2 = str_cards[2].image
            local card3 = str_cards[3].image
            card1:draw(141, 36)
            card2:draw(182, 36)
            card3:draw(223, 36)
        else
            gfx.drawTextAligned("Everything", 200, 60, kTextAlignment.center)
        end
    end
    --pick player2 card
    if player_mode == 1 then
        player2_index = getplayer2Card()
        player2_card = player2_hand[player2_index]
    else
        gfx.drawText("Player "..tostring(active_player).."'s Turn", 5, 220)
    end
    --finish turn after player makes selection
    if next(player1_card) ~= nil and next(player2_card) ~= nil then
        --draw selected cards in center of screen
        player1_card.image:drawRotated(150, 100, 90)
        player2_card.image:drawRotated(250, 100, -90)
        --player1 wins
        if contains(player1_card.strengths, player2_card.name) then
            --reduce player2 hp
            player2_hp = player2_hp-20
        --player2 wins
        elseif contains(player2_card.strengths, player1_card.name) then
            --reduce player1 hp
            player1_hp = player1_hp-20
        --cards cancel out
        elseif player1_card.name == player2_card.name then
            --nothing happens
            --TODO: DO SOMETHING OF NOTE HERE LIKE AN ANIMATION OR SOUND!
        --block card used
        elseif player1_card.name == "block" then
            player2_hp = player2_hp - 20
        elseif player2_card.name == "block" then
            player1_hp = player1_hp - 20
        --neutral damage
        else
            --both sides get hit in this case
            player1_hp = player1_hp-10
            player2_hp = player2_hp-10
        end
        playdate.wait(2000)
        --discard cards
        table.insert(discard, player1_card)
        table.insert(discard, player2_card)
        --deck is getting close to empty
        if deck_size <= 2 then
            --add discard pile to deck and shuffle
            for _, val in pairs(discard) do
                table.insert(deck, val)
            end
            discard = {}
            shuffleDeck()
        end
        --remove new cards from deck
        table.remove(deck, 1)
        table.remove(deck, 2)
        --animate cards moving from deck to hands

        --give players new cards
        table.insert(player1_hand, deck[1])
        table.insert(player2_hand, deck[2])
        --reset choice
        player1_card = {}
        player2_card = {}
        active_card_y = 140
    end
    --endgame logic
    if player1_hp == 0 and player2_hp == 0 then
        winner = "It's a tie!"
        mode = "end"
    elseif player1_hp == 0 then
            winner = "Player 2 wins!"
            mode = "end"
    elseif player2_hp == 0 then
            winner = "Player 1 wins!"
            mode = "end"
    end
end

local function rps_update()
    local hp_bar_image = gfx.image.new("images/hp_bar")
    local hp_val_image = gfx.image.new("images/hp_val")
    local player1_hp_val = gfx.sprite.new(hp_val_image)
    local player2_hp_val = gfx.sprite.new(hp_val_image)
    --drawing HP values
    -- player1_hp_val:setCenter(0, 0)
    -- player2_hp_val:setCenter(0, 0)
    -- player1_hp_val:add()
    -- player2_hp_val:add()
    --decrease hp bar display
    -- local player1_hp_calc = 120*(player1_hp/100)
    -- local player2_hp_calc = 120*(player2_hp/100)
    -- player1_hp_val:setClipRect(5, 5, player1_hp_calc, 20)
    -- player2_hp_val:setClipRect(275, 5, player2_hp_calc, 20)
    hp_bar_image:draw(5, 5)
    hp_bar_image:draw(275, 5)
    if game_start then
        shuffleDeck()
        --distribute cards
        for i=1,5 do
            local card_1 = deck[1]
            local card_2 = deck[2]
            table.insert(player1_hand, card_1)
            table.insert(player2_hand, card_2)
            table.remove(deck, 1)
            table.remove(deck, 2)
        end
        game_start = false
    end
    --HP bar logic
    if player1_hp < 0 then player1_hp = 0 end
    if player2_hp < 0 then player2_hp = 0 end
    gfx.drawText("HP: "..tostring(player1_hp), 5, 25)
    gfx.drawText("HP: "..tostring(player2_hp), 275, 25)
    --active hand
    if active_player == 1 then
        active_hand = player1_hand
        non_active_hand = player2_hand
    else
        active_hand = player2_hand
        non_active_hand = player1_hand
    end
    --create each "hand"
    player1_hand = {cards[1], cards[2], cards[3]}
    player2_hand = {cards[1], cards[2], cards[3]}
    --draw card selector
    playdate.graphics.drawRect(141+40*(active_card-1), 174, 38, 52)
    --draw the three cards on both sides
    cards[1].image:draw(142, 175)
    cards[2].image:draw(182, 175)
    cards[3].image:draw(222, 175)

    cards[3].image:draw(142, 15, "flipY")
    cards[2].image:draw(182, 15, "flipY")
    cards[1].image:draw(222, 15, "flipY")
    --pick player2 card
    if player_mode == 1 then
        player2_index = getplayer2Card()
        player2_card = player2_hand[player2_index]
    else
        gfx.drawText("Player "..tostring(active_player).."'s Turn", 5, 220)
    end
    --finish turn after player makes selection
    if next(player1_card) ~= nil and next(player2_card) ~= nil then
        --draw selected cards in center of screen
        player1_card.image:drawRotated(150, 100, 90)
        player2_card.image:drawRotated(250, 100, -90)
        --player1 wins
        if contains(player1_card.strengths, player2_card.name) then
            --reduce player2 hp
            player2_hp = player2_hp-20
        --player2 wins
        elseif contains(player2_card.strengths, player1_card.name) then
            --reduce player1 hp
            player1_hp = player1_hp-20
        --cards cancel out
        elseif player1_card.name == player2_card.name then
            --nothing happens
            --TODO: DO SOMETHING OF NOTE HERE LIKE AN ANIMATION OR SOUND!
        end
        playdate.wait(2000)
        --reset choice
        player1_card = {}
        player2_card = {}
    end
    --endgame logic
    if player1_hp == 0 and player2_hp == 0 then
        winner = "It's a tie!"
        mode = "end"
    elseif player1_hp == 0 then
            winner = "Player 2 wins!"
            mode = "end"
    elseif player2_hp == 0 then
            winner = "Player 1 wins!"
            mode = "end"
    end
end

local function end_update()
    gfx.drawText(winner, 200, 100)
end

local do_update = {}
do_update["title"] = title_update
do_update["menu"] = menu_update
do_update["game"] = game_update
do_update["rps"] = rps_update
do_update["end"] = end_update

local do_controls = {}
do_controls["title"] = title_controls
do_controls["menu"] = menu_controls
do_controls["game"] = game_controls
do_controls["rps"] = rps_controls
do_controls["end"] = end_controls

--handle game logic
function playdate.update()
    --clear the screen after every frame
    gfx.clear()
    --do corresponding mode portion of the update function
    do_update[mode]()
    --controls
    do_controls[mode]()
end