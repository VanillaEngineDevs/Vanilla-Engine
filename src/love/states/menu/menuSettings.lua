local menuBG = graphics.newImage(graphics.imagePath("menu/title-bg"))

newlinesMoment = {
    "",
    "\n\n",
    "\n\n\n\n",
    "\n\n\n\n\n\n",
    "\n\n\n\n\n\n\n\n",
    "\n\n\n\n\n\n\n\n\n\n",
    "\n\n\n\n\n\n\n\n\n\n\n\n",
    "\n\n\n\n\n\n\n\n\n\n\n\n\n\n",
    "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n",  --bruh -- shhhhhhhh  -- no -- yes
    "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n",
    "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n",
    "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n",
    "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
}

settingsDescriptions1 = { -- The big spaces are so it lines up lol
    "Downscroll:" ..
    "\n      \"Downscroll\" Makes arrows scroll down, and rearranges the UI.",

    "Middlescroll:" ..
    "\n      \"Middlescroll\" Centers the player notefield",

    "Ghost Tapping:" ..
    "\n       \"Ghost Tapping\" disables anti-spam, but counts \"Shit\" inputs as\n       misses" ..
    "\n\n       NOTE: Currently unfinished, some aspects of this input mode\n       still need to be implemented, like mash violations",

    "Side Judgements" ..
    "\n       \"Side Judgements\" Shows your judgment counts on the left\n       side of the screen.",

    "Bot Play" ..
    "\n       \"Bot Play\" Sit back and relax. Let the bot do all the playing\n       for you", 

    "Custom Scroll Speed" ..
    "\n       \"Custom Scroll Speed\" Allows you to set a custom scroll speed\n       for the game.\n       1 = Default",

    "Scroll Underlay" ..
    "\n       \"Scroll Underlay\" set a opacity for a scroll underlay\n       0 = Default",

    "Fps Limit" .. 
    "\n       \"Fps Limit\" Limits the FPS of the game\n       60 = Default, 500 max\n       Nintendo Switch stays as 60.",
}
settingsDescriptions2 = {

    "Hardware Compression:" ..
    "\n       \"Hardware Compression\" Use hardware-compressed image formats\n       to save RAM, disabling this will make the game eat your RAM\n       for breakfast (and increase load times)" ..
    "\n\n       WARNING: Don't disable this on 32-bit versions of the game,\n       or the game will quickly run out of memory and crash (thanks\n       to the 2 GB RAM cap)",

    "Show Debug Info" ..
    "\n       \"Show Debug\" Shows debug info on the screen" ..
    "\n\n       \"fps\" only displays FPS count" ..
    "\n\n       \"detailed\" shows things for debugging. (E.g. Music time,\n       Health, etc)",
}
settingsDescriptions3 = { 

    "Practice Mode:" ..
    "\n       \"Practice Mode\" Too hard? Enable this to not lose!",

    "Sudden Death:" ..
    "\n       \"Sudden Death\" Too easy? Enable this to lose if you miss one note",
}

local function switchMenu(menu)end

return {
	enter = function(self, previous)

		songNum = 0
        settingSelect = 1
        settingsMenuState = 0

		camera.zoom = 0.9

		switchMenu(1)

		graphics:fadeInWipe(0.6)
	end,

	update = function(self, dt)
		if not graphics.isFading() then
			if input:pressed("confirm") then
                function confirmFunc()
                    if settingsMenuState == 0 then
                        if settingSelect == 1 then
                            settingSelect = 1
                            settingsMenuState = 1 
                        elseif settingSelect == 2 then
                            settingSelect = 1
                            settingsMenuState = 2
                        elseif settingSelect == 3 then
                            graphics:fadeOutWipe(0.7,
                            function()
                                Gamestate.switch(settingsKeybinds)
                            end)
                        elseif settingSelect == 4 then
                            settingSelect = 1
                            settingsMenuState = 3
                        elseif settingSelect == 5 then
                            settingSelect = 1
                            saveSettings()
                        end
                    elseif settingsMenuState == 1 then
                        if settingSelect == 1 then
                            settings.practiceMode = not settings.practiceMode
                        elseif settingSelect == 2 then
                            settings.noMiss = not settings.noMiss
                        end
                    elseif settingsMenuState == 2 then
                        if settingSelect == 1 then
                            settings.downscroll = not settings.downscroll
                        elseif settingSelect == 2 then
                            settings.middleScroll = not settings.middleScroll
                        elseif settingSelect == 3 then
                            settings.ghostTapping = not settings.ghostTapping
                        elseif settingSelect == 4 then
                            settings.sideJudgements = not settings.sideJudgements
                        elseif settingSelect == 5 then
                            settings.botPlay = not settings.botPlay
                        -- 6 is scroll speed
                        -- 7 is scroll underlay transparency
                        -- 9 is fps limit
                        end
                    elseif settingsMenuState == 3 then
                        if settingSelect == 1 then
                            settings.hardwareCompression = not settings.hardwareCompression
                        elseif settingSelect == 2 then
                            if not settings.showDebug then
                                settings.showDebug = "fps"
                            elseif settings.showDebug == "fps" then
                                settings.showDebug = "detailed" 
                            elseif settings.showDebug == "detailed" then
                                settings.showDebug = false
                            end
                        end
                    end
                end
				audio.playSound(confirmSound)

                confirmFunc()
			elseif input:pressed("back") then
				audio.playSound(selectSound)

                if settingsMenuState == 0 then
                else
                    settingsMenuState = 0
                    settingSelect = 1
                end
            elseif input:pressed("up") then
                if settingsMenuState == 0 then
                    settingSelect = settingSelect ~= 1 and settingSelect - 1 or 5
                elseif settingsMenuState == 1 then
                    settingSelect = settingSelect ~= 1 and settingSelect - 1 or #settingsDescriptions3
                elseif settingsMenuState == 2 then
                    settingSelect = settingSelect ~= 1 and settingSelect - 1 or #settingsDescriptions1
                elseif settingsMenuState == 3 then
                    settingSelect = settingSelect ~= 1 and settingSelect - 1 or #settingsDescriptions2
                end
            elseif input:pressed("down") then
                if settingsMenuState == 0 then
                    settingSelect = settingSelect ~= 5 and settingSelect + 1 or 1
                elseif settingsMenuState == 1 then
                    settingSelect = settingSelect ~= #settingsDescriptions3 and settingSelect + 1 or 1
                elseif settingsMenuState == 2 then
                    settingSelect = settingSelect ~= #settingsDescriptions1 and settingSelect + 1 or 1
                elseif settingsMenuState == 3 then
                    settingSelect = settingSelect ~= #settingsDescriptions3 and settingSelect + 1 or 1           
                end
            elseif input:pressed("right") or (love.keyboard.isDown("lshift") and input:down("right")) then
                if settingsMenuState == 2 then
                    if settingSelect == 6 then
                        settings.customScrollSpeed = settings.customScrollSpeed + 0.05
                    elseif settingSelect == 7 then
                        if settings.scrollUnderlayTrans < 1 then
                            settings.scrollUnderlayTrans = settings.scrollUnderlayTrans + 0.05
                        else
                            settings.scrollUnderlayTrans = 1
                        end
                    elseif settingSelect == 9 then
                        if settings.fpsCap < 500 then
                            settings.fpsCap = settings.fpsCap + 1
                        else
                            settings.fpsCap = 500
                        end
                    end
                end
            elseif input:pressed("left") or (love.keyboard.isDown("lshift") and input:down("left")) then
                if settingsMenuState == 2 then
                    if settingSelect == 6 then
                        if settings.customScrollSpeed > 0.05 then
                            settings.customScrollSpeed = settings.customScrollSpeed - 0.05
                        else
                            settings.customScrollSpeed = 0.05
                        end
                    elseif settingSelect == 7 then
                        if settings.scrollUnderlayTrans > 0 then
                            settings.scrollUnderlayTrans = settings.scrollUnderlayTrans - 0.05
                        else
                            settings.scrollUnderlayTrans = 0
                        end
                    elseif settingSelect == 9 then
                        if settings.fpsCap > 60 then
                            settings.fpsCap = settings.fpsCap - 1
                        else
                            settings.fpsCap = 60
                        end
                    end
                end
			end
		end
        if settings.hardwareCompression ~= settingdata.hardwareCompression then
            isRestartNeeded = "(RESTART REQUIRED)"
        else
            isRestartNeeded = ""
        end

        love.setFpsCap(settings.fpsCap)
	end,

	draw = function(self)
		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)

			love.graphics.push()
                menuBG:draw()

                graphics.setColor(1,1,0)
                if settingsMenuState == 0 then
                    love.graphics.print("Gamemodes", -628, -300)
                    love.graphics.print("\n\nGameplay", -628, -300)
                    love.graphics.print("\n\n\n\nKeybinds", -628, -300)
                    love.graphics.print("\n\n\n\n\n\nMisc.", -628, -300)
                    if settings.hardwareCompression ~= settingdata.hardwareCompression then
                        love.graphics.print("\n\n\n\n\n\n\n\nSave settings & Restart", -628, -300)
                    else
                        love.graphics.print("\n\n\n\n\n\n\n\nSave settings", -628, -300)
                    end
                elseif settingsMenuState == 1 then
                    love.graphics.print("Practice Mode = " .. tostring(settings.practiceMode), -628, -300)
                    love.graphics.print("\n\nNo Miss = " .. tostring(settings.noMiss), -628, -300)
                elseif settingsMenuState == 2 then -- I need a better way for this lmfao
                    love.graphics.print("Downscroll = " .. tostring(settings.downscroll), -628, -300)
                    love.graphics.print("\n\nMiddlescroll = " .. tostring(settings.middleScroll), -628, -300)
                    love.graphics.print("\n\n\n\nGhost Tapping = " .. tostring(settings.ghostTapping), -628, -300)
                    love.graphics.print("\n\n\n\n\n\nSide Judgements = " .. tostring(settings.sideJudgements), -628, -300)
                    love.graphics.print("\n\n\n\n\n\n\n\nBot Play = " .. tostring(settings.botPlay), -628, -300)
                    love.graphics.print("\n\n\n\n\n\n\n\n\n\nCustom Scroll Speed = " .. tostring(settings.customScrollSpeed), -628, -300)
                    love.graphics.print("\n\n\n\n\n\n\n\n\n\n\n\nScroll Underlay Transparency = " .. tostring(settings.scrollUnderlayTrans), -628, -300)
                    love.graphics.print("\n\n\n\n\n\n\n\n\n\n\n\n\n\nFps Limit = " .. tostring(settings.fpsCap), -628, -300)
                    --love.graphics.print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nNoteskin = " .. tostring(noteskins[settings.noteSkins]), -628, -300)
                elseif settingsMenuState == 3 then
                    love.graphics.print("Hardware Compression = " .. tostring(settings.hardwareCompression) .. " " .. isRestartNeeded, -628, -300) 
                    love.graphics.print("\n\nShow Debug = " .. tostring(settings.showDebug), -628, -300)
                end
                love.graphics.print(newlinesMoment[settingSelect] .. ">", -640, -300)
                

                if settingsMenuState ~= 0 then
                    graphics.setColor(0,0,0,0.4)
                    love.graphics.rectangle("fill", -400, 175, 800, 300)
                    graphics.setColor(1,1,1)
                    if settingsMenuState == 1 then
                        love.graphics.printf(settingsDescriptions3[settingSelect], -390, 185, 1000, "left", nil, 0.8, 0.8)
                    elseif settingsMenuState == 2 then
                        love.graphics.printf(settingsDescriptions1[settingSelect], -390, 185, 1000, "left", nil, 0.8, 0.8)
                    elseif settingsMenuState == 3 then
                        love.graphics.printf(settingsDescriptions2[settingSelect], -390, 185, 1000, "left", nil, 0.8, 0.8)
                    end
                end

				love.graphics.scale(camera.zoom, camera.zoom)

				love.graphics.pop()
		love.graphics.pop()
	end,

	leave = function(self)
        saveSettings()

		Timer.clear()
	end
}
