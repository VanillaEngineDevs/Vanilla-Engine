local fromState, hasStartedAnimation, isEnding
local deadBF, quotes
local quoteCount = 25

local quoteLength = 0
local quoteTimer = 0
local vol = {0.2}
return {
	enter = function(self, from)
		quoteLength = 0
		quoteTimer = 0
		vol = {0.2}
		hasStartedAnimation = false
		graphics.setFade(1)
		deadBF = fakeBoyfriend or boyfriend or BaseCharacter("sprites/characters/boyfriend.lua")
		if deadBF.x == 0 and boyfriend then -- Probably forgot to set this in the week file
			deadBF.x = boyfriend.x
		end
		if deadBF.y == 0 and boyfriend then
			deadBF.y = boyfriend.y
		end

		fromState = from

		if inst then inst:stop() end
		if voicesBF then voicesBF:stop() end
		if voicesEnemy then voicesEnemy:stop() end

		inst = love.audio.newSource("music/game-over.ogg", "stream")
		inst:setLooping(true)

		Timer.clear()
		local point = camera:getPoint("boyfriend") or {x = 0, y = 0}
		CAM_LERP_POINT.x, CAM_LERP_POINT.y = point.x, point.y
		camera.defaultZoom = 1

		quotes = {}

		for i = 1, quoteCount do
			quotes[i] = love.audio.newSource("sounds/deathQuotes/default/jeffGameover-" .. i .. ".ogg", "static")
		end

	end,

	update = function(self, dt)
		local adjustedLerp  = 1 - math.pow(1.0 - 0.04, dt * 60)
		camera.x = camera.x + (CAM_LERP_POINT.x - camera.x) * adjustedLerp
		camera.y = camera.y + (CAM_LERP_POINT.y - camera.y) * adjustedLerp
		camera.zoom = util.smoothLerp(camera.zoom, camera.defaultZoom, dt, 0.5)

		deadBF:update(dt)

		if not hasStartedAnimation then
			hasStartedAnimation = true
			if deadBF then
				deadBF:animate("dies", false, function()
					local quote = quotes[love.math.random(1, quoteCount)]
					quote:play()
					quoteLength = quote:getDuration("seconds")

					deadBF:animate("dead", true)
				end)
			end
			audio.playSound(gameOverSounds.boyfriend.firstDeath)
		end

		if quoteLength > 0 then
			quoteTimer = quoteTimer + dt
			if quoteTimer >= quoteLength and not inst:isPlaying() then
				inst:play()
				Timer.tween(
					4,
					vol,
					{1}
				)
				inst:setVolume(vol[1])
			elseif quoteTimer >= quoteLength then
				inst:setVolume(vol[1])
			end
		end

		if not isEnding and input:pressed("confirm") then
			self:confirmDeath()
		end
	end,

	confirmDeath = function(self)
		isEnding = true
		inst:stop()
		inst = love.audio.newSource("music/game-over-end.ogg", "stream")
		inst:play()
		deadBF:animate("dead confirm", false, function()
			graphics.fadeOut(
				3,
				function()
					Gamestate.pop()

					fromState:load()
				end
			)
		end)
	end,

	draw = function(self)
		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)

			love.graphics.push()
				love.graphics.scale(camera.zoom, camera.zoom)
				love.graphics.translate(camera.x, camera.y)

				if deadBF then
					deadBF:draw()
				end
			love.graphics.pop()
		love.graphics.pop()
	end,

	leave = function(self)
		Timer.clear()
		graphics.setFade(1)
		if inst then inst:stop() end
		if voicesBF then voicesBF:stop() end
		if voicesEnemy then voicesEnemy:stop() end

		for i = 1, quoteCount do
			quotes[i]:stop()
		end
	end
}
