class('OptionButton').extends(sprite)

local gfx <const> = playdate.graphics
local text = "Option Button"
local selected = false
local neighbor_top, neighbor_bottom, neightbor_left, neighbor_right

function OptionButton:init(text, x, y)
    function self:draw(x, y)
        gfx.setClipRect(x, y, 50, 50)
        gfx.drawTextAligned(text, x, y, kTextAlignment.center)
        gfx.clearClipRect()
    end
    OptionButton.super.add()
    OptionButton.super.draw(x, y)
end


function OptionButton:update()
    if selected then
        print(text, " selected!")
    end
end