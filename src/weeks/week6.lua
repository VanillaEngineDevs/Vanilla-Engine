return {
	enter = function(self, from, songNum, songAppend, _songExt, _audioAppend)
		love.graphics.setDefaultFilter("nearest")
		weeks:enter("pixel")

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
			inst = love.audio.newSource("songs/thorns/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/thorns/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/thorns/Voices-spirit" .. songExt .. ".ogg", "stream")
		elseif song == 2 then
			inst = love.audio.newSource("songs/roses/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/roses/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/roses/Voices-senpai" .. songExt .. ".ogg", "stream")
		else
			inst = love.audio.newSource("songs/senpai/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/senpai/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/senpai/Voices-senpai" .. songExt .. ".ogg", "stream")
		end
	end,

	initUI = function(self)
		weeks:initUI("pixel")

		if song == 3 then
			weeks:generateNotes("data/songs/thorns/thorns-chart" .. songExt .. ".lua", "data/songs/thorns/thorns-metadata" .. songExt .. ".lua", difficulty)
		elseif song == 2 then
			weeks:generateNotes("data/songs/roses/roses-chart" .. songExt .. ".lua", "data/songs/roses/roses-metadata" .. songExt .. ".lua", difficulty)
		else
			weeks:generateNotes("data/songs/senpai/senpai-chart" .. songExt .. ".lua", "data/songs/senpai/senpai-metadata" .. songExt .. ".lua", difficulty)
		end

		weeks:setupCountdown()
	end,

	update = function(self, dt)
		weeks:update(dt)

		weeks:checkSongOver()

		weeks:updateUI(dt)
	end,

	draw = function(self)
		weeks:renderStage()

		weeks:drawUI()
	end,

	leave = function(self)
		graphics.clearCache()

		weeks:leave()
	end
}
