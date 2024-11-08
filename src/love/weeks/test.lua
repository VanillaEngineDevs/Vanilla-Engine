local stageBack, stageFront, curtains

return {
	enter = function(self, from)
		weeks:enter()

		stages["stage.base"]:enter()
        enemy = nil
        love.graphics.setDefaultFilter("nearest", "nearest")
        enemy = BaseCharacter("sprites/characters/boyfriend-pixel.lua")
        love.graphics.setDefaultFilter("linear", "linear")

        enemy.flipX = true
        enemy.sizeX, enemy.sizeY = 7, 7
        enemy.x = -300
        enemy.y = 30

		song = 1
		difficulty = ""

		self:load()
	end,

	load = function(self)
		weeks:load()
		stages["stage.base"]:load()

	    inst = love.audio.newSource("songs/test/Inst.ogg", "stream")
		voicesBF = love.audio.newSource("songs/test/Voices-bf.ogg", "stream")
        voicesEnemy = love.audio.newSource("songs/test/Voices-bf-pixel.ogg", "stream")

        -- override of the weeks.lua function
        function updateNotePos()
            local dt = love.timer.getDelta()
            for i = 1, 4 do
                for j, note in ipairs(boyfriendNotes[i]) do
                    local strumline = boyfriendArrows[i]

                    if note.time >= 32130 and note.time <= 38400 then
                        if (math.floor((note.time - 32130) / (33130 - 32130)) % 2 == 0) then
                            note.y = (-400 + 775 * (((note.time - 32130) % (33130 - 32130)) / (33130 - 32130)))
                        else
                            note.y = (400 - 775 * (((note.time - 32130) % (33130 - 32130)) / (33130 - 32130)))
                        end
                        if note.time - musicTime > (83535.91160220992 - 82209.94475138119) then
                            note.alpha = 0
                        elseif (math.floor((note.time - 32130) / (33130 - 32130)) == math.floor((musicTime - 32130) / (33130 - 32130))) then
                            note.alpha = 1
                        else
                            note.alpha = 0.7
                        end

                        if note:getAnimName() == "hold" or note:getAnimName() == "end" then
                            -- just remove it from boyfriendNotes[i]
                            table.remove(boyfriendNotes[i], j)
                        end
                    else
                        note.alpha = 1

                        note.y = (strumline.y - (musicTime - note.time) * (0.45 * math.roundDecimal(speed,2)))
                    end
                end

                for j, note in ipairs(enemyNotes[i]) do
                    local strumline = enemyArrows[i]

                    if note.time >= 32130 and note.time <= 38400 then
                        if (math.floor((note.time - 32130) / (33130 - 32130)) % 2 == 0) then
                            note.y = (-400 + 775 * (((note.time - 32130) % (33130 - 32130)) / (33130 - 32130)))
                        else
                            note.y = (400 - 775 * (((note.time - 32130) % (33130 - 32130)) / (33130 - 32130)))
                        end
                        if note.time - musicTime > (83535.91160220992 - 82209.94475138119) then
                            note.alpha = 0
                        elseif (math.floor((note.time - 32130) / (33130 - 32130)) == math.floor((musicTime - 32130) / (33130 - 32130))) then
                            note.alpha = 1
                        else
                            note.alpha = 0.7
                        end

                        if note:getAnimName() == "hold" or note:getAnimName() == "end" then
                            -- just remove it from enemyNotes[i]
                            table.remove(enemyNotes[i], j)
                        end
                    else
                        note.y = (strumline.y - (musicTime - note.time) * (0.45 * math.roundDecimal(speed,2)))
                    end

                    if note.time >= 63630 and note.time <= 64000 then
                        note.orientation = note.orientation + 420 * dt
                    end
                end
            end
        end

		self:initUI()

		weeks:setupCountdown()
	end,

	initUI = function(self)
		weeks:initUI()

		weeks:legacyGenerateNotes("data/songs/test/test.json")
	end,

	update = function(self, dt)
		weeks:update(dt)
		stages["stage.base"]:update(dt)

        for i = 1, 4 do
            local strumline = boyfriendArrows[i]
            local strumline2 = enemyArrows[i]
            if musicTime >= 32130 and musicTime <= 38400 then
                if (math.floor((musicTime - 32130) / (33130 - 32130)) % 2 == 0) then
                    strumline.y = -400 + 825 * ((musicTime - 32130) % (33130 - 32130)) / (33130 - 32130)
                    strumline2.y = -400 + 825 * ((musicTime - 32130) % (33130 - 32130)) / (33130 - 32130)
                else
                    strumline.y = 400 - 825 * ((musicTime - 32130) % (33130 - 32130)) / (33130 - 32130)
                    strumline2.y = 400 - 825 * ((musicTime - 32130) % (33130 - 32130)) / (33130 - 32130)
                end
            else
                strumline.y = -400
                strumline2.y = -400
            end

            if musicTime >= 63630 and musicTime <= 64000 then
                strumline2.orientation = strumline2.orientation + 420 * dt
            elseif musicTime >= 64000 and musicTime <= 64075 then
                strumline2.orientation = 0
            end
        end

		weeks:checkSongOver()

		weeks:updateUI(dt)
	end,

	draw = function(self)
		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
			love.graphics.scale(camera.zoom, camera.zoom)

			stages["stage.base"]:draw()
		love.graphics.pop()

		weeks:drawUI()
	end,

	leave = function(self)
		stages["stage.base"]:leave()

		enemy = nil
		boyfriend = nil
		girlfriend = nil

		graphics.clearCache()

		weeks:leave()
	end
}
