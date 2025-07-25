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

local loading

local noResize

return {
	setLoading = function(state)
		loading = state
	end,
	getLoading = function()
		return loading
	end,

	setNoResize = function(state)
		noResize = state
	end,
	getNoResize = function()
		return noResize
	end,

	getDebugStr = function(type)
		local debugStr
		local stats = love.graphics.getStats()
		if type == "detailed" then
			debugStr = "UPS: " .. tostring(love.timer.getFPS()) .. " | DPS: " .. tostring(love.timer.getDrawFPS()) ..
			"\nLua Memory: " .. tostring(math.floor(collectgarbage("count"))) .. "KB" ..
			"\nGraphics Memory: " .. tostring(math.floor(stats.texturememory / 1048576)) .. "MB" ..
			"\nLoaded Images: " .. tostring(stats.images) ..
			"\nLoaded Fonts: " .. tostring(stats.fonts) ..
			"\nDraw Calls: " .. tostring(stats.drawcalls) ..

			"\n\nmusicTime: " .. string.format("%.2f", musicTime) ..
			"\nhealth: " .. string.format("%.2f", health)
		else
			debugStr = "UPS: " .. tostring(love.timer.getFPS()) .. " | DPS: " .. tostring(love.timer.getDrawFPS())
		end

		return debugStr
	end
}
