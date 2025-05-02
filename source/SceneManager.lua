--import scenes to add to the list

class('SceneManager').extends()

local gfx <const> = playdate.graphics
local current_scene

function SceneManager:init()
    import "scene_title"
    self:load_scene(TitleScene())
end

function SceneManager:load_scene(next_scene)
    if next_scene then
        gfx.clear()
        gfx.sprite.removeAll()
        self:removeAllTimers()
        self.current_scene = next_scene
        self.current_scene:init()
    else
        print("No valid scene provided")
        playdate.stop()
    end
end

function SceneManager:removeAllTimers()
    for _, timer in ipairs(playdate.timer.allTimers()) do
        timer.remove()
    end
end