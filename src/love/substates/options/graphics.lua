local m_graphics = OptionsMenu:extend()

local supportsHardwareCompression = love.graphics.getImageFormats().DXT5 ~= nil

function m_graphics:enter()
    --[[ local o = Option:new(
        "Fps Limit",
        "How many frames per second the game will run at",
        settings.fpsCap,
        "number"
    )
    o.minValue = debug and 1 or 30
    o.maxValue = 500
    self:addOption(o) ]]
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
    
    self.super.enter(self)
end

function m_graphics:leave()
    if supportsHardwareCompression then
        settings.hardwareCompression = self.optionsArray[1]:getValue()
    end

    self.super.leave(self)
end

return m_graphics