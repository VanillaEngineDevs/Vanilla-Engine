local stageBack, stageFront, curtains

local zoomTimer
local zoom = {}

return {
	enter = function(self, from, songNum, songAppend, _songExt, _audioAppend)
		weeks:enter()

		difficulty = songAppend
		song = songNum
		songExt = _songExt
		audioAppend = _audioAppend

		stageBack = graphics.newImage(graphics.imagePath("week1/stage-back"))
		stageFront = graphics.newImage(graphics.imagePath("week1/stage-front"))
		curtains = graphics.newImage(graphics.imagePath("week1/curtains"))

		stageFront.y = 400
		curtains.y = -100

		girlfriend = nil
		enemy = BaseCharacter("sprites/characters/girlfriend.lua")
		enemy.x, enemy.y = 30, -90
		boyfriend.x, boyfriend.y = 260, 100

		self:load()
	end,

	lload = function(self, DONT_GENERATE)
		weeks:load(not DONT_GENERATE)

		zoom[1] = 1

		inst = love.audio.newSource("songs/tutorial/Inst" .. songExt .. ".ogg", "stream")
		voicesBF = love.audio.newSource("songs/tutorial/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
		voicesEnemy = love.audio.newSource("songs/tutorial/Voices-gf" .. songExt .. ".ogg", "stream")

		if not DONT_GENERATE then
			self:initUI()
		end

		weeks:setupCountdown()
	end,

	initUI = function(self)
		weeks:initUI()

		weeks:generateNotes("data/songs/tutorial/tutorial-chart" .. songExt .. ".lua", "data/songs/tutorial/tutorial-metadata" .. songExt .. ".lua", difficulty)
	end,

	update = function(self, dt)
		weeks:update(dt)

		if musicThres ~= oldMusicThres and (musicThres == 185 or musicThres == 280) then
			enemy:animate("cheer", false)
			boyfriend:animate("hey", false)
		end

		weeks:checkSongOver()

		weeks:updateUI(dt)
	end,

	draw = function(self)
		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
			love.graphics.scale(camera.zoom, camera.zoom)

			love.graphics.push()
				love.graphics.translate(camera.x * 0.9, camera.y * 0.9)

				stageBack:draw()
				stageFront:draw()
				enemy:draw()
			love.graphics.pop()
			love.graphics.push()
				love.graphics.translate(camera.x, camera.y)

				boyfriend:draw()
			love.graphics.pop()
			love.graphics.push()
				love.graphics.translate(camera.x * 1.1, camera.y * 1.1)

				curtains:draw()
			love.graphics.pop()
		love.graphics.pop()

		weeks:drawUI()
	end,

	leave = function(self)
		stageBack = nil
		stageFront = nil
		curtains = nil

		graphics.clearCache()

		weeks:leave()
	end
}
