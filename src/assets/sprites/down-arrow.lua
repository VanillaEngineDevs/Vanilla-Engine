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

return graphics.newSprite(
	images.notes,
	{
		{x = 1062, y = 452, width = 51, height = 64, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 1: blue hold end instance 10000
		{x = 1282, y = 457, width = 51, height = 44, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 2: blue hold piece instance 10000
		{x = 0, y = 240, width = 158, height = 154, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 3: blue instance 10000
	},
	{
		["on"] = {start = 3, stop = 3, speed = 0, offsetX = 0, offsetY = 0},
		["end"] = {start = 1, stop = 1, speed = 0, offsetX = 0, offsetY = 0},
		["hold"] = {start = 2, stop = 2, speed = 0, offsetX = 0, offsetY = 0},
	},
	"on",
	false
)
