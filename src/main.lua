---@diagnostic disable: param-type-mismatch
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
--[[ if love.filesystem.isFused() then 
	function print() end 
else
	_debug = true
end ]]debug=true -- print functions tend the make the game lag when in update functions, so we do this to prevent that
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
	for i = -6, 6 do
		for j = -6, 6 do
			love.graphics.printf(text,x+i,y+j,limit,align,r,sx,sy,ox,oy,kx,ky)
		end
	end
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
	for i = -2, 2 do
		for j = -2, 2 do
			love.graphics.printf(text,x+i,y+j,limit,align,r,sx,sy,ox,oy,kx,ky)
		end
	end
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
	for i = -1, 1 do
		for j = -1, 1 do
			love.graphics.print(text,x+i,y+j,r,sx,sy,ox,oy,kx,ky)
		end
	end
	graphics.setColor(1,1,1, alpha or 1)
	love.graphics.print(text,x,y,r,sx,sy,ox,oy,kx,ky)
end
function uitextColored(text,x,y,r,col1,col2,sx,sy,ox,oy,kx,ky)
	local x = x or 0
	local y = y or 0
	local r = r or 0
	local sx = sx or 1
	local sy = sy or 1
	local ox = ox or 0
	local oy = oy or 0
	local kx = kx or 0
	local ky = ky or 0
	local col1 = col1 or {0,0,0,1}
	local col2 = col2 or {1,1,1,1}
	graphics.setColor(col1[1],col1[2],col1[3],col1[4])
	for i = -1, 1 do
		for j = -1, 1 do
			love.graphics.print(text,x+i,y+j,r,sx,sy,ox,oy,kx,ky)
		end
	end
	graphics.setColor(col2[1],col2[2],col2[3],col2[4])
	love.graphics.print(text,x,y,r,sx,sy,ox,oy,kx,ky)
end
function uitextfColored(text,x,y,limit,align,col1,col2,r,sx,sy,ox,oy,kx,ky)
	local x = x or 0
	local y = y or 0
	local r = r or 0
	local limit = limit or 750
	local align = align or "center"
	local sx = sx or 1
	local sy = sy or 1
	local ox = ox or 0
	local oy = oy or 0
	local kx = kx or 0
	local ky = ky or 0
	graphics.setColor(col1[1],col1[2],col1[3],col1[4])
	for i = -1, 1 do
		for j = -1, 1 do
			love.graphics.printf(text,x+i,y+j,limit,align,r,sx,sy,ox,oy,kx,ky)
		end
	end
	graphics.setColor(col2[1],col2[2],col2[3],col2[4])
	love.graphics.printf(text,x,y,limit,align,r,sx,sy,ox,oy,kx,ky)
end

local capturedScreenshot = {
	x = 0,
	y = 0,
	flash = 0,
	alpha = 0,
	img = nil,
	hovered = false,
	timers = {}
}

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
	for i = -1, 1 do
		for j = -1, 1 do
			love.graphics.print(text,x+i,y+j,r,sx,sy,ox,oy,kx,ky)
		end
	end
	graphics.setColor(1,1,1, alpha or 1)
	love.graphics.print(text,x,y,r,sx,sy,ox,oy,kx,ky)
end

function songNameToFolder(str)
	str = str:gsub(" ", "-")
	str = str:lower()
	
	return str
end

mainDrawing = true

require "modules.overrides"

local mouseTimer = 0
local mouseTimerReset = 0.5

function love.load()
	paused = false
	settings = {}
	curOS = love.system.getOS()

	-- Load libraries
	baton = require "lib.baton"
	ini = require "lib.ini"
	push = require "lib.push"
	Gamestate = require "lib.gamestate"
	Timer = require "lib.timer"
	json = require "lib.json"
	lume = require "lib.lume"
	Object = require "lib.classic"
	xml = require "lib.xml"
	lovefftINST = require "lib.fft.lovefft"
	require("lib.loveanimate")

	-- Load modules
	status = require "modules.status"
	audio = require "modules.audio"
	graphics = require "modules.graphics"
	icon = require "modules.Icon"
	camera = require "modules.camera"
	beatHandler = require "modules.beatHandler"
	Conductor = require "modules.Conductor"
	util = require "modules.util"
	cutscene = require "modules.cutscene"
	dialogue = require "modules.dialogue"
	Group = require "modules.Group"
	require "modules.savedata"
	require "modules.Alphabet"
	Option = require "modules.Option"
	CONSTANTS = require "modules.constants"
	NoteSplash = require "modules.Splash"
	HoldCover = require "modules.Cover"
	waveform = require "modules.waveform"
	popupScore = require "modules.popupScore"
	settings.pixelPerfect = false

	-- Load Characters
	BaseCharacter = require "data.characters.BaseCharacter"
	NeneCharacter = require "data.characters.NeneCharacter"
	PixelNeneCharacter = require "data.characters.PixelNeneCharacter"
	BFDarkCharacter = require "data.characters.BFDarkCharacter"
	GFDarkCharacter = require "data.characters.GFDarkCharacter"
	PicoDarkCharacter = require "data.characters.PicoDarkCharacter"
	NeneDarkCharacter = require "data.characters.NeneDarkCharacter"
	SpookyDarkCharacter = require "data.characters.SpookyDarkCharacter"

	-- Modding
	importMods = require "modding.importMods"

	-- XML Modules
	Sprite = require "modules.xml.Sprite"
	xmlcamera = require "modules.xml.camera"
	Checkbox = require "modules.Checkbox"

	playMenuMusic = true

	-- disable vsync
	love.window.setVSync(0)

	graphics.setImageType(love.filesystem.read("IMAGE_FORMAT.txt"))

	volumeWidth = {width = 160}
	volFade = 0

	-- Load settings
	input = require "input"

	-- Load Debugs
	debugMenu = require "states.debug.debugMenu"
	spriteDebug = require "states.debug.sprite-debug"
	stageDebug = require "states.debug.stage-debug"
	frameDebug = require "states.debug.frame-debug"
	stageBuilder = require "states.debug.stage-builder"

	-- Sounds
	selectSound = love.audio.newSource("sounds/menu/select.ogg", "static")
	confirmSound = love.audio.newSource("sounds/menu/confirm.ogg", "static")

	-- Load stages
	stages = {
		["stage.base"] = require "stages.base.stage",
		["hauntedHouse.base"] = require "stages.base.hauntedHouse",
		["city.base"] = require "stages.base.city",
		["sunset.base"] = require "stages.base.sunset",
		["mall.base"] = require "stages.base.mall",
		["school.base"] = require "stages.base.school",
		["evilSchool.base"] = require "stages.base.evilSchool",
		["tank.base"] = require "stages.base.tank",
		["streets.base"] = require "stages.base.streets",

		["stage.erect"] = require "stages.erect.stage",
		["hauntedHouse.erect"] = require "stages.erect.hauntedHouse",
		["city.erect"] = require "stages.erect.city",
		["sunset.erect"] = require "stages.erect.sunset",
		["mall.erect"] = require "stages.erect.mall",
		["school.erect"] = require "stages.erect.school",
		["evilSchool.erect"] = require "stages.erect.evilSchool",
		["tank.erect"] = require "stages.erect.tank",
		["streets.erect"] = require "stages.erect.streets"
	}

	-- Load Note types
	noteTypes = {
		["normal"] = require "notetypes.normal",
		["Hurt Note"] = require "notetypes.hurt"
	}

	shaders = {}
	if love.system.getOS() ~= "NX" then 
		shaders["rain"] = love.graphics.newShader("shaders/rain.glsl")
	end
	shaders["wiggle"] = love.graphics.newShader("shaders/wiggle.glsl")
	--[[ shaders["dropShadow"] = love.graphics.newShader("shaders/dropShadow.glsl") ]]

	-- Load Menus
	menu = require "states.menu.menu"
	menuWeek = require "states.menu.menuWeek"
	menuFreeplay = require "states.menu.menuFreeplay"
	menuSettings = require "states.menu.options.OptionsState"
	menuCredits = require "states.menu.menuCredits"
	menuSelect = require "states.menu.menuSelect"
	menuMods = require "states.menu.menuMods"
	resultsScreen = require "states.menu.results"

	firstStartup = true

	-- Load weeks
	weeks = require "states.weeks"

	-- Load substates
	OptionsMenu = require "states.menu.options.OptionsMenu"
	gameOvers = {
		default = require "substates.gameovers.boyfriend",
		week7Default = require "substates.gameovers.boyfriend-week7",
		pixelDefault = require "substates.gameovers.boyfriend-pixel",
	}
	settingsKeybinds = require "substates.settings-keybinds"
	optionSubstates = {
		["Gamemodes"] = require "substates.options.gamemodes",
		["Gameplay"] = require "substates.options.gameplay",
		["Graphics"] = require "substates.options.graphics",
		["Controls"] = require "substates.settings-keybinds",
		["Miscillaneous"] = require "substates.options.miscillaneous"
	}

	TankmanDatingSim = require "misc.dating"

	-- Load week data
	weekData = require "data.weeks.weekData"
	weekDesc = require "data.weeks.weekDescriptions"
	weekMeta = require "data.weeks.weekMeta"
	for i, week in ipairs(weekMeta) do
		for k, song in ipairs(week[2]) do
			if type(song) == "table" then
				if song.show == nil then
					song.show = true
				end
				if song.diffs == nil then
					song.diffs = {{"easy", ext=""}, {"normal", ext=""}, {"hard", ext=""}}
				else
					for _, v in ipairs(song.diffs) do
						v.ext = v[2]
					end
				end
			end
		end
	end
	modWeekPlacement = #weekMeta-1 -- everything after the main weeks is a mod folder.

	gameOverSounds = {
		boyfriend = {
			firstDeath = love.audio.newSource("sounds/death.ogg", "static"),
		}
	}

	require "modules.extras"

	__VERSION__ = love.filesystem.getInfo("version.txt") and love.filesystem.read("version.txt") or "vUnknown"

	-- LÖVE init
	if curOS == "OS X" then
		love.window.setIcon(love.image.newImageData("icons/macos.png"))
	else
		love.window.setIcon(love.image.newImageData("icons/default.png"))
	end

	push.setupScreen(1280, 720, {upscale="normal", canvas = true})

	function hex2rgb(hex)
		if type(hex) == "string" then
			hex = hex:gsub("#",""):gsub("0x","")
			local r = hex:sub(1,2) 
			local g = hex:sub(3,4)
			local b = hex:sub(5,6)

			hexR = tonumber("0x".. r)
			hexG = tonumber("0x".. g)
			hexB = tonumber("0x".. b)
			return {hexR/255, hexG/255, hexB/255}
		else
			-- sometimes it can be given as 0xffe7e6e6
			local r = bit.band(bit.rshift(hex, 16), 0xff)/255
			local g = bit.band(bit.rshift(hex, 8), 0xff)/255
			local b = bit.band(hex, 0xff)/255
			return {r, g, b}
		end
	end

	-- Variables
	font = love.graphics.newFont("fonts/vcr.ttf", 24)
	scoringFont = love.graphics.newFont("fonts/vcr.ttf", 26)
	psychScoringFont = love.graphics.newFont("fonts/vcr.ttf", 36)
	optionsFont = love.graphics.newFont("fonts/vcr.ttf", 32)
	FNFFont = love.graphics.newFont("fonts/fnFont.ttf", 24)
	credFont = love.graphics.newFont("fonts/fnFont.ttf", 32)   -- guglio is a bitch -- fuck you calling a bitch????
	uiFont = love.graphics.newFont("fonts/Dosis-SemiBold.ttf", 32)
	pauseFont = love.graphics.newFont("fonts/Dosis-SemiBold.ttf", 96)
	weekFont = love.graphics.newFont("fonts/Dosis-SemiBold.ttf", 84)
	weekFontSmall = love.graphics.newFont("fonts/Dosis-SemiBold.ttf", 54)

	weekNum = 1
	songDifficulty = 2

	storyMode = false
	countingDown = false

	uiCam = {zoom = 1, x = 1, y = 1, sizeX = 1, sizeY = 1}

	musicTime = 0
	health = 0

	music = love.audio.newSource("music/menu/menu.ogg", "stream")
	music:setLooping(true)

	fixVol = tonumber(string.format(
		"%.1f  ",
		(love.audio.getVolume())
	))

	volumeWidth = {width = 160 }

	if CONSTANTS.OPTIONS.DO_MODS then
		importMods.setup()
		importMods.loadAllMods()
	end

	--[[ graphics:initStickerData() ]]

	love.audio.setVolume(0.1)

	Gamestate.switch(menu)
	--Gamestate.switch(weekData[7], 1, "hard", "-pico", "-pico")
end

function love.resize(width, height)
	push.resize(width, height)
end

function love.filedropped(file)
	Gamestate.filedropped(file)
end

function love.keypressed(key)
	if key == "f3" then
		love.filesystem.createDirectory("screenshots")

		love.graphics.captureScreenshot(function(capture)
			local screenshotName = "screenshot-"
			local date = os.date("*t", os.time())
			screenshotName = screenshotName .. string.format("%d-%02d-%02d-%02d-%02d-%02d", date.year, date.month, date.day, date.hour, date.min, date.sec) .. ".png"
			capture:encode("png", string.format("screenshots/" .. screenshotName))
			capturedScreenshot.img = love.graphics.newImage(capture)
			capturedScreenshot.y = -160 / 4
			capturedScreenshot.alpha = 0
			for i = 1, #capturedScreenshot.timers do
				Timer.cancel(capturedScreenshot.timers[i])
			end

			capturedScreenshot.timers[1] = Timer.tween(
				0.25,
				capturedScreenshot,
				{alpha = 1, y = 0},
				"out-quad",
				function()
					capturedScreenshot.timers[2] = Timer.after(
						1.5,
						function()
							Timer.tween(
								0.25,
								capturedScreenshot,
								{alpha = 0, y = 160 / 4},
								"in-quad",
								function()
									capturedScreenshot.img = nil
								end
							)
						end
					)
				end
			)
		end)
	elseif key == "7" and not love.keyboard.isDown("lalt") then
		Gamestate.switch(debugMenu)
	elseif key == "`" and love.keyboard.isDown("lalt") then
		status.setLoading(true)
		graphics:fadeOutWipe(
			0.7,
			function()
				music:stop()
				Gamestate.switch(TankmanDatingSim)
				status.setLoading(false)
			end
		)
	elseif key == "0" then
		volFade = 1
		if fixVol == 0 then
			love.audio.setVolume(lastAudioVolume)
		else
			lastAudioVolume = love.audio.getVolume()
			love.audio.setVolume(0)
		end
	--[[ elseif key == "-" and love.keyboard.isDown("lalt") then
		Gamestate.switch(resultsScreen, {
			diff = "hard",
			song = "High Erect",
			artist = "Kohta Takahashi (feat. Kawai Sprite)",
			scores = {
				sickCount = 10,
				goodCount = 15,
				badCount = 20,
				shitCount = 25,
				missedCount = 30,
				maxCombo = 384,
				score = 192000
			}
		}) ]]
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

	if capturedScreenshot.img then
		if capturedScreenshot.hovered then
			love.system.openURL("file://" .. love.filesystem.getSaveDirectory() .. "/screenshots")
		end
	end
end

function love.mousereleased(x, y, button, istouch, presses)
	Gamestate.mousereleased(x, y, button, istouch, presses)
end

function love.mousemoved(x, y, dx, dy, istouch)
	Gamestate.mousemoved(x, y, dx, dy, istouch)

	if capturedScreenshot.img then
		capturedScreenshot.hovered = x > capturedScreenshot.x and x < capturedScreenshot.x + 320 and y > capturedScreenshot.y and y < capturedScreenshot.y + 180
	end

	love.mouse.setVisible(true)
	mouseTimer = 0
end

function love.wheelmoved(x, y)
	Gamestate.wheelmoved(x, y)
end

function love.touchpressed(id, x, y, dx, dy, pressure)
	Gamestate.touchpressed(id, x, y, dx, dy, pressure)
end

function love.touchmoved(id, x, y, dx, dy, pressure)
	Gamestate.touchmoved(id, x, y, dx, dy, pressure)
end

function love.update(dt)
	if volFade > 0 then
		volFade = volFade - 1 * dt
	end

	mouseTimer = mouseTimer + dt

	if mouseTimer > mouseTimerReset and love.mouse.isVisible() then
		love.mouse.setVisible(false)
	end

	input:update()

	if status.getNoResize() then
		Gamestate.update(dt)
	else
		love.graphics.setFont(font)
		graphics.screenBase(push:getWidth(), push:getHeight())
		graphics.setColor(1, 1, 1) -- Fade effect on
		Gamestate.update(dt)
		love.graphics.setColor(1, 1, 1) -- Fade effect off
		graphics.screenBase(love.graphics.getWidth(), love.graphics.getHeight())
		love.graphics.setFont(font)
	end

	Timer.update(dt)
end

function love.draw(dt) -- love.draw has its own delta time
	love.graphics.setFont(font)
	graphics.screenBase(push:getWidth(), push:getHeight())

	if mainDrawing then
		if not status.getNoResize() then
			push:start()
				graphics.setColor(1, 1, 1) -- Fade effect on
				Gamestate.draw(dt)
				love.graphics.setColor(1, 1, 1) -- Fade effect off
				love.graphics.setFont(font)
				if status.getLoading() then
					love.graphics.print("Loading...", push:getWidth() - 175, push:getHeight() - 50)
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
					love.graphics.draw(fade.mesh, 0, fade.y, 0, push:getWidth(), fade.height)
				end
				graphics:drawStickers()
			push:finish()
		else
			graphics.setColor(1, 1, 1) -- Fade effect on
			Gamestate.draw()
			love.graphics.setColor(1, 1, 1) -- Fade effect off
			love.graphics.setFont(font)
			if status.getLoading() then
				love.graphics.print("Loading...", graphics.getWidth() - 175, graphics.getHeight() - 50)
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
				love.graphics.draw(fade.mesh, 0, fade.y, 0, graphics.getWidth(), fade.height)
			end
			graphics:drawStickers()
		end


		graphics.setColor(1,1,1,capturedScreenshot.flash)
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
		graphics.setColor(1,1,1,1)

		if capturedScreenshot.img and capturedScreenshot.alpha > 0 then
			graphics.setColor(1, 1, 1, capturedScreenshot.alpha * (capturedScreenshot.hovered and 0.45 or 1))
			love.graphics.draw(capturedScreenshot.img, capturedScreenshot.x, capturedScreenshot.y, 0, (320 / capturedScreenshot.img:getWidth()), (180 / capturedScreenshot.img:getHeight()))
		end
	end

	graphics.screenBase(love.graphics.getWidth(), love.graphics.getHeight())
	if not mainDrawing then
		Gamestate.draw()
	end
	-- Debug output
	if settings.showDebug and Gamestate.current() ~= stageBuilder then
		borderedText(status.getDebugStr(settings.showDebug), 5, 5, nil, 0.6, 0.6)
	end
end

function love.focus(t)
	Gamestate.focus(t)
end

function love.quit()
	if settings.lastDEBUGOption then
		settings.showDebug = settings.lastDEBUGOption
	end
	saveSettings(false)
	saveSavedata()
end