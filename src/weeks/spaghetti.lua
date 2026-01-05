local stage

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
        enemy.x = -200
        inst = love.audio.newSource("songs/spaghetti/Inst.mp3", "stream")
        voicesBF = love.audio.newSource("songs/spaghetti/Voices-sserafim-sakura.mp3", "stream")

		weeks:setupCountdown()
	end,

	initUI = function(self)
		weeks:initUI()

		weeks:generateNotes("data/songs/spaghetti/spaghetti-chart" .. songExt .. ".json", "data/songs/spaghetti/spaghetti-metadata" .. songExt .. ".json", difficulty)
	end,

	update = function(self, dt)
		weeks:update(dt)

		weeks:checkSongOver()

		weeks:updateUI(dt)
	end,

    onNoteHit = function(self, character, noteType, rating, id)
        local notok = false
        if noteType == "sakura-joint" then
            notok = true
            character:play(CONSTANTS.WEEKS.ANIM_LIST[id] .. "-joint", true, false)
        elseif noteType == "sakura-bf1" then
            notok = true
            character:play(CONSTANTS.WEEKS.ANIM_LIST[id] .. "-bf1", true, false)
        elseif noteType == "sakura-bf2" then
            notok = true
            character:play(CONSTANTS.WEEKS.ANIM_LIST[id] .. "-bf2", true, false)
        end

        return true
    end,

    onEvent = function(self, event)
        if event.name == "sserafimSing" then
            self:setGirlsSinging(event.value.singing)
        end
    end,

    setGirlsSinging = function(self, singing)
        if #singing < 6 then return end

        enemy.characterType = singing[1] and CHARACTER_TYPE.BF or CHARACTER_TYPE.DAD
        boyfriend.characterType = singing[5] and CHARACTER_TYPE.BF or CHARACTER_TYPE.DAD
        girlfriend.characterType = singing[6] and CHARACTER_TYPE.BF or CHARACTER_TYPE.DAD
    end,

	draw = function(self)
		--[[ love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
			love.graphics.scale(camera.zoom, camera.zoom)
            love.graphics.translate(-graphics.getWidth() / 2, -graphics.getHeight() / 2)

            boyfriend:draw()
            girlfriend:draw()
            enemy:draw()

		love.graphics.pop() ]]

        weeks:renderStage()

		weeks:drawUI()
	end,

	leave = function(self)

		enemy = nil
		boyfriend = nil
		girlfriend = nil

		graphics.clearCache()

		weeks:leave()
	end
}
