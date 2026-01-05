local MultiSparrowCharacter = Character:extend()

function MultiSparrowCharacter:new(data)
    MultiSparrowCharacter.super.new(self, data)

    self.sprites = {}

    self.primary = graphics.newSparrowAtlas()
    table.insert(self.sprites, self.primary)
    self.assetPath = data.assetPath:gsub("shared:", "characters/")
    self.primary:load(self.assetPath .. "")

    for i, anims in ipairs(data.animations) do

    end
end

return MultiSparrowCharacter