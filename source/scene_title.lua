local gfx <const> = playdate.graphics

class('TitleScene').extends(Scene)

name = "Title"
backgroundImage = gfx.sprite.new()

function TitleScene:init():
    TitleScene.super:init()
    gfx.drawTextAligned("Card Fight", 0, 0, kTextAlignment.center)
end

function TitleScene:update()
    TitleScene.super:update()
end

function TitleScene:controls()
    TitleScene.super:controls()
    if playdate.buttonIsPressed(playdate.kButtonUp) then
        print("Moving up")
    elseif playdate.buttonIsPressed(playdate.kButtonDown) then
        print("Moving down")
    end
end