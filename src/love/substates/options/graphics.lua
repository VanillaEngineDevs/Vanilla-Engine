local m_graphics = OptionsMenu:extend()

function m_graphics:enter()
    local o = Option:new(
        "Fps Limit",
        "How many frames per second the game will run at",
        settings.fpsCap,
        "number"
    )
    o.minValue = debug and 1 or 30
    o.maxValue = 500
    self:addOption(o)
    self:addOption(
        Option:new(
            "Hardware Compression",
            "If checked, the game will use DDS textures instead of PNGs. This will make the game run faster and is recommended. Needs Restart.",
            settings.hardwareCompression,
            "bool"
        )
    )
    
    self.super.enter(self)
end

function m_graphics:leave()
    settings.fpsCap = self.optionsArray[1]:getValue()
    settings.hardwareCompression = self.optionsArray[2]:getValue()

    self.super.leave(self)
end

return m_graphics