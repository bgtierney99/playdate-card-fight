import "scene_game"

local gfx <const> = playdate.graphics
local crankTicks = playdate.getCrankTicks(5)

class('TitleScene').extends(Scene)

name = "Title"
-- backgroundImage = gfx.image.new("images/background")
backgroundImage = gfx.image.new(400, 240)
local arrow = nil
local selected_index = 1
local mode_index = 1
local displayed_text = gfx.sprite.new()

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

local function change_mode(mode)
    if mode < 1 then mode = 1 elseif mode > #options_list then mode = #options_list end
    mode_index = mode
    function displayed_text:draw(x, y)
        gfx.setClipRect(x, y, 400, 240)
        for i=1,#options_list[mode] do
            gfx.drawTextAligned(options_list[mode][i]["text"], x+200, y+150+(40*(i-1)), kTextAlignment.center) 
        end
        gfx.clearClipRect()
    end
    displayed_text:draw(0, 0)
end

function TitleScene:init()
    TitleScene.super.init()
    playdate.restart()
    name = "Title"
    gfx.sprite.setBackgroundDrawingCallback(
        function( x, y, width, height )
            backgroundImage:draw( 0, 0 )
            gfx.drawTextAligned("Card Fight", 200, 10, kTextAlignment.center)
        end
    )
    selected_index = 1
    mode_index = 1
    local arrow_img = gfx.image.new("images/arrow")
    arrow = gfx.sprite.new(arrow_img)
    arrow:add()
    displayed_text:setSize(400, 240)
    displayed_text:add()
    change_mode(1)
end

function TitleScene:update()
    crankTicks = playdate.getCrankTicks(5)
    arrow:moveTo(100, 157+(40*(selected_index-1)))
end

function TitleScene:controls()
    if playdate.buttonJustPressed(playdate.kButtonUp) or (crankTicks == -1) then
        selected_index -= 1
        if selected_index < 1 then selected_index = #options_list end
    elseif playdate.buttonJustPressed(playdate.kButtonDown) or (crankTicks == 1) then
        selected_index += 1
        if selected_index > #options_list then selected_index = 1 end
    end
    if playdate.buttonJustPressed(playdate.kButtonA) then
        options_list[mode_index][selected_index].action()
        if mode_index < #options_list then
            change_mode(mode_index+1)
        end
    end
    if playdate.buttonJustPressed(playdate.kButtonB) then
        if mode_index > 1 then
            change_mode(mode_index-1)
        end
    end
end