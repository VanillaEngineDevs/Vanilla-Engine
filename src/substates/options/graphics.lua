local m_graphics = OptionsMenu:extend()

local supportsHardwareCompression = love.graphics.getImageFormats().DXT5 ~= nil

function m_graphics:enter()
    if supportsHardwareCompression then
        self:addOption(
            Option:new(
                "Hardware Compression",
                "If checked, the game will use DDS textures instead of PNGs. This will make the game run faster and is recommended. Needs Restart.",
                settings.hardwareCompression,
                "bool"
            )
        )
    else
        self:addOption(
            Option:new(
                "Hardware Compression",
                "Your system does not support hardware compression. This option will be ignored.",
                false,
                "bool"
            )
        )
    end

    self:addOption(
        Option:new(
            "Shaders",
            "If checked, the game will use shaders to improve graphics. This will make the game run slower but look better. Needs Restart.",
            settings.shaders,
            "bool"
        )
    )

    local fpsCapOpt = Option:new(
        "FPS Cap",
        "How many frames per second the game will run at.",
        settings.fpsCap,
        "number"
    )
    fpsCapOpt.minValue = debug and 1 or 30
    fpsCapOpt.maxValue = 500
    self:addOption(fpsCapOpt)

    self.super.enter(self)
end

function m_graphics:leave()
    if supportsHardwareCompression then
        settings.hardwareCompression = self.optionsArray[1]:getValue()
        settings.shaders = self.optionsArray[2]:getValue()
        settings.fpsCap = self.optionsArray[3]:getValue()
    else
        settings.hardwareCompression = false
        settings.shaders = self.optionsArray[1]:getValue()
        settings.fpsCap = self.optionsArray[2]:getValue()
    end

    self.super.leave(self)
end

return m_graphics