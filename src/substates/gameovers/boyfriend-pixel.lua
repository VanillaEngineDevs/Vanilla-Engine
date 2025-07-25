local fromState

return {
	enter = function(self, from)
		hasStartedAnimation, isEnding = false, false
		graphics.setFade(1)
		local boyfriend = fakeBoyfriend or boyfriend

		fromState = from

		if inst then inst:stop() end
		if voicesBF then voicesBF:stop() end
		if voicesEnemy then voicesEnemy:stop() end

		audio.playSound(sounds["death"])

		if boyfriend then boyfriend:animate("dies", false) end

		Timer.clear()

		Timer.tween(
			2,
			camera,
			{x = boyfriend and -boyfriend.x or 0, y = boyfriend and -boyfriend.y or 0, zoom = camera.defaultZoom},
			"out-quad",
			function()
				inst = love.audio.newSource("music/pixel/game-over.ogg", "stream")
				inst:setLooping(true)
				inst:play()

				boyfriend:animate("dead", true)
			end
		)
	end,

	update = function(self, dt)
		local boyfriend = fakeBoyfriend or boyfriend

		if input:pressed("confirm") or pauseRestart then
			pauseRestart = false
			if inst then inst:stop() end -- In case inst is nil and "confirm" is pressed before game over music starts

			inst = love.audio.newSource("music/pixel/game-over-end.ogg", "stream")
			inst:play()

			Timer.clear()

			if boyfriend then 
				camera.x, camera.y = -boyfriend.x, -boyfriend.y
			else
				camera.x, camera.y = 0, 0
			end

			if boyfriend then boyfriend:animate("dead confirm", false) end

			graphics.fadeOut(
				3,
				function()
					Gamestate.pop()

					fromState:load()
				end
			)
		elseif input:pressed("gameBack") then
			status.setLoading(true)

			graphics:fadeOutWipe(
				0.7,
				function()
					Gamestate.pop()

					Gamestate.switch(menuWeek)

					status.setLoading(false)

					if not music:isPlaying() then
						music:play()
					end
				end
			)
		end

		boyfriend:update(dt)
	end,

	draw = function(self)
		local boyfriend = fakeBoyfriend or boyfriend

		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)

			love.graphics.push()
				love.graphics.scale(camera.zoom, camera.zoom)
				love.graphics.translate(camera.x, camera.y)

				if boyfriend then
					boyfriend:udraw()
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
	end
}
