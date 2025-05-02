import "scene_title"

local gfx <const> = playdate.graphics
-- import "option_button"

class('GameScene').extends(Scene)

name = "Title"
backgroundImage = gfx.image.new("images/background")

function GameScene:init()
    GameScene.super.init()
    name = "Game"
    gfx.sprite.setBackgroundDrawingCallback(
        function( x, y, width, height )
            backgroundImage:draw( 0, 0 )
            gfx.drawTextAligned("Gamet", 200, 10, kTextAlignment.center)
        end
    )
end

function GameScene:update()
    -- gfx.setClipRect(x, y, 400, 240)
    -- gfx.clearClipRect()
end

function GameScene:controls()
    if playdate.buttonJustPressed(playdate.kButtonA) then
        print("In the test scene!")
    end
    if playdate.buttonJustPressed(playdate.kButtonB) then
        SCENE_MANAGER:load_scene(TitleScene())
    end
end