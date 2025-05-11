import "scene_title"

local gfx <const> = playdate.graphics

class('GameScene').extends(Scene)

name = "Game"

function GameScene:init()
    GameScene.super.init()
    name = "Game"
    backgroundImage = gfx.image.new("images/background")
    gfx.sprite.setBackgroundDrawingCallback(
        function( x, y, width, height )
            backgroundImage:draw( 0, 0 )
            -- gfx.drawTextAligned("New Game", 200, 10, kTextAlignment.center)
        end
    )
end

function GameScene:update()

end

function GameScene:controls()
    if playdate.buttonJustPressed(playdate.kButtonA) then
        print("In the test scene!")
    end
    if playdate.buttonJustPressed(playdate.kButtonB) then
        SCENE_MANAGER:load_scene(TitleScene())
    end
end