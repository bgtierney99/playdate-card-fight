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
math.randomseed(playdate.getSecondsSinceEpoch())

local cards = {}

--images
local arrow = gfx.image.new("images/arrow")
local game_background = gfx.image.new("images/game_background")
local blank_card_image = gfx.image.new("images/blank_card")
local hp_bar_image = gfx.image.new("images/hp_bar")
local hp_val_image = gfx.image.new("images/hp_val")

--hp variables
local player1_hp = 100
local player2_hp = 100
local player1_hp_val = gfx.sprite.new(hp_val_image)
local player2_hp_val = gfx.sprite.new(hp_val_image)
--positioning hp bars for drawing later
player1_hp_val:setCenter(0, 0)
player2_hp_val:setCenter(0, 0)
player1_hp_val:moveTo(5, 5)
player2_hp_val:moveTo(275, 5)

cards = {
    {name = "fire", image = "images/fire_card", strengths = {"grass", "snow", "metal"}},
    {name = "water", image = "images/water_card", strengths = {"fire", "metal", "earth"}},
    {name = "grass", image = "images/grass_card", strengths = {"water", "earth", "lightning"}},
    {name = "snow", image = "images/snow_card", strengths = {"water", "grass", "lightning"}},
    {name = "earth", image = "images/earth_card", strengths = {"fire", "metal", "snow"}},
    {name = "air", image = "images/air_card", strengths = {"fire", "grass", "water"}},
    {name = "metal", image = "images/metal_card", strengths = {"earth", "snow", "grass"}},
    {name = "lightning", image = "images/lightning_card", strengths = {"water", "metal", "air"}},
    {name = "block", image = "images/block_card", strengths = {"everything"}}
}

--miscellaneous variables
local card_list = {}
local deck = {}
local discard = {}
local player1_hand = {}
local player2_hand = {}
local player1_card = {}
local player2_card = {}
local player1_history = {}
local active_hand = {}
local non_active_hand = {}
local winner = ""
local active_card_y = 140
local active_card = 1
local player2_index = 1
local active_player = 1
local showMenu = false
local winning_card = {}
local turn_num = 1
local title_index = 1
local menu_index = 1

--mode sprites
local title_sprite = gfx.sprite.new()
title_sprite:setSize(400, 240)
title_sprite:moveTo(0, 0)
function title_sprite:draw(x, y)
    gfx.setClipRect(x, y, 400, 240)
    arrow:draw(x+130, y+152+((title_index-1)*50))
    gfx.drawText("Card Fight", x+145, y+10)
    gfx.drawText("1-Player", x+145, y+150)
    gfx.drawText("2-Player", x+145, y+200)
    gfx.clearClipRect()
end

local menu_sprite = gfx.sprite.new()
menu_sprite:setSize(400, 240)
menu_sprite:moveTo(0, 0)
function menu_sprite:draw(x, y)
    gfx.setClipRect(x, y, 400, 240)
    arrow:draw(x+130, y+152+((menu_index-1)*50))
    gfx.drawText("Mode", x+145, y+10)
    gfx.drawText("Fight", x+145, y+150)
    gfx.drawText("Rock, Paper, Scissors", x+145, y+200)
    gfx.clearClipRect()
end

local game_sprite = gfx.sprite.new()
game_sprite:setSize(400, 240)
game_sprite:moveTo(0, 0)
function game_sprite:draw(x, y)
    gfx.setClipRect(x, y, 400, 240)
    game_background:draw(x, y)
    if player_mode == 2 then
        gfx.drawText("Player "..tostring(active_player).."'s Turn", x+5, y+220)
    end
    --hp bars
    hp_bar_image:draw(x+5, y+5)
    hp_bar_image:draw(x+275, y+5)
    --hp value text
    gfx.drawText("HP: "..tostring(player1_hp), x+5, y+25)
    gfx.drawText("HP: "..tostring(player2_hp), x+275, y+25)
    --info menu
    if showMenu then
        local current_card = active_hand[active_card]
        local info_menu = gfx.image.new("images/info_menu")
        info_menu:draw(x+135, y+10)
        gfx.drawTextAligned("Strengths:", x+200, y+18, kTextAlignment.center)
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
            local card1 = gfx.image.new(str_cards[1].image)
            local card2 = gfx.image.new(str_cards[2].image)
            local card3 = gfx.image.new(str_cards[3].image)
            card1:draw(x+141, y+36)
            card2:draw(x+182, y+36)
            card3:draw(x+223, y+36)
        else
            gfx.drawTextAligned("Everything", x+200, y+60, kTextAlignment.center)
        end
    end
    gfx.clearClipRect()
end

local rps_sprite = gfx.sprite.new()
rps_sprite:setSize(400, 240)
rps_sprite:moveTo(0, 0)
function rps_sprite:draw(x, y)
    gfx.setClipRect(x, y, 400, 240)
    --hp bars
    hp_bar_image:draw(x+5, y+5)
    hp_bar_image:draw(x+275, y+5)
    --hp value text
    gfx.drawText("HP: "..tostring(player1_hp), x+5, y+25)
    gfx.drawText("HP: "..tostring(player2_hp), x+275, y+25)
    --draw card selector
    gfx.drawRect(x+141+40*(active_card-1), y+174, 38, 52)
    if player_mode == 2 then
        gfx.drawText("Player "..tostring(active_player).."'s Turn", x+5, y+220)
    end
    gfx.clearClipRect()
end

local end_sprite = gfx.sprite.new()
end_sprite:setSize(400, 240)
end_sprite:moveTo(0, 0)
function end_sprite:draw(x, y)
    gfx.setClipRect(x, y, 400, 240)
    gfx.drawText(winner, x+200, y+100)
    gfx.clearClipRect()
end

function table.copy(first_table)
    local new_table = {}
    for k, v in pairs(first_table) do
        if v.type == table then
            table.copy(v)
        end
        new_table[k] = v
    end
    return new_table
end

local function createDeck()
    --create deck
    for i=1,#cards do
        for j=1,5 do
            local new_card = {}
            new_card = table.copy(cards[i])
            table.insert(deck, new_card)
        end
    end
    --create sprites for each card
    for i=1, #deck do
        local new_image = gfx.image.new(deck[i].image)
        deck[i].sprite = gfx.sprite.new(new_image)
        deck[i].id = i
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
    showMenu = false
    deck = {}
    discard = {}
    player1_history = {}
    winning_card = {}
    player1_hp = 100
    player2_hp = 100
    active_card = 1
    active_player = 1
    end_sprite:remove()
    gfx.clear()
    game_start = true
end

local function getCardIDs(old_table)
    local id_list = {}
    for i=1, #old_table do
        table.insert(id_list, old_table[i].id)
    end
    return id_list
end

local function contains(list, x)
	for _, v in pairs(list) do
		if v == x then return true end
	end
	return false
end

local function getplayer2Card()
    local chance = math.random(1, 3)
    --no block cards
    for i=1, #player2_hand do
        --use a block card if any are on-hand
        if player2_hand[i].name == "block" then
            return i
        end
        --2/3 priority to base the next choice on previous results
        if chance%3 == 1 then
            --no matter who won the last round, always pick the option that beats whatever won previously
            if contains(player2_hand[i].strengths, winning_card.name) then
                return i
            end
        end
        --1/3 priority to base the next choice on previous player 1 choices
        if #player1_history > 0 then
            --generate a random number that falls somewhere in the player history list
            local possible_choice = math.random(1, #player1_history)
            --return the option that player 2 has that beats whatever option on the list that the random number landed on
            if contains(player2_hand[i].strengths, player1_history[possible_choice].name) then
                return i
            end
        end
    end
    --tie, first round with no data, or no options on-hand that apply to either potentially winning scenario. Pick a random option
    return math.random(1, #player2_hand)
end

--mode-dependent controls functions
local function  title_controls()
    if playdate.buttonJustPressed("up") then
        title_index = ((title_index-2)%2)+1
    elseif playdate.buttonJustPressed("down") then
        title_index = (title_index%2)+1
    end
    if playdate.buttonJustPressed("a") then
        title_sprite:remove()
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
        menu_sprite:remove()
        player1_hp_val:add()
        player2_hp_val:add()
        game_mode = menu_index
        mode = mode_list[game_mode]
    elseif playdate.buttonJustPressed("b") then
        menu_sprite:remove()
        mode = "title"
    end
end

local function game_controls()
    --move through hand
    if not showMenu then
        local crankTicks = playdate.getCrankTicks(5)
        if playdate.buttonJustPressed("right") or (crankTicks == 1) then
            active_card = (active_card % 5)+1
        elseif playdate.buttonJustPressed("left") or (crankTicks == -1) then
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
            player2_index = getplayer2Card()
            player2_card = player2_hand[player2_index]
            --set up for next turn
            winning_card = player1_card
            table.insert(player1_history, player1_card)
            turn_num = turn_num + 1
            --remove cards from players
            table.remove(player1_hand, active_card)
            table.remove(player2_hand, player2_index)
            active_card_y = 175
        else
            if active_player == 1 then
                --pick player card
                print("Player 1 turn")
                player1_card = active_hand[active_card]
                table.remove(player1_hand, active_card)
            else
                print("Player 2 turn")
                player2_card = active_hand[active_card]
                table.remove(player2_hand, player2_index)
                active_card_y = 175
            end
            --swap players
            active_player = (active_player%2)+1
        end
        --damage logic
        if player2_card.name ~= nil then
            --player1 wins
            if contains(player1_card.strengths, player2_card.name) then
                --reduce player2 hp
                player2_hp = player2_hp-20
                winning_card = player1_card
            --player2 wins
            elseif contains(player2_card.strengths, player1_card.name) then
                --reduce player1 hp
                player1_hp = player1_hp-20
                winning_card = player2_card
            --cards cancel out
            elseif player1_card.name == player2_card.name then
                --nothing happens
                --TODO: DO SOMETHING OF NOTE HERE LIKE AN ANIMATION OR SOUND!
                winning_card = player1_card
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
            --discard cards
            table.insert(discard, player1_card)
            table.insert(discard, player2_card)
            --remove new cards from deck
            table.remove(deck, #deck)
            table.remove(deck, #deck-1)
            --animate cards moving from deck to hands

            --give players new cards
            table.insert(player1_hand, deck[#deck])
            table.insert(player2_hand, deck[#deck-1])
            --reset choice
            player1_card = {}
            player2_card = {}
            active_card_y = 140
            active_card, player2_index = 1, 1
        end
        --deck is getting close to empty
        if #deck <= 2 then
            --add discard pile to deck and shuffle
            for _, val in pairs(discard) do
                table.insert(deck, val)
            end
            discard = {}
            shuffleDeck()
        end
    end
end

local function rps_controls()
    local crankTicks = playdate.getCrankTicks(3)
    if playdate.buttonJustPressed("right") or (crankTicks == 1) then
        active_card = (active_card % 3)+1
    elseif playdate.buttonJustPressed("left") or (crankTicks == -1) then
        active_card = ((active_card-2) % 3)+1
    end
    if playdate.buttonJustPressed("a") then
        if player_mode == 1 then
            player1_card = player1_hand[active_card]
            player2_index = getplayer2Card()
            player2_card = player2_hand[player2_index]
            --set up for next turn
            winning_card = player1_hand[active_card]
            turn_num = turn_num + 1
        else
            if active_player == 1 then
                --pick player card
                player1_card = active_hand[active_card]
            else
                player2_card = active_hand[active_card]
            end
            --swap players
            active_player = (active_player%2)+1
        end
        if player2_card.name ~= nil then
            --player1 wins
            if contains(player1_card.strengths, player2_card.name) then
                --reduce player2 hp
                player2_hp = player2_hp-20
                winning_card = player1_card
            --player2 wins
            elseif contains(player2_card.strengths, player1_card.name) then
                --reduce player1 hp
                player1_hp = player1_hp-20
                winning_card = player2_card
            --cards cancel out
            elseif player1_card.name == player2_card.name then
                --nothing happens
                --TODO: DO SOMETHING OF NOTE HERE LIKE AN ANIMATION OR SOUND!
                winning_card = player1_card
            end
            --reset choice
            player1_card = {}
            player2_card = {}
        end
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
    title_sprite:add()
end

local function menu_update()
    menu_sprite:add()
end

local function game_update()
    gfx.clear()
    game_sprite:add()
    --decrease hp bar display
    local player1_hp_calc = math.floor(120*(player1_hp/100))
    local player2_hp_calc = math.floor(120*(player2_hp/100))
    player1_hp_val:setClipRect(5, 5, player1_hp_calc, 20)
    player2_hp_val:setClipRect(275, 5, player2_hp_calc, 20)
    --HP bar logic
    if player1_hp < 0 then player1_hp = 0 end
    if player2_hp < 0 then player2_hp = 0 end
    --collect all the cards
    if game_start then
        createDeck()
        card_list = table.copy(deck)
        shuffleDeck()
        --add all cards to drawing list
        for i=1, #card_list do
            card_list[i].sprite:setCenter(0, 0)
            card_list[i].sprite:add()
        end
        --distribute cards
        for i=1,5 do
            local i_1, i_2 = #deck, #deck-1
            local card_1, card_2 = deck[i_1], deck[i_2]
            table.insert(player1_hand, card_1)
            table.insert(player2_hand, card_2)
            table.remove(deck, i_1)
            table.remove(deck, i_2)
        end
        game_start = false
    end
    local deck_size = #deck
    local discard_size = #discard
    --active hand
    if active_player == 1 then
        active_hand = player1_hand
        non_active_hand = player2_hand
    else
        active_hand = player2_hand
        non_active_hand = player1_hand
    end
    --draw right side
    if active_player == 1 then
        local id_list = getCardIDs(deck)
        for i=1, deck_size do
            local current_id = id_list[i]
            card_list[current_id].sprite:setZIndex(i)
            card_list[current_id].sprite:moveTo(323, 110-(i*2)+2)
        end
    else
        if discard_size > 0 then
            local id_list = getCardIDs(discard)
            for i=1, discard_size do
                local current_id = id_list[i]
                card_list[current_id].sprite:setZIndex(i)
                card_list[current_id].sprite:moveTo(323, 110-(i*2)+2)
                discard[i].sprite:setImage(gfx.image.new(discard[i].image), "flipY")
            end
        end
    end
    --draw left side
    if active_player == 1 then
        if discard_size > 0 then
            local id_list = getCardIDs(discard)
            for i=1, discard_size do
                local current_id = id_list[i]
                card_list[current_id].sprite:setZIndex(i)
                card_list[current_id].sprite:moveTo(42, 110-(i*2)+2)
            end
        end
    else
        local id_list = getCardIDs(deck)
        for i=1, deck_size do
            local current_id = id_list[i]
            card_list[current_id].sprite:setZIndex(i)
            card_list[current_id].sprite:moveTo(42, 110-(i*2)+2)
        end
    end
    --draw active hand
    local active_id_list = getCardIDs(active_hand)
    for i=5, 1, -1 do
        local current_id = active_id_list[i]
        card_list[current_id].sprite:setZIndex(i)
        if i ~= active_card then
            card_list[current_id].sprite:moveTo(171+5*(i-1), 175)
        else
            card_list[current_id].sprite:moveTo(171+5*(i-1), active_card_y)
        end
    end
    --draw non-active hand
    local non_active_id_list = getCardIDs(non_active_hand)
    for i=1,5 do
        local current_id = non_active_id_list[i]
        card_list[current_id].sprite:setZIndex(i)
        card_list[current_id].sprite:moveTo(171+5*(i-1), 15)
    end
    --endgame logic
    if player1_hp == 0 or player2_hp == 0 then
        if player1_hp == 0 and player2_hp == 0 then
            winner = "It's a tie!"
        elseif player1_hp == 0 then
                winner = "Player 2 wins!"
        elseif player2_hp == 0 then
                winner = "Player 1 wins!"
        end
        mode = "end"
    end
end

local function rps_update()
    rps_sprite:add()
    --decrease hp bar display
    local player1_hp_calc = math.floor(120*(player1_hp/100))
    local player2_hp_calc = math.floor(120*(player2_hp/100))
    player1_hp_val:setClipRect(5, 5, player1_hp_calc, 20)
    player2_hp_val:setClipRect(275, 5, player2_hp_calc, 20)
    --HP bar logic
    if player1_hp < 0 then player1_hp = 0 end
    if player2_hp < 0 then player2_hp = 0 end
    --active hand
    if active_player == 1 then
        active_hand = player1_hand
        non_active_hand = player2_hand
    else
        active_hand = player2_hand
        non_active_hand = player1_hand
    end
    local player1_cards
    local player2_cards
    if game_start then
        player1_hand = {cards[1], cards[2], cards[3]}
        player2_hand = {cards[1], cards[2], cards[3]}
        player1_cards = {gfx.sprite.new(), gfx.sprite.new(), gfx.sprite.new()}
        player2_cards = {gfx.sprite.new(), gfx.sprite.new(), gfx.sprite.new()}

        for i=1, 3 do
            player1_cards[i]:setImage(gfx.image.new(player1_hand[i].image))
            player2_cards[i]:setImage(gfx.image.new(player2_hand[i].image), "flipY")

            player1_cards[i]:setCenter(0, 0)
            player2_cards[i]:setCenter(0, 0)

            player1_cards[i]:moveTo(102+(40*i), 175)
            player2_cards[i]:moveTo(262-(40*i), 15)

            player1_cards[i]:add()
            player2_cards[i]:add()
        end
        game_start = false
    end
    --endgame logic
    if player1_hp == 0 or player2_hp == 0 then
        if player1_hp == 0 and player2_hp == 0 then
            winner = "It's a tie!"
        elseif player1_hp == 0 then
                winner = "Player 2 wins!"
        elseif player2_hp == 0 then
                winner = "Player 1 wins!"
        end
        mode = "end"
    end
end

local function end_update()
    gfx.sprite.removeAll()
    end_sprite:add()
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
    --update timers
    playdate.timer.updateTimers()
    --update the sprites every frame
    gfx.sprite.update()
end