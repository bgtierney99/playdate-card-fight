class("FireCard").extends(Card)

function FireCard:init(x, y)
    FireCard.super.init(x, y, "images/icon_fire")
    self.name = "fire"
    self.strengths = {"grass", "snow", "metal"}
end