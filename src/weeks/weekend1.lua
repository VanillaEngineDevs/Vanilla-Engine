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

		if song == 4 then
			inst = love.audio.newSource("songs/blazin/Inst" .. songExt .. ".ogg", "stream") 
			voicesBF = nil
			voicesEnemy = nil
		elseif song == 3 then
			inst = love.audio.newSource("songs/2hot/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/2hot/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/2hot/Voices-darnell" .. songExt .. ".ogg", "stream")
		elseif song == 2 then
			inst = love.audio.newSource("songs/lit-up/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/lit-up/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/lit-up/Voices-darnell" .. songExt .. ".ogg", "stream")
		else
			inst = love.audio.newSource("songs/darnell/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/darnell/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/darnell/Voices-darnell" .. songExt .. ".ogg", "stream")
		end

		weeks:setupCountdown()
	end,

	initUI = function(self)
		weeks:initUI()
		if song == 4 then
			weeks:generateNotes("data/songs/blazin/blazin-chart" .. songExt .. ".lua", "data/songs/blazin/blazin-metadata" .. songExt .. ".lua", difficulty)
		elseif song == 3 then
			weeks:generateNotes("data/songs/2hot/2hot-chart" .. songExt .. ".lua", "data/songs/2hot/2hot-metadata" .. songExt .. ".lua", difficulty)
		elseif song == 2 then
			weeks:generateNotes("data/songs/lit-up/lit-up-chart" .. songExt .. ".lua", "data/songs/lit-up/lit-up-metadata" .. songExt .. ".lua", difficulty)
		else
			weeks:generateNotes("data/songs/darnell/darnell-chart" .. songExt .. ".lua", "data/songs/darnell/darnell-metadata" .. songExt .. ".lua", difficulty)
		end
	end,

	onNoteMiss = function(self, character, noteType, rating, id)
		if noteType == "weekend-1-firegun" then
			enemy:animate("Pico Hit Can")
			health = health - 0.25

			return true
		end
	end,

	update = function(self, dt)
		weeks:update(dt)

		weeks:checkSongOver()

		weeks:updateUI(dt)
	end,

	draw = function(self, dt)
		weeks:renderStage()

		weeks:drawUI()
	end,

	leave = function(self)
		graphics.clearCache()

		weeks:leave()
	end
}
