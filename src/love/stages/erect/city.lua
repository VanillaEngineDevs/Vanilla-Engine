local colorShader = love.graphics.newShader("shaders/adjustColor.glsl")

return {
    enter = function(self, songExt)
		sounds = sounds or {}
        winColors = {
			{182, 111, 67},
			{50, 154, 109},
			{147, 44, 40},
			{38, 99, 172},
			{80, 45, 100},
		}
        winAlpha = 1
		winColor = 1
        
        stageImages = {
            ["Sky"] = graphics.newImage(graphics.imagePath("week3.erect/sky")), -- sky
            ["City"] = graphics.newImage(graphics.imagePath("week3.erect/city")), -- city
            ["City Windows"] = graphics.newImage(graphics.imagePath("week3/city-windows")), -- city-windows
            ["Behind Train"] = graphics.newImage(graphics.imagePath("week3.erect/behindTrain")), -- behind-train
            ["Street"] = graphics.newImage(graphics.imagePath("week3.erect/street")), -- street
			["Train"] = graphics.newImage(graphics.imagePath("week3/train")), -- train
        }

        stageImages["Behind Train"].y = -100
		stageImages["Behind Train"].sizeX, stageImages["Behind Train"].sizeY = 1.25, 1.25
		stageImages["Street"].y = -100
		stageImages["Street"].sizeX, stageImages["Street"].sizeY = 1.25, 1.25

		stageImages["Train"].x, stageImages["Train"].y = 3000, -25

		enemy = BaseCharacter("sprites/characters/pico-enemy.lua")
		enemy.flipX = true

		if songExt == "-pico" then
			boyfriend = BaseCharacter("sprites/characters/pico-player.lua")
			girlfriend = NeneCharacter()
		end

		sounds.trainPassing = love.audio.newSource("sounds/week3/train.ogg", "static")

		girlfriend.x, girlfriend.y = -70, -140
		enemy.x, enemy.y = -480, 50
		boyfriend.x, boyfriend.y = 165, 50

		if songExt == "-pico" then
			girlfriend.y = girlfriend.y - 100
			boyfriend.y = boyfriend.y + 10
			boyfriend.x = boyfriend.x + 70
		end

		colorShader:send("brightness", -5)
		colorShader:send("hue", -26)
		colorShader:send("contrast", 0)
		colorShader:send("saturation", -16)
		
		boyfriend.shader = colorShader
		girlfriend.shader = colorShader
		enemy.shader = colorShader

		stageImages["Train"].doShit = true

		function trainReset()
			stageImages["Train"].x = 3000
			stageImages["Train"].moving = false
			trainCars = 8
			stageImages["Train"].finishing = false
			stageImages["Train"].startedMoving = false
		end

		function trainStart()
			stageImages["Train"].moving = true
			audio.playSound(sounds.trainPassing)
		end

		function updateTrainPos(dt)
			if sounds.trainPassing:tell("seconds") > 4.7 and sounds.trainPassing:isPlaying() then
				stageImages["Train"].startedMoving = true
			end
			if stageImages["Train"].startedMoving then
				stageImages["Train"].x = stageImages["Train"].x - 6750 * dt

				if stageImages["Train"].x < -3000 and stageImages["Train"].finishing then
					--trainReset() -- bruh this shit is trying to troll me rn
					-- 			      why does it reset the train then still do it 1 more time
					stageImages["Train"].doShit = false
					stageImages["Train"].moving	= false
					stageImages["Train"].startedMoving = false
					stageImages["Train"].finishing = false
					girlfriend:animate("hair landing", false, function() girlfriend:animate("danceLeft") ; girlfriend.danced = false end)
				end

				if stageImages["Train"].x < -200 and not stageImages["Train"].finishing and stageImages["Train"].doShit then
					if not girlfriend:isAnimated() or util.startsWith(girlfriend:getAnimName(), "dance") and girlfriend:getAnimName() ~= "hair landing" then
						girlfriend:animate("hair blowing")
					end
					stageImages["Train"].x = 375
					trainCars = trainCars - 1

					if trainCars <= 0 then
						stageImages["Train"].finishing = true
						stageImages["Train"].doShit = false
					end
				end
			end

			if not stageImages["Train"].moving then
				trainCooldown = trainCooldown + 1
			end
		end

		trainCooldown = 0
		trainCars = 8
    end,

    load = function()

    end,

    update = function(self, dt)
        if beatHandler.onBeat() and beatHandler.getBeat() % 4 == 0 then
			winColor = winColor + 1

			if winColor > 5 then
				winColor = 1
			end

			winAlpha = 1
		end

		if beatHandler.onBeat() and beatHandler.getBeat() % 8 == 4 and not stageImages["Train"].moving and trainCooldown > 8 and love.math.random(10) == 1 then
			trainCooldown = love.math.random(-4, 0)
			stageImages["Train"].doShit = true
			trainReset()
			trainStart()
		end

        if winAlpha > 0 then
            winAlpha = winAlpha - (((bpm or 120)/260) * dt)
        end

		updateTrainPos(dt)
    end,

    draw = function()
        local curWinColor = winColors[winColor]

        love.graphics.push()
			love.graphics.translate(camera.x * 0.25, camera.y * 0.25)

			stageImages["Sky"]:draw()
		love.graphics.pop()
		love.graphics.push()
			love.graphics.translate(camera.x * 0.5, camera.y * 0.5)

			stageImages["City"]:draw()
			graphics.setColor(curWinColor[1]/255, curWinColor[2]/255, curWinColor[3]/255, winAlpha)
			stageImages["City Windows"]:draw()
			graphics.setColor(1, 1, 1)
		love.graphics.pop()
		love.graphics.push()
			love.graphics.translate(camera.x * 0.9, camera.y * 0.9)
			stageImages["Behind Train"]:draw()
			stageImages["Train"]:draw()
			stageImages["Street"]:draw()

			girlfriend:draw()
		love.graphics.pop()
		love.graphics.push()
			love.graphics.translate(camera.x, camera.y)

			enemy:draw()
			boyfriend:draw()
		love.graphics.pop()
    end,

    leave = function()
        for _, v in pairs(stageImages) do
			v = nil
		end

		graphics.clearCache()
    end
}