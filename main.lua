import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"
import "CoreLibs/animator"

import "GameManager"
import "SceneManager"

local gfx <const> = playdate.graphics
GAME_MANAGER = GameManager()
SCENE_MANAGER = SceneManager()

local function initialize()
    SCENE_MANAGER:init()
end

initialize()

--handle game logic
function playdate.update()
    --clear the screen after every frame
    gfx.clear()
    if SCENE_MANAGER.current_scene then
        --update function for current game state/scene
        SCENE_MANAGER.current_scene:update()
        --controls for current game state/scene
        SCENE_MANAGER.current_scene:controls()
    else
        print("No current scene loaded!")
    end
    --update timers
    playdate.timer.updateTimers()
    --update the sprites every frame
    gfx.sprite.update()
end