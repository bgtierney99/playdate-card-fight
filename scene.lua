local gfx <const> = playdate.graphics

class('Scene').extends()

local backgroundImage = gfx.sprite.new()
backgroundImage:setSize(400, 240)

function Scene:init(background)
    print("Initializing scene!")
    if background then
        print("Background: ", background)
        backgroundImage = gfx.image.new(background)
        gfx.sprite.setBackgroundDrawingCallback(
            function( x, y, width, height )
                backgroundImage:draw( 0, 0 )
            end
        )
    else
        print("No background present")
    end
end