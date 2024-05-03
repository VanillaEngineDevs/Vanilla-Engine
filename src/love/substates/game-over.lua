--[[----------------------------------------------------------------------------
This file is part of Friday Night Funkin' Rewritten

Copyright (C) 2021  HTV04

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
------------------------------------------------------------------------------]]

local fromState

return {
	enter = function(self, from)
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
				if not pixel then
					inst = love.audio.newSource("music/game-over.ogg", "stream")
				else
					inst = love.audio.newSource("music/pixel/game-over.ogg", "stream")
				end
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

			if not pixel then
				inst = love.audio.newSource("music/game-over-end.ogg", "stream")
			else
				inst = love.audio.newSource("music/pixel/game-over-end.ogg", "stream")
			end
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
					if not pixel then
						boyfriend:draw()
					else
						boyfriend:udraw()
					end
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
