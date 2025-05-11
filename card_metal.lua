class("MetalCard").extends(Card)

function MetalCard:init(x, y)
    MetalCard.super.init(x, y, "images/icon_metal")
    self.name = "metal"
    self.strengths = {"earth", "snow", "grass"}
end