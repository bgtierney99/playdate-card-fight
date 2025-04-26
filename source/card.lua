local gfx <const> = playdate.graphics

class('Card').extends(gfx.sprite)

function Card:init(x, y, icon)
    self:moveTo(x, y)
    self:setImage("images/card.png")
    self.name = "blank"
    self.strengths = {}
    if icon
        icon:add()
    end
end

function Card:ShowStrengthMenu(menu_state)
    if menu_state then
        print("Showing stengths and weaknesses")
    else
        print("Hiding strengths and weaknesses")
    end
end

function Card:update()
    Card.super.update(self)
    if playdate.buttonIsPressed(playdate.kButtonUp) then
        ShowStrengthMenu(true)
    elseif playdate.buttonIsPressed(playdate.kButtonDown) then
        ShowStrengthMenu(false)
    end
end