import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"

import "SceneManager"

local gfx <const> = playdate.graphics

local function initialize()
    SceneManager.current_scene:init()
end

initialize()

--handle game logic
function playdate.update()
    --clear the screen after every frame
    gfx.clear()
    --update function for current game state/scene
    SceneManager.current_scene:update()
    --controls for current game state/scene
    SceneManager.current_scene:controls()
    --update timers
    playdate.timer.updateTimers()
    --update the sprites every frame
    gfx.sprite.update()
end