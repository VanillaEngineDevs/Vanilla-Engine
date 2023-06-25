--[[----------------------------------------------------------------------------
Friday Night Funkin' Rewritten v1.1.0 beta 2

Copyright (C) 2021  HTV04

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
------------------------------------------------------------------------------]]
__VERSION__ = love.filesystem.read("version.txt")
if love.filesystem.isFused() then function print() end end -- print functions tend the make the game lag when in update functions, so we do this to prevent that
function uitextflarge(text,x,y,limit,align,hovered,r,sx,sy,ox,oy,kx,ky)
	local x = x or 0
	local y = y or 0
	local r = r or 0
	local limit = limit or 750
	local align = align or "center"
	local hovered = hovered or false
	local sx = sx or 1
	local sy = sy or 1
	local ox = ox or 0
	local oy = oy or 0
	local kx = kx or 0
	local ky = ky or 0
	if not hovered then graphics.setColor(0,0,0) else graphics.setColor(1,1,1) end
	love.graphics.printf(text,x-6,y,limit,align,r,sx,sy,ox,oy,kx,ky)
	love.graphics.printf(text,x+6,y,limit,align,r,sx,sy,ox,oy,kx,ky)
	love.graphics.printf(text,x,y-6,limit,align,r,sx,sy,ox,oy,kx,ky)
	love.graphics.printf(text,x,y+6,limit,align,r,sx,sy,ox,oy,kx,ky)
	if not hovered then graphics.setColor(1,1,1) else graphics.setColor(0,0,0) end
	love.graphics.printf(text,x,y,limit,align,r,sx,sy,ox,oy,kx,ky)
end
function uitextf(text,x,y,limit,align,r,sx,sy,ox,oy,kx,ky,alpha)
	local x = x or 0
	local y = y or 0
	local r = r or 0
	local limit = limit or 750
	local align = align or "left"
	local sx = sx or 1
	local sy = sy or 1
	local ox = ox or 0
	local oy = oy or 0
	local kx = kx or 0
	local ky = ky or 0
	graphics.setColor(0,0,0, alpha or 1)
	love.graphics.printf(text,x-2,y,limit,align,r,sx,sy,ox,oy,kx,ky)
	love.graphics.printf(text,x+2,y,limit,align,r,sx,sy,ox,oy,kx,ky)
	love.graphics.printf(text,x,y-2,limit,align,r,sx,sy,ox,oy,kx,ky)
	love.graphics.printf(text,x,y+2,limit,align,r,sx,sy,ox,oy,kx,ky)
	graphics.setColor(1,1,1, alpha or 1)
    love.graphics.printf(text,x,y,limit,align,r,sx,sy,ox,oy,kx,ky)
end
function uitext(text,x,y,r,sx,sy,ox,oy,kx,ky,alpha)
	local x = x or 0
	local y = y or 0
	local r = r or 0
	local sx = sx or 1
	local sy = sy or 1
	local ox = ox or 0
	local oy = oy or 0
	local kx = kx or 0
	local ky = ky or 0
	graphics.setColor(0,0,0, alpha or 1)
	love.graphics.print(text,x-2,y,r,sx,sy,a,ox,oy,kx,ky)
	love.graphics.print(text,x+2,y,r,sx,sy,a,ox,oy,kx,ky)
	love.graphics.print(text,x,y-2,r,sx,sy,a,ox,oy,kx,ky)
	love.graphics.print(text,x,y+2,r,sx,sy,a,ox,oy,kx,ky)
	graphics.setColor(1,1,1, alpha or 1)
    love.graphics.print(text,x,y,r,sx,sy,a,ox,oy,kx,ky)
end

function borderedText(text,x,y,r,sx,sy,ox,oy,kx,ky,alpha)
	local x = x or 0
	local y = y or 0
	local r = r or 0
	local sx = sx or 1
	local sy = sy or 1
	local ox = ox or 0
	local oy = oy or 0
	local kx = kx or 0
	local ky = ky or 0
	graphics.setColor(0,0,0, alpha or 1)
	love.graphics.print(text,x-1,y,r,sx,sy,a,ox,oy,kx,ky)
	love.graphics.print(text,x+1,y,r,sx,sy,a,ox,oy,kx,ky)
	love.graphics.print(text,x,y-1,r,sx,sy,a,ox,oy,kx,ky)
	love.graphics.print(text,x,y+1,r,sx,sy,a,ox,oy,kx,ky)
	graphics.setColor(1,1,1, alpha or 1)
	love.graphics.print(text,x,y,r,sx,sy,a,ox,oy,kx,ky)
end

function saveSettings()
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
            setImageType = "dds",
            sideJudgements = settings.sideJudgements,
            botPlay = settings.botPlay,
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
			colourByQuantization = settings.colourByQuantization,
            window = settings.window,
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
            setImageType = "dds",
            sideJudgements = settings.sideJudgements,
            botPlay = settings.botPlay,
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
			colourByQuantization = settings.colourByQuantization,

            customBindDown = customBindDown,
            customBindUp = customBindUp,
            customBindLeft = customBindLeft,
            customBindRight = customBindRight,
            settingsVer = settingsVer
        }
        serialized = lume.serialize(settingdata)
        love.filesystem.write("settings", serialized)
        graphics:fadeOutWipe(
            0.7,
            function()
                Gamestate.switch(menuSelect)
                status.setLoading(false)
            end
        )
    end
end
--[[

function love.load() -- Todo, add custom framerate support

end
]]

function love.load()
	paused = false
	settings = {}
	local curOS = love.system.getOS()

	-- Load libraries
	baton = require "lib.baton"
	ini = require "lib.ini"
	lovesize = require "lib.lovesize"
	Gamestate = require "lib.gamestate"
	Timer = require "lib.timer"
	json = require "lib.json"
	lume = require "lib.lume"
	Object = require "lib.classic"
	xml = require "lib.xml".parse

	-- Load modules
	status = require "modules.status"
	audio = require "modules.audio"
	graphics = require "modules.graphics"
	camera = require "modules.camera"
	beatHandler = require "modules.beatHandler"
	util = require "modules.util"
	cutscene = require "modules.cutscene"
	dialogue = require "modules.dialogue"
	settings = require "settings"
	NoteSplash = require "modules.Splash"
	require "modules.savedata"
	loadSavedata()
	
	-- XML Modules
	Sprite = require "modules.xml.Sprite"
	xmlcamera = require "modules.xml.camera"

	playMenuMusic = true

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
			setImageType = "dds",
			sideJudgements = settings.sideJudgements,
			botPlay = settings.botPlay,
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
			colourByQuantization = settings.colourByQuantization,
			settingsVer = settingsVer
		}
		serialized = lume.serialize(settingdata)
		love.filesystem.write("settings", serialized)
	end
	if settingsVer ~= 2 then
		love.window.showMessageBox("Uh Oh!", "Settings have been reset.", "warning")
		love.filesystem.remove("settings")
	end
	if not love.filesystem.getInfo("settings") or settingsVer ~= 2 then
		settings.hardwareCompression = true
		graphics.setImageType("dds")
		settings.downscroll = false
		settings.middleScroll = false
		settings.ghostTapping = false
		settings.showDebug = false
		settings.sideJudgements = false
		settings.botPlay = false
		settings.practiceMode = false
		settings.noMiss = false
		settings.customScrollSpeed = 1
		settings.keystrokes = false
		settings.scrollUnderlayTrans = 0
		settings.colourByQuantization = false
		--settings.noteSkins = 1
		customBindLeft = "a"
		customBindRight = "d"
		customBindUp = "w"
		customBindDown = "s"
	
		settings.flashinglights = false
		settingsVer = 2
		settingdata = {}
		settingdata = {
			hardwareCompression = settings.hardwareCompression,
			downscroll = settings.downscroll,
			ghostTapping = settings.ghostTapping,
			showDebug = settings.showDebug,
			setImageType = "dds",
			sideJudgements = settings.sideJudgements,
			botPlay = settings.botPlay,
			middleScroll = settings.middleScroll,
			practiceMode = settings.practiceMode,
			noMiss = settings.noMiss,
			customScrollSpeed = settings.customScrollSpeed,
			keystrokes = settings.keystrokes,
			scrollUnderlayTrans = settings.scrollUnderlayTrans,
			colourByQuantization = settings.colourByQuantization,

			customBindLeft = "a",
			customBindRight = "d",
			customBindUp = "w",
			customBindDown = "s",
			
			settingsVer = settingsVer
		}
		serialized = lume.serialize(settingdata)
		love.filesystem.write("settings", serialized)
	end

	volumeWidth = {width = 160}
	volFade = 0

	-- Load settings
	--settings = require "settings"
	input = require "input"

	-- Load Debugs
	debugMenu = require "states.debug.debugMenu"
	spriteDebug = require "states.debug.sprite-debug"
	stageDebug = require "states.debug.stage-debug"

	-- Sounds
	selectSound = love.audio.newSource("sounds/menu/select.ogg", "static")
	confirmSound = love.audio.newSource("sounds/menu/confirm.ogg", "static")

	-- Load stages
	stages = {
		["stage"] = require "stages.stage",
		["hauntedHouse"] = require "stages.hauntedHouse",
		["city"] = require "stages.city",
		["sunset"] = require "stages.sunset",
		["mall"] = require "stages.mall",
		["school"] = require "stages.school",
		["evilSchool"] = require "stages.evilSchool",
		["tank"] = require "stages.tank"
	}

	-- Load Menus
	clickStart = require "states.click-start"
	menu = require "states.menu.menu"
	menuWeek = require "states.menu.menuWeek"
	menuFreeplay = require "states.menu.menuFreeplay"
	menuSettings = require "states.menu.menuSettings"
	menuCredits = require "states.menu.menuCredits"
	menuSelect = require "states.menu.menuSelect"

	firstStartup = true

	-- Load weeks
	weeks = require "states.weeks"

	-- Load substates
	gameOver = require "substates.game-over"
	settingsKeybinds = require "substates.settings-keybinds"

	-- Load week data
	weekData = {
		require "weeks.tutorial",
		require "weeks.week1",
		require "weeks.week2",
		require "weeks.week3",
		require "weeks.week4",
		require "weeks.week5",
		require "weeks.week6",
		require "weeks.week7"
	}

	weekDesc = { -- Add your week description here
		"LEARN TO FUNK",
		"DADDY DEAREST",
		"SPOOKY MONTH",
		"PICO",
		"MOMMY MUST MURDER",
		"RED SNOW",
		"HATING SIMULATOR FT. MOAWLING",
		"TANKMAN"
	}

	weekDesc = { -- Add your week description here
		"LEARN TO FUNK",
		"DADDY DEAREST",
		"SPOOKY MONTH",
		"PICO",
		"MOMMY MUST MURDER",
		"RED SNOW",
		"HATING SIMULATOR FT. MOAWLING",
		"TANKMAN"
	}
	weekMeta = { -- Add/remove weeks here
		{
			"Tutorial",
			{
				"Tutorial"
			}
		},
		{
			"Week 1",
			{
				"Bopeebo",
				"Fresh",
				"Dadbattle"
			}
		},
		{
			"Week 2",
			{
				"Spookeez",
				"South",
				"Monster"
			}
		},
		{
			"Week 3",
			{
				"Pico",
				"Philly Nice",
				"Blammed"
			}
		},
		{
			"Week 4",
			{
				"Satin Panties",
				"High",
				"M.I.L.F"
			}
		},
		{
			"Week 5",
			{
				"Cocoa",
				"Eggnog",
				"Winter Horrorland"
			}
		},
		{
			"Week 6",
			{
				"Senpai",
				"Roses",
				"Thorns"
			},
		},
		{
			"Week 7",
			{
				"Ugh",
				"Guns",
				"Stress"
			}
		}
	}

	-- LÖVE init
	if curOS == "OS X" then
		love.window.setIcon(love.image.newImageData("icons/macos.png"))
	else
		love.window.setIcon(love.image.newImageData("icons/default.png"))
	end

	lovesize.set(1280, 720)

	function hex2rgb(hex)
		hex = hex:gsub("#",""):gsub("0x","")
		local r = hex:sub(1,2) 
		local g = hex:sub(3,4)
		local b = hex:sub(5,6)

		hexR = tonumber("0x".. r)
		hexG = tonumber("0x".. g)
		hexB = tonumber("0x".. b)
		return {hexR/255, hexG/255, hexB/255}
	end

	-- Variables
	font = love.graphics.newFont("fonts/vcr.ttf", 24)
	FNFFont = love.graphics.newFont("fonts/fnFont.ttf", 24)
	credFont = love.graphics.newFont("fonts/fnFont.ttf", 32)   -- guglio is a bitch 
	uiFont = love.graphics.newFont("fonts/Dosis-SemiBold.ttf", 32)
	pauseFont = love.graphics.newFont("fonts/Dosis-SemiBold.ttf", 96)
	weekFont = love.graphics.newFont("fonts/Dosis-SemiBold.ttf", 84)
	weekFontSmall = love.graphics.newFont("fonts/Dosis-SemiBold.ttf", 54)

	weekNum = 1
	songDifficulty = 2

	storyMode = false
	countingDown = false

	uiScale = {zoom = 1, x = 1, y = 1, sizeX = 1, sizeY = 1}

	musicTime = 0
	health = 0

	music = love.audio.newSource("music/menu/menu.ogg", "stream")
	music:setLooping(true)

	fixVol = tonumber(string.format(
		"%.1f  ",
		(love.audio.getVolume())
	))

	-- mod folder stuff
	modweek = require "mods.week"
	modfolder = require "mods.folder"

	if curOS == "Web" then
		Gamestate.switch(clickStart)
	else
		Gamestate.switch(menu)
	end
end

function love.resize(width, height)
	lovesize.resize(width, height)
end

function love.keypressed(key)
	if key == "6" then
		love.filesystem.createDirectory("screenshots")

		love.graphics.captureScreenshot("screenshots/" .. os.time() .. ".png")
	elseif key == "7" then
		Gamestate.switch(debugMenu)
	elseif key == "0" then
		volFade = 1
		if fixVol == 0 then
			love.audio.setVolume(lastAudioVolume)
		else
			lastAudioVolume = love.audio.getVolume()
			love.audio.setVolume(0)
		end
	elseif key == "-" then
		volFade = 1
		if fixVol > 0 then
			love.audio.setVolume(love.audio.getVolume() - 0.1)
		end
	elseif key == "=" then
		volFade = 1
		if fixVol <= 0.9 then
			love.audio.setVolume(love.audio.getVolume() + 0.1)
		end
    else
		Gamestate.keypressed(key)
	end
end

function love.textinput(t)
	Gamestate.textinput(t)
end

function love.mousepressed(x, y, button, istouch, presses)
	Gamestate.mousepressed(x, y, button, istouch, presses)
end

function love.update(dt)
	dt = math.min(dt, 1 / 30)

	if volFade > 0 then
		volFade = volFade - 1 * dt
	end

	input:update()

	if status.getNoResize() then
		Gamestate.update(dt)
	else
		love.graphics.setFont(font)
		graphics.screenBase(lovesize.getWidth(), lovesize.getHeight())
		graphics.setColor(1, 1, 1) -- Fade effect on
		Gamestate.update(dt)
		love.graphics.setColor(1, 1, 1) -- Fade effect off
		graphics.screenBase(love.graphics.getWidth(), love.graphics.getHeight())
		love.graphics.setFont(font)
	end

	Timer.update(dt)
end

function love.draw()
	love.graphics.setFont(font)
	graphics.screenBase(lovesize.getWidth(), lovesize.getHeight())

	lovesize.begin()
		graphics.setColor(1, 1, 1) -- Fade effect on
		Gamestate.draw()
		love.graphics.setColor(1, 1, 1) -- Fade effect off
		love.graphics.setFont(font)
		if status.getLoading() then
			love.graphics.print("Loading...", lovesize.getWidth() - 175, lovesize.getHeight() - 50)
		end
		if volFade > 0  then
			love.graphics.setColor(1, 1, 1, volFade)
			fixVol = tonumber(string.format(
				"%.1f  ",
				(love.audio.getVolume())
			))
			love.graphics.setColor(0.5, 0.5, 0.5, volFade - 0.3)

			love.graphics.rectangle("fill", 1110, 0, 170, 50)

			love.graphics.setColor(1, 1, 1, volFade)

			if volTween then Timer.cancel(volTween) end
			volTween = Timer.tween(
				0.2, 
				volumeWidth, 
				{width = fixVol * 160},
				"out-quad"
			)
			love.graphics.rectangle("fill", 1113, 10, volumeWidth.width, 30)
			graphics.setColor(1, 1, 1, 1)
		end
		if fade.mesh then 
			graphics.setColor(1,1,1)
			love.graphics.draw(fade.mesh, 0, fade.y, 0, lovesize.getWidth(), fade.height)
		end
	lovesize.finish()

	graphics.screenBase(love.graphics.getWidth(), love.graphics.getHeight())

	-- Debug output
	if settings.showDebug then
		borderedText(status.getDebugStr(settings.showDebug), 5, 5, nil, 0.6, 0.6)
	end
end

function love.focus(t)
	Gamestate.focus(t)
end

function love.quit()
	saveSavedata()
end