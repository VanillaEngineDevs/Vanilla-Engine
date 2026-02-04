return {
	songs = {
		"darnell",
		"lit-up",
		"2hot",
		"blazin"
	},
	
	enter = function(self, from, songNum, songAppend, _songExt, _audioAppend)
		weeks:enter("normal", songNum, songAppend, _songExt, _audioAppend)

		weeks:load()
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
