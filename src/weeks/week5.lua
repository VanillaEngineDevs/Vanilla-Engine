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
			inst = love.audio.newSource("songs/winter-horrorland/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/winter-horrorland/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/winter-horrorland/Voices-monster" .. songExt .. ".ogg", "stream")
		elseif song == 2 then
			inst = love.audio.newSource("songs/eggnog/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/eggnog/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/eggnog/Voices-parents-christmas" .. songExt .. ".ogg", "stream")
		else
			inst = love.audio.newSource("songs/cocoa/Inst.ogg", "stream")
			voicesBF = love.audio.newSource("songs/cocoa/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/cocoa/Voices-parents-christmas" .. songExt .. ".ogg", "stream")
		end

		weeks:setupCountdown()
	end,

	initUI = function(self)
		weeks:initUI()

		if song == 3 then
			weeks:generateNotes("data/songs/winter-horrorland/winter-horrorland-chart" .. songExt .. ".json", "data/songs/winter-horrorland/winter-horrorland-metadata" .. songExt .. ".json", difficulty)
		elseif song == 2 then
			weeks:generateNotes("data/songs/eggnog/eggnog-chart" .. songExt .. ".json", "data/songs/eggnog/eggnog-metadata" .. songExt .. ".json", difficulty)
		else
			weeks:generateNotes("data/songs/cocoa/cocoa-chart" .. songExt .. ".json", "data/songs/cocoa/cocoa-metadata" .. songExt .. ".json", difficulty)
		end
	end,

	onNoteHit = function(self, character, noteType, rating, id) 
		-- rating is "EnemyHit" when an enemy hits it. Can be used to determine if the player hit it or the enemy hit it when needed
		-- Return "true" to not play ANY animations, return "false" or nothing to play the default animations
		if rating == "EnemyHit" then
			if noteType == "mom" then
				weeks:setAltAnims(true)
			end
		end

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

	leave = function()
		graphics.clearCache()

		weeks:leave()
	end
}
