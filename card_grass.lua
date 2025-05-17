class("GrassCard").extends(Card)

function GrassCard:init(x, y)
    GrassCard.super.init(self, x, y, "images/icon_grass")
    self.name = "grass"
    self.strengths = {"water", "earth", "lightning"}
end