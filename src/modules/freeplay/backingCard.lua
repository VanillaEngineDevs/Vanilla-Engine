local backingCard = Group:extend()

backingCard.instance = nil

function backingCard:new(char, state)
    Group.new(self)

    if not backingCard.instance then backingCard.instance = state end

    --self.cardGlow
    
    
end