class("EarthCard").extends(Card)

function EarthCard:init(x, y)
    EarthCard.super.init(self, x, y, "images/icon_earth")
    self.name = "earth"
    self.strengths = {"fire", "metal", "snow"}
end