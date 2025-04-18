local gameplay = OptionsMenu:extend()

function gameplay:enter()
    self.title = "Gameplay Settings"

    self:addOption(
        Option:new(
            "Downscroll", 
            "If checked, notes go Down instead of Up", 
            settings.downscroll, 
            "bool"
        )
    )

    self:addOption(
        Option:new(
            "Middlescroll",
            "If checked, your notes get centered",
            settings.middleScroll,
            "bool"
        )
    )

    self:addOption(
        Option:new(
            "Ghost Tapping",
            "If checked, you won't get misses from pressing keys while there are no notes able to be hit",
            settings.ghostTapping,
            "bool"
        )
    )

    self:addOption(
        Option:new(
            "Bot Play",
            "If checked, the game will play for you",
            settings.botPlay,
            "bool"
        )
    )

    self:addOption(
        Option:new(
            "Accuracy Mode",
            "How accuracy is calculated. Complex means MS-Based",
            settings.accuracyMode,
            "string",
            {
                "Simple",
                "Complex"
            }
        )
    )

    self:addOption(
        Option:new(
            "Scoring Type",
            "How the scoring is displayed.",
            settings.scoringType,
            "string",
            {
                "KE",
                "Psych",
                "VSlice"
            }
        )
    )

    self:addOption(
        Option:new(
            "Popup Score Display",
            "How the combo and rating gets displayed",
            settings.popupScoreMode,
            "string",
            {
                "Simple",
                "Stack"
            }
        )
    )

    self:addOption(
        Option:new(
            "Judge Preset",
            "The judgement timings for the game.",
            settings.judgePreset,
            "string",
            CONSTANTS.WEEKS.JUDGE_PRESETS
        )
    )

    local o = Option:new(
        "Scrollspeed",
        "How fast the notes scroll, 1 is the default song speed",
        settings.customScrollSpeed,
        "float"
    )
    o.minValue = 0.1
    o.maxValue = 10
    o.scrollSpeed = 30
    o.changeValue = 0.1
    o.decimals = 2
    self:addOption(o)

    o = Option:new(
        "Scroll Underlay Transparency",
        "How opaque the scroll underlay is",
        settings.scrollUnderlayTrans,
        "percent"
    )
    
    o.minValue = 0
    o.maxValue = 1
    o.scrollSpeed = 0.5
    o.changeValue = 0.01
    o.decimals = 2
    self:addOption(o)

    self.super.enter(self)
end

function gameplay:leave()
    -- Save the settings
    settings.downscroll = self.optionsArray[1]:getValue()
    settings.middleScroll = self.optionsArray[2]:getValue()
    settings.ghostTapping = self.optionsArray[3]:getValue()
    settings.botPlay = self.optionsArray[4]:getValue()
    settings.accuracyMode = self.optionsArray[5]:getValue()
    settings.scoringType = self.optionsArray[6]:getValue()
    settings.popupScoreMode = self.optionsArray[7]:getValue()
    settings.judgePreset = self.optionsArray[8]:getValue()
    settings.customScrollSpeed = self.optionsArray[9]:getValue()
    settings.scrollUnderlayTrans = self.optionsArray[10]:getValue()

    self.super.leave(self)
end

return gameplay