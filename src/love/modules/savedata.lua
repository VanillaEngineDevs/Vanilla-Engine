settings = require "settings"
savedata = {}

function loadSavedata()
    -- read savedata with lume
    if love.filesystem.getInfo("savedata") then
        savedata = lume.deserialize(love.filesystem.read("savedata"))
    else
        savedata = {}
    end
end

if love.filesystem.getInfo("settings") then 
    settingsdata = lume.deserialize(love.filesystem.read("settings"))

    settings = settingsdata

    customBindLeft = settings.customBindLeft
    customBindRight = settings.customBindRight
    customBindUp = settings.customBindUp
    customBindDown = settings.customBindDown

    settingsVer = settings.settingsVer

    settingdata = {
        hardwareCompression = settings.hardwareCompression,
        downscroll = settings.downscroll,
        ghostTapping = settings.ghostTapping,
        showDebug = settings.showDebug,
        setImageType = settings.setImageType,
        sideJudgements = settings.sideJudgements,
        middleScroll = settings.middleScroll,
        practiceMode = settings.practiceMode,
        noMiss = settings.noMiss,
        customScrollSpeed = settings.customScrollSpeed,
        keystrokes = settings.keystrokes,
        scrollUnderlayTrans = settings.scrollUnderlayTrans,
        customBindDown = customBindDown,
        customBindUp = customBindUp,
        customBindLeft = customBindLeft,
        customBindRight = customBindRight,
        window = settings.window,
        fpsCap = settings.fpsCap,
        pixelPerfect = false,
        settingsVer = settingsVer
    }
    serialized = lume.serialize(settingdata)
    love.filesystem.write("settings", serialized)
end
if settingsVer ~= 3 then
    love.window.showMessageBox("Uh Oh!", "Settings have been reset.", "warning")
    love.filesystem.remove("settings")
end
if not love.filesystem.getInfo("settings") or settingsVer ~= 3 then
    settings.hardwareCompression = true
    graphics.setImageType("dds")
    settings.setImageType = "dds"
    settings.downscroll = false
    settings.middleScroll = false
    settings.ghostTapping = true
    settings.showDebug = false
    settings.sideJudgements = false
    settings.practiceMode = false
    settings.noMiss = false
    settings.customScrollSpeed = 1
    settings.keystrokes = false
    settings.scrollUnderlayTrans = 0
    settings.window = false
    settings.fpsCap = 60
    settings.pixelPerfect = false
    --settings.noteSkins = 1
    customBindLeft = "a"
    customBindRight = "d"
    customBindUp = "w"
    customBindDown = "s"

    settings.flashinglights = false
    settingsVer = 3
    settingdata = {}
    settingdata = {
        hardwareCompression = settings.hardwareCompression,
        downscroll = settings.downscroll,
        ghostTapping = settings.ghostTapping,
        showDebug = settings.showDebug,
        setImageType = settings.setImageType,
        sideJudgements = settings.sideJudgements,
        middleScroll = settings.middleScroll,
        practiceMode = settings.practiceMode,
        noMiss = settings.noMiss,
        customScrollSpeed = settings.customScrollSpeed,
        keystrokes = settings.keystrokes,
        scrollUnderlayTrans = settings.scrollUnderlayTrans,
        fpsCap = settings.fpsCap,
        pixelPerfect = false,

        customBindLeft = "a",
        customBindRight = "d",
        customBindUp = "w",
        customBindDown = "s",
        
        settingsVer = settingsVer
    }
    serialized = lume.serialize(settingdata)
    love.filesystem.write("settings", serialized)
end

function saveSettings(menu)
	local menu = menu == nil and true or menu
    if settings.hardwareCompression ~= settingdata.hardwareCompression then
        settingdata = {}
        if settings.hardwareCompression then
            imageTyppe = "dds" 
        else
            imageTyppe = "png"
        end
        settingdata = {
            hardwareCompression = settings.hardwareCompression,
            downscroll = settings.downscroll,
            ghostTapping = settings.ghostTapping,
            showDebug = settings.showDebug,
            setImageType = imageTyppe,
            sideJudgements = settings.sideJudgements,
            middleScroll = settings.middleScroll,
            randomNotePlacements = settings.randomNotePlacements,
            practiceMode = settings.practiceMode,
            noMiss = settings.noMiss,
            customScrollSpeed = settings.customScrollSpeed,
            keystrokes = settings.keystrokes,
            scrollUnderlayTrans = settings.scrollUnderlayTrans,
            Hitsounds = settings.Hitsounds,
            vocalsVol = settings.vocalsVol,
            instVol = settings.instVol,
            hitsoundVol = settings.hitsoundVol,
            noteSkins = settings.noteSkins,
            flashinglights = settings.flashinglights,
            window = settings.window,
			fpsCap = settings.fpsCap,
            pixelPerfect = false,
            customBindDown = customBindDown,
            customBindUp = customBindUp,
            customBindLeft = customBindLeft,
            customBindRight = customBindRight,
            settingsVer = settingsVer
        }
        serialized = lume.serialize(settingdata)
        love.filesystem.write("settings", serialized)
        love.window.showMessageBox("Settings Saved!", "Settings saved. Vanilla Engine will now restart to make sure your settings saved")
        love.event.quit("restart")
    else
        settingdata = {}
        if settings.hardwareCompression then
            imageTyppe = "dds" 
        else
            imageTyppe = "png"
        end
        settingdata = {
            hardwareCompression = settings.hardwareCompression,
            downscroll = settings.downscroll,
            ghostTapping = settings.ghostTapping,
            showDebug = settings.showDebug,
            setImageType = settings.setImageType,
            sideJudgements = settings.sideJudgements,
            middleScroll = settings.middleScroll,
            randomNotePlacements = settings.randomNotePlacements,
            practiceMode = settings.practiceMode,
            noMiss = settings.noMiss,
            customScrollSpeed = settings.customScrollSpeed,
            keystrokes = settings.keystrokes,
            scrollUnderlayTrans = settings.scrollUnderlayTrans,
            Hitsounds = settings.Hitsounds,
            vocalsVol = settings.vocalsVol,
            instVol = settings.instVol,
            hitsoundVol = settings.hitsoundVol,
            noteSkins = settings.noteSkins,
            flashinglights = settings.flashinglights,
			window = settings.window,
			fpsCap = settings.fpsCap,
            pixelPerfect = false,

            customBindDown = customBindDown,
            customBindUp = customBindUp,
            customBindLeft = customBindLeft,
            customBindRight = customBindRight,
            settingsVer = settingsVer
        }
        serialized = lume.serialize(settingdata)
        love.filesystem.write("settings", serialized)
		if menu then
			graphics:fadeOutWipe(
				0.7,
				function()
					Gamestate.switch(menuSelect)
					status.setLoading(false)
				end
			)
		end
    end
end

function saveSavedata()
    -- write savedata with lume
    love.filesystem.write("savedata", lume.serialize(savedata))
end