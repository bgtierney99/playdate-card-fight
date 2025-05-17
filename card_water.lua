class("WaterCard").extends(Card)

function WaterCard:init(x, y)
    WaterCard.super.init(self, x, y, "images/icon_water")
    self.name = "water"
    self.strengths = {"fire", "metal", "earth"}
end