return {
	songs = {
		"bopeebo",
		"fresh",
		"dadbattle"
	},

	enter = function(self, from, songNum, songAppend, _songExt, _audioAppend)
		weeks:enter("normal", songNum, songAppend, _songExt, _audioAppend)
		
		weeks:load()
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
