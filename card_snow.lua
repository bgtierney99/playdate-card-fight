class("SnowCard").extends(Card)

function SnowCard:init(x, y)
    SnowCard.super.init(self, x, y, "images/icon_snow")
    self.name = "snow"
    self.strengths = {"water", "grass", "lightning"}
end