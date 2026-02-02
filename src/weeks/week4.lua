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
			inst = love.audio.newSource("songs/milf/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/milf/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/milf/Voices-mom" .. songExt .. ".ogg", "stream")
		elseif song == 2 then
			inst = love.audio.newSource("songs/high/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/high/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/high/Voices-mom" .. songExt .. ".ogg", "stream")
		else
			inst = love.audio.newSource("songs/satin-panties/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/satin-panties/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/satin-panties/Voices-mom" .. songExt .. ".ogg", "stream")
		end

		weeks:setupCountdown()
	end,

	initUI = function(self)
		weeks:initUI()

		if song == 3 then
			weeks:generateNotes("data/songs/milf/milf-chart" .. songExt .. ".lua", "data/songs/milf/milf-metadata" .. songExt .. ".lua", difficulty)
		elseif song == 2 then
			weeks:generateNotes("data/songs/high/high-chart" .. songExt .. ".lua", "data/songs/high/high-metadata" .. songExt .. ".lua", difficulty)
		else
			weeks:generateNotes("data/songs/satin-panties/satin-panties-chart" .. songExt .. ".lua", "data/songs/satin-panties/satin-panties-metadata" .. songExt .. ".lua", difficulty)
		end
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

	leave = function()
		graphics.clearCache()

		weeks:leave()
	end
}
