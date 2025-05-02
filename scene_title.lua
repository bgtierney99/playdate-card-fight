import "scene_game"

local gfx <const> = playdate.graphics

class('TitleScene').extends(Scene)

name = "Title"
-- backgroundImage = gfx.image.new("images/background")
backgroundImage = gfx.image.new(400, 240)
arrow = gfx.image.new("images/arrow")
local selected_index = 1
local mode_index = 1
local player_text, mode_text = gfx.sprite.new(), gfx.sprite.new()

local function change_mode(mode)
    if mode == 1 then mode_text:remove() elseif mode == 2 then player_text:remove() end
    -- options_list[mode_index].visuals:remove()
    mode_index = mode
    if mode == 1 then player_text:add() elseif mode == 2 then mode_text:add() end
    -- options_list[mode_index].visuals:add()
end

local options_list = {
    {
        {text="1-Player", action=function() GAME_MANAGER:setPlayerCount(1) end},
        {text="2-Player", action=function() GAME_MANAGER:setPlayerCount(2) end}
    },
    {
        {text="Fight", action=function() print("Transition to fight scene") SCENE_MANAGER:load_scene(GameScene()) end},
        {text="Rock, Paper, Scissors", action=function() print("Transition to rps scene") SCENE_MANAGER:load_scene(GameScene()) end}
    }
}

player_text:setSize(400, 240)
function player_text:draw(x, y)
    gfx.setClipRect(x, y, 400, 240)
    for i=1,#options_list[1] do
        gfx.drawTextAligned(options_list[1][i]["text"], x+200, y+150+(40*(i-1)), kTextAlignment.center) 
    end
    gfx.clearClipRect()
end

mode_text:setSize(400, 240)
function mode_text:draw(x, y)
    gfx.setClipRect(x, y, 400, 240)
    for i=1,#options_list[2] do
        gfx.drawTextAligned(options_list[2][i]["text"], x+200, y+150+(40*(i-1)), kTextAlignment.center) 
    end
    gfx.clearClipRect()
end

function TitleScene:init()
    TitleScene.super.init()
    name = "Title"
    gfx.sprite.setBackgroundDrawingCallback(
        function( x, y, width, height )
            backgroundImage:draw( 0, 0 )
            gfx.drawTextAligned("Card Fight", 200, 10, kTextAlignment.center)
        end
    )
    player_text:add()
    player_text:draw(0, 0)
end

function TitleScene:update()
    -- gfx.setClipRect(x, y, 400, 240)
    -- gfx.clearClipRect()
end

function TitleScene:controls()
    if playdate.buttonJustPressed(playdate.kButtonUp) then
        selected_index -= 1
        if selected_index < 1 then selected_index = #options_list end
        print("Moving up to ", selected_index)
    elseif playdate.buttonJustPressed(playdate.kButtonDown) then
        selected_index += 1
        if selected_index > #options_list then selected_index = 1 end
        print("Moving down to ", selected_index)
    end
    if playdate.buttonJustPressed(playdate.kButtonA) then
        options_list[mode_index][selected_index].action()
        if mode_index < #options_list then mode_index += 1 end
        change_mode(mode_index)
    end
    if playdate.buttonJustPressed(playdate.kButtonB) then
        if mode_index > 1 then mode_index -= 1 end
        change_mode(mode_index-1)
    end
end