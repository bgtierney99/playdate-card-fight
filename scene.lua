local gfx <const> = playdate.graphics

class('Scene').extends()

local name = "Scene"
local backgroundImage = gfx.sprite.new()
backgroundImage:setSize(400, 240)

function Scene:init()
    print("Name: ", name)
    gfx.sprite.setBackgroundDrawingCallback(
        function( x, y, width, height )
            backgroundImage:draw( 0, 0 )
        end
    )
end