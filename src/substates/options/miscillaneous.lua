local miscillaneous = OptionsMenu:extend()

function miscillaneous:enter()
    self.title = "Gamemode Settings"

    self:addOption(
        Option:new(
            "Debug String",
            "What debug info to show",
            settings.showDebug,
            "string",
            {
                false,
                "fps",
                "detailed"
            }
        )
    )

    self.super.enter(self)
end

function miscillaneous:leave()
    settings.showDebug = self.optionsArray[1]:getValue()

    self.super.leave(self)
end

return miscillaneous