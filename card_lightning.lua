class("LightningCard").extends(Card)

function LightningCard:init(x, y)
    LightningCard.super.init(self, x, y, "images/icon_lightning")
    self.name = "lightning"
    self.strengths = {"water", "metal", "air"}
end