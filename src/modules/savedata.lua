settings = {}
savedata = {}

local SETTINGS_VERSION = 7

local function getDefaultSettings()
    customBindDown = "s"
    customBindLeft = "a"
    customBindRight = "d"
    customBindUp = "w"
    local useHardwareCompression = true
    if love.graphics.getImageFormats().DXT5 then
        useHardwareCompression = true
    end
    return {
        hardwareCompression = useHardwareCompression,
        downscroll = false,
        ghostTapping = true,
        showDebug = false,
        setImageType = "dds",
        sideJudgements = false,
        middlescroll = false,
        practiceMode = false,
        noMiss = false,
        customScrollSpeed = 1,
        keystrokes = false,
        scrollUnderlayTrans = 0,
        window = false,
        fpsCap = 60,
        pixelPerfect = false,
        scoringType = "KE",
        accuracyMode = "Simple",
        popupScoreMode = "Stack",
        judgePreset = "PBot1",
        customBindLeft = customBindLeft or "a",
        customBindRight = customBindRight or "d",
        customBindUp = customBindUp or "w",
        customBindDown = customBindDown or "s",
        flashinglights = false,
        settingsVer = SETTINGS_VERSION
    }
end

function loadSavedata()
    if love.filesystem.getInfo("savedata") then
        savedata = lume.deserialize(love.filesystem.read("savedata"))
    else
        savedata = {}
    end
end

local function loadOrResetSettings()
    local reset = false

    if love.filesystem.getInfo("settings") then
        local data = lume.deserialize(love.filesystem.read("settings"))
        if data and data.settingsVer == SETTINGS_VERSION then
            settings = data
            customBindDown = settings.customBindDown or "s"
            customBindLeft = settings.customBindLeft or "a"
            customBindRight = settings.customBindRight or "d"
            customBindUp = settings.customBindUp or "w"
            return
        else
            reset = true
        end
    else
        reset = true
    end

    if reset then
        love.window.showMessageBox("Uh Oh!", "Settings have been reset.", "warning")
        love.filesystem.remove("settings")
        settings = getDefaultSettings()
        saveSettings(false)
        graphics.setImageType("dds")
    end
end

function saveSettings(restartOnChange)
    restartOnChange = restartOnChange == nil and true or restartOnChange

    local newSettings = lume.clone(settings, true)

    -- Determine image type based on compression
    newSettings.setImageType = newSettings.hardwareCompression and "dds" or "png"
    newSettings.pixelPerfect = false
    newSettings.settingsVer = SETTINGS_VERSION

    local currentSerialized = lume.serialize(settings)
    local newSerialized = lume.serialize(newSettings)

    if currentSerialized ~= newSerialized then
        love.filesystem.write("settings", newSerialized)

        if restartOnChange then
            love.window.showMessageBox("Settings Saved!", "Settings saved. Restarting Vanilla Engine to apply changes.")
            love.event.quit("restart")
        else
            graphics:fadeOutWipe(0.7, function()
                Gamestate.switch(menuSelect)
                status.setLoading(false)
            end)
        end
    end
end

function saveSavedata()
    love.filesystem.write("savedata", lume.serialize(savedata))
end

loadOrResetSettings()