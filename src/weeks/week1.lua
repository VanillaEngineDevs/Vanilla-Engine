return {
	songs = {
		"bopeebo",
		"fresh",
		"dadbattle"
	},

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
			weeks:initUI()
			weeks:generateNotes(self.songs[song], difficulty)
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
