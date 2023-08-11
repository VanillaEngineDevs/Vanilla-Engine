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
local version = love.filesystem.getInfo("version.txt") and love.filesystem.read("version.txt") or "vUnknown"
function love.conf(t)
	t.identity = "VE-FNFR"
	t.version = "11.4"
	t.console = not love.filesystem.isFused() -- lmao i just found out you can use this function in love.conf

	t.window.title = "Friday Night Funkin' Vanilla Engine " .. version
end
