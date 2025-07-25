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
		{x = 647, y = 238, width = 157, height = 155, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 1: arrowDOWN0000
		{x = 0, y = 240, width = 158, height = 154, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 7: blue alone0000
		{x = 1062, y = 452, width = 51, height = 64, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 5: blue tail0000
		{x = 1282, y = 457, width = 51, height = 44, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 6: blue hold0000
		{x = 0, y = 0, width = 240, height = 236, offsetX = -6, offsetY = 0, offsetWidth = 240, offsetHeight = 236}, -- 8: down confirm0000
		{x = 244, y = 0, width = 240, height = 236, offsetX = -6, offsetY = 0, offsetWidth = 240, offsetHeight = 236}, -- 9: down confirm0001
		{x = 1206, y = 235, width = 221, height = 218, offsetX = -12, offsetY = -12, offsetWidth = 240, offsetHeight = 236}, -- 10: down confirm0002
		{x = 1206, y = 235, width = 221, height = 218, offsetX = -12, offsetY = -12, offsetWidth = 240, offsetHeight = 236}, -- 11: down confirm0003
		{x = 805, y = 399, width = 143, height = 139, offsetX = -4, offsetY = -3, offsetWidth = 150, offsetHeight = 146}, -- 12: down press0000
		{x = 805, y = 399, width = 143, height = 139, offsetX = -4, offsetY = -3, offsetWidth = 150, offsetHeight = 146}, -- 13: down press0001
		{x = 1898, y = 0, width = 150, height = 146, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 14: down press0002
		{x = 1898, y = 0, width = 150, height = 146, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 15: down press0003
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
