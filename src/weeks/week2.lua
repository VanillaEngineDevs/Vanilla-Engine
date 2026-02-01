return {
	enter = function(self, from, songNum, songAppend, _songExt, _audioAppend)
		weeks:enter()

		song = songNum
		difficulty = songAppend
		songExt = _songExt
		audioAppend = _audioAppend

		camera.zoom = 1.1
		camera.defaultZoom = 1.1

		sounds["thunder"] = {
			love.audio.newSource("sounds/week2/thunder1.ogg", "static"),
			love.audio.newSource("sounds/week2/thunder2.ogg", "static")
		}

		self:load()
	end,

	load = function(self, DONT_GENERATE)
		weeks:load(not DONT_GENERATE)
		if not DONT_GENERATE then
			self:initUI()
		end
		if song == 3 then
			inst = love.audio.newSource("songs/monster/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/monster/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/monster/Voices-monster" .. songExt .. ".ogg", "stream")
		elseif song == 2 then
			inst = love.audio.newSource("songs/south/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/south/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/south/Voices-spooky" .. songExt .. ".ogg", "stream")
		else
			inst = love.audio.newSource("songs/spookeez/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/spookeez/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/spookeez/Voices-spooky" .. songExt .. ".ogg", "stream")
		end

		weeks:setupCountdown()
	end,

	initUI = function(self)
		weeks:initUI()

		if song == 3 then
			weeks:generateNotes("data/songs/monster/monster-chart" .. songExt .. ".lua", "data/songs/monster/monster-metadata" .. songExt .. ".lua", difficulty)
		elseif song == 2 then
			weeks:generateNotes("data/songs/south/south-chart" .. songExt .. ".lua", "data/songs/south/south-metadata" .. songExt .. ".lua", difficulty)
		else
			weeks:generateNotes("data/songs/spookeez/spookeez-chart" .. songExt .. ".lua", "data/songs/spookeez/spookeez-metadata" .. songExt .. ".lua", difficulty)
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

	leave = function(self)
		graphics.clearCache()

		weeks:leave()
	end
}
