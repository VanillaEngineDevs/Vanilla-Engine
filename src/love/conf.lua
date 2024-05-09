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

-- Modified by Vanilla Engine Team

local version = love.filesystem.getInfo("version.txt") and love.filesystem.read("version.txt") or "vUnknown"
local _debug = not love.filesystem.isFused()
local loveVer
function love.conf(t)
	t.identity = "VE-FNFR"
	t.version = "11.4"
	t.console = _debug
	t.window.vsync = false

	if _debug then
		local major, minor, revision, codename = love.getVersion()
		loveVer = major .. "." .. minor .. "." .. revision .. " " .. codename
	end

	t.window.title = "Friday Night Funkin' Vanilla Engine " .. version .. (_debug and " | DEBUG | LOVE: " .. loveVer or "")
end
