local stage

return {
	enter = function(self, from, songNum, songAppend, _songExt, _audioAppend)
		weeks:enter()

		song = songNum
		difficulty = songAppend
		songExt = _songExt
		audioAppend = _audioAppend

		self:load()
	end,

	load = function(self, DONT_GENERATE)
		weeks:load(not DONT_GENERATE)
		if not DONT_GENERATE then
			self:initUI()
		end
        inst = love.audio.newSource("songs/spaghetti/Inst.mp3", "stream")
        voicesBF = love.audio.newSource("songs/spaghetti/Voices-sserafim-sakura.mp3", "stream")

		weeks:setupCountdown()
	end,

	initUI = function(self)
		weeks:initUI()

		weeks:generateNotes("data/songs/spaghetti/spaghetti-chart" .. songExt .. ".json", "data/songs/spaghetti/spaghetti-metadata" .. songExt .. ".json", difficulty)
	end,

	update = function(self, dt)
		weeks:update(dt)

		weeks:checkSongOver()

		weeks:updateUI(dt)
	end,

    onEvent = function(self, event)
        if event.name == "sserafimSing" then
			weeks.stage.script:setGirlsSinging(event.value.singing)
		elseif event.name == "sserafimShow" then
			weeks.stage.script:setGirlsVisible(event.value.visible)
		elseif event.name == "sserafimGuitarVibration" then
			hapticUtil:increasingVibrate(0.25, 1/2, event.value.duration)
		elseif event.name == "sserafimDark" then
			weeks.stage.script:setDarkenAmt(event.value.amount, event.value.duration)
		elseif event.name == "sserafimLights" then
			weeks.stage.script:flashTruckLights(event.value.amount, event.value.duration)
		elseif event.name == "sserafimCover" then
			weeks.stage.script:setCoverVisible(event.value.visible)
		elseif event.name == "sserafimFlash" then
			weeks:flash(event.value.duration)
		elseif event.name == "sserafimPulseLights" then
			weeks.stage.script:setLightState(event.value.enabled, event.value.colors, event.value.durations, event.value.intensities)
		elseif event.name == "sserafimKick" then
			weeks.stage.script:kickTruck(event.value.final)
        end
    end,

	draw = function(self)
        weeks:renderStage()

		weeks:drawUI()
	end,

	leave = function(self)

		enemy = nil
		boyfriend = nil
		girlfriend = nil

		graphics.clearCache()

		weeks:leave()
	end
}
