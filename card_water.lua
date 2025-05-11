class("WaterCard").extends(Card)

function WaterCard:init(x, y)
    WaterCard.super.init(x, y, "images/icon_water")
    self.name = "water"
    self.strengths = {"fire", "metal", "earth"}
end