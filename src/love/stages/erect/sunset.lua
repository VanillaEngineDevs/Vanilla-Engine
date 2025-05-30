local colorShader = love.graphics.newShader("shaders/adjustColor.glsl")

return {
    enter = function()
        sounds = sounds or {}
        stageImages = {
            ["Sunset"] = graphics.newImage(graphics.imagePath("week4.erect/limoSunset")),
            ["BG Limo"] = love.filesystem.load("sprites/week4.erect/bg-limo.lua")(), -- bg-limo
            ["Limo Dancer"] = love.filesystem.load("sprites/week4/limo-dancer.lua")(), -- limo-dancer
            ["Limo"] = love.filesystem.load("sprites/week4/limo.lua")(), -- limo
            ["Fast Car"] = graphics.newImage(graphics.imagePath("week4/fastCarLol")) -- fast-car
        }
        girlfriend = BaseCharacter("sprites/characters/girlfriend-car.lua")
        enemy = BaseCharacter("sprites/characters/mommy-mearest.lua")
        boyfriend = BaseCharacter("sprites/characters/boyfriend-car.lua")
        fakeBoyfriend = BaseCharacter("sprites/characters/boyfriend.lua") -- Used for game over

        stageImages.Sunset.y = 300

        sounds.car = {
            love.audio.newSource("sounds/week4/carPass0.ogg", "static"),
            love.audio.newSource("sounds/week4/carPass1.ogg", "static"),
        }
        sounds.car[1]:setVolume(0.7)
        sounds.car[2]:setVolume(0.7)

        fakeBoyfriend.x, fakeBoyfriend.y = 350, -100
        stageImages["BG Limo"].y = 250
        stageImages["Limo Dancer"].y = -130
        stageImages["Limo"].y = 375

        stageImages["Fast Car"].x = -12600
        stageImages["Fast Car"].y = love.math.random(140, 250)
        stageImages["Fast Car"].vx = 0
        stageImages["Fast Car"].canDrive = true

        girlfriend.x, girlfriend.y = 30, -50
        enemy.x, enemy.y = -380, -10
        boyfriend.x, boyfriend.y = 340, -100

        function resetFastCar()
            stageImages["Fast Car"].x = -12600
            stageImages["Fast Car"].y = 375 + love.math.random(140, 250)
            stageImages["Fast Car"].vx = 0
            stageImages["Fast Car"].canDrive = true
        end

        function fastCarDrive(dt)
            audio.playSound(sounds.car[love.math.random(2)])

            stageImages["Fast Car"].canDrive = false
            stageImages["Fast Car"].vx = (love.math.random(170, 220) / dt) * 0.25
            if carTimer then
                Timer.cancel(carTimer)
            end
            carTimer = Timer.after(2, function()
                resetFastCar()
                carTimer = nil
            end)
        end

        boyfriend.shader = colorShader
        girlfriend.shader = colorShader
        enemy.shader = colorShader
        stageImages["Limo Dancer"].shader = colorShader
        stageImages["Fast Car"].shader = colorShader

        colorShader:send("brightness", -30)
        colorShader:send("hue", -30)
        colorShader:send("contrast", 0)
        colorShader:send("saturation", -20)
    end,

    load = function()

    end,

    update = function(self, dt)
        stageImages["BG Limo"]:update(dt)
		stageImages["Limo Dancer"]:update(dt)
		stageImages["Limo"]:update(dt)

        if Conductor.onBeat then
            if Conductor.curBeat % 2 == 0 then
                stageImages["Limo Dancer"]:animate("anim1", false)
            else
                stageImages["Limo Dancer"]:animate("anim2", true)
            end
		end

        --[[ if love.math.random(4000) == 100 and stageImages["Fast Car"].canDrive then
            fastCarDrive(dt)
        end ]]

        stageImages["Fast Car"].x = stageImages["Fast Car"].x + stageImages["Fast Car"].vx * dt
    end,

    draw = function()
        love.graphics.push()
            love.graphics.translate(camera.x * 0.1, camera.y * 0.1)
            stageImages["Sunset"]:draw()
        love.graphics.pop()
        love.graphics.push()
			love.graphics.translate(camera.x * 0.4, camera.y * 0.4)

			stageImages["BG Limo"]:draw()
			for i = -475, 725, 400 do
				stageImages["Limo Dancer"].x = i

				stageImages["Limo Dancer"]:draw()
			end
		love.graphics.pop()
		love.graphics.push()
			love.graphics.translate(camera.x, camera.y)

            stageImages["Fast Car"]:draw()
            local lastShader = love.graphics.getShader()
            love.graphics.setShader(colorShader)
			girlfriend:draw()
            love.graphics.setShader(lastShader)
			stageImages["Limo"]:draw()
            love.graphics.setShader(colorShader)
			enemy:draw()
			boyfriend:draw()
            love.graphics.setShader(lastShader)
		love.graphics.pop()
    end,

    leave = function()
        for _, v in pairs(stageImages) do
			v = nil
		end

		graphics.clearCache()
    end
}