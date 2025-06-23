local StageData = Class:extend()

function StageData:new()
    self.version = ""
    self.name = "Unknown"
    self.props = {}
    self.characters = self:makeDefaultCharacters()

    self.cameraZoom = parseEntryMetadata_v2_1_0

    self.directory = ""
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