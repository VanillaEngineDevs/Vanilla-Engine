return {
    enter = function()
        stageImages = {
            ["Haunted House"] = love.filesystem.load("sprites/week2/haunted-house.lua")() -- Haunted House
        }
        
		enemy = love.filesystem.load("sprites/week2/skid-and-pump.lua")()

		girlfriend.x, girlfriend.y = -200, 50
		enemy.x, enemy.y = -610, 140
		boyfriend.x, boyfriend.y = 30, 240
    end,

    load = function()
    end,

    update = function(self, dt)
        stageImages["Haunted House"]:update(dt)
        if not stageImages["Haunted House"]:isAnimated() then
			stageImages["Haunted House"]:animate("normal", false)
		end
        if musicThres ~= oldMusicThres and math.fmod(absMusicTime, 60000 * (love.math.random(17) + 7) / bpm) < 100 then
			audio.playSound(sounds["thunder"][love.math.random(2)])

			stageImages["Haunted House"]:animate("lightning", false)
			girlfriend:animate("fear", false, function() girlfriend:animate("danceLeft", false) end)
			boyfriend:animate("shaking", false)
		end
    end,

    draw = function()
        love.graphics.push()
			love.graphics.translate(camera.x * 0.9, camera.y * 0.9)
			love.graphics.translate(camera.ex * 0.9, camera.ey * 0.9)

			stageImages["Haunted House"]:draw()
			girlfriend:draw()
		love.graphics.pop()
		love.graphics.push()
			love.graphics.translate(camera.x, camera.y)
			love.graphics.translate(camera.ex, camera.ey)

			enemy:draw()
			boyfriend:draw()
		love.graphics.pop()
    end,

    leave = function()
        for i, v in pairs(stageImages) do
			v = nil
		end

		graphics.clearCache()
    end
}