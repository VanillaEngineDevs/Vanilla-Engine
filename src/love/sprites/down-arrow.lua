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
		{x = 479, y = 234, width = 157, height = 154, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 1: arrowDOWN0000
		{x = 1854, y = 1, width = 157, height = 154, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 5: blue0000
		{x = 1051, y = 444, width = 50, height = 64, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 6: blue hold end0000
		{x = 1102, y = 444, width = 50, height = 44, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 7: blue hold piece0000
		{x = 1, y = 1, width = 238, height = 235, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 8: down confirm0000
		{x = 240, y = 1, width = 238, height = 235, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 9: down confirm0001
		{x = 1180, y = 230, width = 220, height = 216, offsetX = -9, offsetY = -10, offsetWidth = 238, offsetHeight = 235, rotated = false}, -- 10: down confirm0002
		{x = 1180, y = 230, width = 220, height = 216, offsetX = -9, offsetY = -10, offsetWidth = 238, offsetHeight = 235, rotated = false}, -- 11: down confirm0003
		{x = 146, y = 395, width = 142, height = 140, offsetX = -4, offsetY = -2, offsetWidth = 149, offsetHeight = 146, rotated = false}, -- 12: down press0000
		{x = 146, y = 395, width = 142, height = 140, offsetX = -4, offsetY = -2, offsetWidth = 149, offsetHeight = 146, rotated = false}, -- 13: down press0001
		{x = 615, y = 389, width = 149, height = 146, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 14: down press0002
		{x = 615, y = 389, width = 149, height = 146, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 15: down press0003
	},
	{
		["off"] = {start = 1, stop = 1, speed = 0, offsetX = 0, offsetY = 0},
		["on"] = {start = 2, stop = 2, speed = 0, offsetX = 0, offsetY = 0},
		["end"] = {start = 3, stop = 3, speed = 0, offsetX = 0, offsetY = 0},
		["hold"] = {start = 4, stop = 4, speed = 0, offsetX = 0, offsetY = 0},
		["confirm"] = {start = 5, stop = 8, speed = 24, offsetX = 0, offsetY = 0},
		["press"] = {start = 9, stop = 12, speed = 24, offsetX = 0, offsetY = 0}
	},
	"off",
	false
)
