---@diagnostic disable: param-type-mismatch

__VERSION__ = love.filesystem.read("version.txt")
if love.filesystem.isFused() then function print() end end

local capturedScreenshot = {x=0, y=0, flash=0, alpha=0, img=nil, hovered=false, timers={}}
local mouseTimer, mouseTimerReset, mainDrawing = 0, 0.5, true

function songNameToFolder(str)
    return str:gsub(" ", "-"):lower()
end

require "modules.overrides"
require "modules.uitext"

function love.load()
    paused = false
    settings = {}
    curOS = love.system.getOS()

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
    require "lib.loveanimate"

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

    BaseCharacter = require "data.characters.BaseCharacter"
    NeneCharacter = require "data.characters.NeneCharacter"
    PixelNeneCharacter = require "data.characters.PixelNeneCharacter"
    BFDarkCharacter = require "data.characters.BFDarkCharacter"
    GFDarkCharacter = require "data.characters.GFDarkCharacter"
    PicoDarkCharacter = require "data.characters.PicoDarkCharacter"
    NeneDarkCharacter = require "data.characters.NeneDarkCharacter"
    SpookyDarkCharacter = require "data.characters.SpookyDarkCharacter"

    importMods = require "modding.importMods"

    Sprite = require "modules.xml.Sprite"
    xmlcamera = require "modules.xml.camera"
    Checkbox = require "modules.Checkbox"

    playMenuMusic = true
    graphics.setImageType(love.filesystem.read("IMAGE_FORMAT.txt"))
    volumeWidth = {width = 160}
    volFade = 0

    input = require "input"

    debugMenu = require "states.debug.debugMenu"
    spriteDebug = require "states.debug.sprite-debug"
    stageDebug = require "states.debug.stage-debug"
    frameDebug = require "states.debug.frame-debug"
    stageBuilder = require "states.debug.stage-builder"

    selectSound = love.audio.newSource("sounds/menu/select.ogg", "static")
    confirmSound = love.audio.newSource("sounds/menu/confirm.ogg", "static")

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

    noteTypes = {
        ["normal"] = require "notetypes.normal",
        ["Hurt Note"] = require "notetypes.hurt"
    }

    shaders = {}
    if curOS ~= "NX" then 
        shaders["rain"] = love.graphics.newShader("shaders/rain.glsl")
    end
    shaders["wiggle"] = love.graphics.newShader("shaders/wiggle.glsl")

    menu = require "states.menu.menu"
    menuWeek = require "states.menu.menuWeek"
    menuFreeplay = require "states.menu.menuFreeplay"
    menuSettings = require "states.menu.options.OptionsState"
    menuCredits = require "states.menu.menuCredits"
    menuSelect = require "states.menu.menuSelect"
    menuMods = require "states.menu.menuMods"
    resultsScreen = require "states.menu.results"

    firstStartup = true
    weeks = require "states.weeks"

    OptionsMenu = require "states.menu.options.OptionsMenu"
    gameOvers = {
        default = require "substates.gameovers.boyfriend",
        week7Default = require "substates.gameovers.boyfriend-week7",
        pixelDefault = require "substates.gameovers.boyfriend-pixel"
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
    weekData = require "data.weeks.weekData"
    weekDesc = require "data.weeks.weekDescriptions"
    weekMeta = require "data.weeks.weekMeta"

    for _, week in ipairs(weekMeta) do
        for _, song in ipairs(week[2]) do
            if type(song) == "table" then
                song.show = song.show or true
                if not song.diffs then
                    song.diffs = {{"easy", ext=""}, {"normal", ext=""}, {"hard", ext=""}}
                else
                    for _, v in ipairs(song.diffs) do v.ext = v[2] end
                end
            end
        end
    end
    modWeekPlacement = #weekMeta - 1

    gameOverSounds = {
        boyfriend = {firstDeath = love.audio.newSource("sounds/death.ogg", "static")}
    }

    require "modules.extras"
    __VERSION__ = love.filesystem.getInfo("version.txt") and love.filesystem.read("version.txt") or "vUnknown"

    if curOS == "OS X" then
        love.window.setIcon(love.image.newImageData("icons/macos.png"))
    else
        love.window.setIcon(love.image.newImageData("icons/default.png"))
    end

    push.setupScreen(1280, 720, {upscale="normal", canvas = true})

    function hex2rgb(hex)
        if type(hex) == "string" then
            hex = hex:gsub("#",""):gsub("0x","")
            return {
                tonumber("0x"..hex:sub(1,2))/255,
                tonumber("0x"..hex:sub(3,4))/255,
                tonumber("0x"..hex:sub(5,6))/255
            }
        else
            return {
                bit.band(bit.rshift(hex, 16), 0xff)/255,
                bit.band(bit.rshift(hex, 8), 0xff)/255,
                bit.band(hex, 0xff)/255
            }
        end
    end

    font = love.graphics.newFont("fonts/vcr.ttf", 24)
    scoringFont = love.graphics.newFont("fonts/vcr.ttf", 26)
    psychScoringFont = love.graphics.newFont("fonts/vcr.ttf", 36)
    optionsFont = love.graphics.newFont("fonts/vcr.ttf", 32)
    FNFFont = love.graphics.newFont("fonts/fnFont.ttf", 24)
    credFont = love.graphics.newFont("fonts/fnFont.ttf", 32)
    uiFont = love.graphics.newFont("fonts/Dosis-SemiBold.ttf", 32)
    pauseFont = love.graphics.newFont("fonts/Dosis-SemiBold.ttf", 96)
    weekFont = love.graphics.newFont("fonts/Dosis-SemiBold.ttf", 84)
    weekFontSmall = love.graphics.newFont("fonts/Dosis-SemiBold.ttf", 54)

    weekNum = 1
    songDifficulty = 2
    storyMode = false
    countingDown = false
    uiCam = {zoom = 1, x = 1, y = 1, sizeX = 1, sizeY = 1}
    musicTime, health = 0, 0

    music = love.audio.newSource("music/menu/menu.ogg", "stream")
    music:setLooping(true)

    fixVol = tonumber(string.format("%.1f", love.audio.getVolume()))
    volumeWidth = {width = 160}

    if CONSTANTS.OPTIONS.DO_MODS then
        importMods.setup()
        importMods.loadAllMods()
    end

    love.audio.setVolume(0.1)
    Gamestate.switch(menu)
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