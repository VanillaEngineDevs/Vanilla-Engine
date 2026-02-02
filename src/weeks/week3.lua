local animations = {
	"singLEFT",
	"singDOWN",
	"singUP",
	"singRIGHT",
	"singLEFT",
	"singDOWN",
	"singUP",
	"singRIGHT"
}

local inPicoCutscene = false

previousFrameTime = 0

return {
	enter = function(self, from, songNum, songAppend, _songExt, _audioAppend)
		weeks:enter()

		if _songExt == "-pico" then
			--inPicoCutscene = true
		end

		song = songNum
		difficulty = songAppend
		songExt = _songExt
		audioAppend = _audioAppend

		camera.zoom = 1
		camera.defaultZoom = 1

		self:load()
	end,

	load = function(self, DONT_GENERATE)
		weeks:load(not DONT_GENERATE)
		if not DONT_GENERATE then
			self:initUI()
		end

		if song == 3 then
			inst = love.audio.newSource("songs/blammed/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/blammed/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/blammed/Voices-pico-enemy" .. songExt .. ".ogg", "stream")
		elseif song == 2 then
			inst = love.audio.newSource("songs/philly-nice/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/philly-nice/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/philly-nice/Voices-pico-enemy" .. songExt .. ".ogg", "stream")
		else
			inst = love.audio.newSource("songs/pico/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/pico/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/pico/Voices-pico-enemy" .. songExt .. ".ogg", "stream")
		end

		if not inPicoCutscene then
			weeks:setupCountdown()
		end
	end,

	initUI = function(self)
		weeks:initUI()

		if song == 3 then
			weeks:generateNotes("data/songs/blammed/blammed-chart" .. songExt .. ".lua", "data/songs/blammed/blammed-metadata" .. songExt .. ".lua", difficulty)
		elseif song == 2 then
			weeks:generateNotes("data/songs/philly-nice/philly-nice-chart" .. songExt .. ".lua", "data/songs/philly-nice/philly-nice-metadata" .. songExt .. ".lua", difficulty)
		else
			weeks:generateNotes("data/songs/pico/pico-chart" .. songExt .. ".lua", "data/songs/pico/pico-metadata" .. songExt .. ".lua", difficulty)
		end
	end,

	onNoteHit = function(self, character, noteType, rating, id)
		if noteType == "censor" then
			local animName = animations[id] .. " swear"
			character:play(animName)
			return true
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
