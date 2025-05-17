class("AirCard").extends(Card)

function AirCard:init(x, y)
    AirCard.super.init(self, x, y, "images/icon_air")
    self.name = "air"
    self.strengths = {"fire", "grass", "water"}
end