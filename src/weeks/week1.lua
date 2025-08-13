local stage

return {
	enter = function(self, from, songNum, songAppend, _songExt, _audioAppend)
		weeks:enter()

		stage = stages["stage.base"]

		if _songExt == "-erect" or _songExt == "-pico" then
			stage = stages["stage.erect"]
		end

		stage:enter(_songExt)

		song = songNum
		difficulty = songAppend
		songExt = _songExt
		audioAppend = _audioAppend

		self:load()
	end,

	load = function(self, DONT_GENERATE)
		weeks:load(not DONT_GENERATE)
		stage:load()

		if song == 3 then
			inst = love.audio.newSource("songs/dadbattle/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/dadbattle/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/dadbattle/Voices-dad" .. songExt .. ".ogg", "stream")
			if girlfriend.name == "nene" then
				girlfriend.soundData = love.sound.newSoundData("songs/dadbattle/Inst" .. songExt .. ".ogg")
				girlfriend.multiplier = 3
			end
		elseif song == 2 then
			inst = love.audio.newSource("songs/fresh/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/fresh/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/fresh/Voices-dad" .. songExt .. ".ogg", "stream")
			if girlfriend.name == "nene" then
				girlfriend.soundData = love.sound.newSoundData("songs/fresh/Inst" .. songExt .. ".ogg")
				girlfriend.multiplier = 3
			end
		else
			inst = love.audio.newSource("songs/bopeebo/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/bopeebo/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/bopeebo/Voices-dad" .. songExt .. ".ogg", "stream")
			if girlfriend.name == "nene" then
				girlfriend.soundData = love.sound.newSoundData("songs/bopeebo/Inst" .. songExt .. ".ogg")
				girlfriend.multiplier = 3
			end
		end

		if not DONT_GENERATE then
			self:initUI()
		end

		weeks:setupCountdown()
	end,

	initUI = function(self)
		weeks:initUI()
		if song == 3 then
			weeks:generateNotes("data/songs/dadbattle/dadbattle-chart" .. songExt .. ".lua", "data/songs/dadbattle/dadbattle-metadata" .. songExt .. ".lua", difficulty)
		elseif song == 2 then
			weeks:generateNotes("data/songs/fresh/fresh-chart" .. songExt .. ".lua", "data/songs/fresh/fresh-metadata" .. songExt .. ".lua", difficulty)
		else
			weeks:generateNotes("data/songs/bopeebo/bopeebo-chart" .. songExt .. ".lua", "data/songs/bopeebo/bopeebo-metadata" .. songExt .. ".lua", difficulty)
		end
	end,

	update = function(self, dt)
		weeks:update(dt)
		stage:update(dt)

		weeks:checkSongOver()

		weeks:updateUI(dt)
	end,

	draw = function(self)
		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
			love.graphics.scale(camera.zoom, camera.zoom)

			stage:draw()
		love.graphics.pop()

		weeks:drawUI()
	end,

	leave = function(self)
		stage:leave()

		enemy = nil
		boyfriend = nil
		girlfriend = nil

		graphics.clearCache()

		weeks:leave()
	end
}
