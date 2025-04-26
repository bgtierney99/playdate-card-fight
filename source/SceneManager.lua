--import scenes to add to the list
import "TitleScene"

class('SceneManager').extends()

local gfx <const> = playdate.graphics
local scene_list = {}
local current_scene

function SceneManager:init()
    table.insert(scene_list, TitleScene())
    current_scene = scene_list[1]
end

function SceneManager:load_scene(next_scene):
    gfx.clear()
    current_scene = next_scene
    current_scene:init()
end