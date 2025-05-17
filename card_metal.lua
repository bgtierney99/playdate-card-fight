class("MetalCard").extends(Card)

function MetalCard:init(x, y)
    MetalCard.super.init(self, x, y, "images/icon_metal")
    self.name = "metal"
    self.strengths = {"earth", "snow", "grass"}
end