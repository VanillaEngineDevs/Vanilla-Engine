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

		if song == 3 then
			inst = love.audio.newSource("songs/stress/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/stress/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/stress/Voices-tankman" .. songExt .. ".ogg", "stream")
		elseif song == 2 then
			inst = love.audio.newSource("songs/guns/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/guns/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/guns/Voices-tankman" .. songExt .. ".ogg", "stream")
		else
			inst = love.audio.newSource("songs/ugh/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/ugh/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/ugh/Voices-tankman" .. songExt .. ".ogg", "stream")
		end

		weeks:setupCountdown()
	end,

	initUI = function(self)
		weeks:initUI()

		if song == 3 then
			weeks:generateNotes("data/songs/stress/stress-chart" .. songExt .. ".json", "data/songs/stress/stress-metadata" .. songExt .. ".json", difficulty)
			weeks:generateGFNotes("data/songs/stress/stress-chart" .. songExt .. ".json", "picospeaker")
		elseif song == 2 then
			weeks:generateNotes("data/songs/guns/guns-chart" .. songExt .. ".lua", "data/songs/guns/guns-metadata" .. songExt .. ".lua", difficulty)
		else
			weeks:generateNotes("data/songs/ugh/ugh-chart" .. songExt .. ".lua", "data/songs/ugh/ugh-metadata" .. songExt .. ".lua", difficulty)
		end
	end,

	update = function(self, dt)
		weeks:update(dt)

		weeks:checkSongOver()

		weeks:updateUI(dt)
	end,

	draw = function()
        weeks:renderStage()

        weeks:drawUI()
    end,

	leave = function(self)
		graphics.clearCache()

		weeks:leave()
	end
}