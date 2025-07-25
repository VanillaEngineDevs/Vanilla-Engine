local gamemodes = OptionsMenu:extend()

function gamemodes:enter()
    self.title = "Gamemode Settings"

    self:addOption(
        Option:new(
            "Practice Mode",
            "If checked, you can't fail songs",
            settings.practiceMode,
            "bool"
        )
    )

    self:addOption(
        Option:new(
            "Sudden Death",
            "If checked, you fail the song if you miss a note",
            settings.noMiss,
            "bool"
        )
    )

    self.super.enter(self)
end

function gamemodes:leave()
    settings.practiceMode = self.optionsArray[1]:getValue()
    settings.noMiss = self.optionsArray[2]:getValue()

    self.super.leave(self)
end

return gamemodes