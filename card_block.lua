class("BlockCard").extends(Card)

function BlockCard:init(x, y)
    BlockCard.super.init(self, x, y, "images/icon_block")
    self.name = "block"
    self.strengths = {"all"}
end