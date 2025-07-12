local StageData = Class:extend()

function StageData:new(id, data)
    self.version = ""
    self.name = data.name or "Unknown Stage"
    self.id = id or "unknown_stage"
    self.props = {}
    self.characters = self:makeDefaultCharacters()

    self.cameraZoom = parseEntryMetadata_v2_1_0

    self.directory = ""

    self.props = data.props or {}

    for name, char in pairs(data.characters or {}) do
        char.zIndex = char.zIndex or 0
        char.scale = char.scale or 1
        char.position = char.position or {0, 0}
        char.cameraOffsets = char.cameraOffsets or {0, 0}

        self.characters[name] = char
    end

    for name, prop in pairs(data.props or {}) do
        prop.zIndex = prop.zIndex or 0
        prop.danceEvery = prop.danceEvery or 0
        prop.position = prop.position or {0, 0}
        prop.scale = prop.scale or {1, 1}
        prop.animType = prop.animType or "sparrow"
        prop.isPixel = prop.isPixel or false
        prop.scroll = prop.scroll or {0, 0}
        prop.assetPath = prop.assetPath or ""
        prop.animations = prop.animations or {}

        self.props[name] = prop
    end
end

function StageData:makeDefaultCharacters()
    return {
        bf = {
            zIndex = 0,
            scale = 1,
            position = {0, 0},
            cameraOffsets = {-100, -100}
        },
        dad = {
            zIndex = 0,
            scale = 1,
            position = {0, 0},
            cameraOffsets = {100, -100}
        },
        gf = {
            zIndex = 0,
            scale = 1,
            position = {0, 0},
            cameraOffsets = {0, 0}
        }
    }
end

return StageData