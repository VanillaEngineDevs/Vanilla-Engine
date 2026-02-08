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
	love.graphics.newImage(graphics.imagePath("rating")),
	{
		{x = 0, y = 0, width = 403, height = 152, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 1: Sick
		{x = 404, y = 0, width = 317, height = 126, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 2: Good
		{x = 722, y = 0, width = 261, height = 131, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 3: Bad
		{x = 984, y = 0, width = 285, height = 163, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 4: Shit

		{x = 0, y = 164, width = 94, height = 119, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 1: 0
		{x = 95, y = 164, width = 98, height = 120, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 2: 1
		{x = 194, y = 164, width = 105, height = 129, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 3: 2
		{x = 300, y = 164, width = 102, height = 134, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 4: 3
		{x = 403, y = 164, width = 98, height = 130, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 5: 4
		{x = 502, y = 164, width = 111, height = 135, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 6: 5
		{x = 614, y = 164, width = 108, height = 134, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 7: 6
		{x = 723, y = 164, width = 91, height = 111, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 8: 7
		{x = 815, y = 164, width = 90, height = 115, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 9: 8
		{x = 906, y = 164, width = 91, height = 124, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 10: 9
	},
	{
		["sick"] = {start = 1, stop = 1, speed = 0, offsetX = 0, offsetY = 0},
		["good"] = {start = 2, stop = 2, speed = 0, offsetX = 0, offsetY = 0},
		["bad"] = {start = 3, stop = 3, speed = 0, offsetX = 0, offsetY = 0},
		["shit"] = {start = 4, stop = 4, speed = 0, offsetX = 0, offsetY = 0},

		["0"] = {start = 5, stop = 5, speed = 0, offsetX = 0, offsetY = 0},
		["1"] = {start = 6, stop = 6, speed = 0, offsetX = 0, offsetY = 0},
		["2"] = {start = 7, stop = 7, speed = 0, offsetX = 0, offsetY = 0},
		["3"] = {start = 8, stop = 8, speed = 0, offsetX = 0, offsetY = 0},
		["4"] = {start = 9, stop = 9, speed = 0, offsetX = 0, offsetY = 0},
		["5"] = {start = 10, stop = 10, speed = 0, offsetX = 0, offsetY = 0},
		["6"] = {start = 11, stop = 11, speed = 0, offsetX = 0, offsetY = 0},
		["7"] = {start = 12, stop = 12, speed = 0, offsetX = 0, offsetY = 0},
		["8"] = {start = 13, stop = 13, speed = 0, offsetX = 0, offsetY = 0},
		["9"] = {start = 14, stop = 14, speed = 0, offsetX = 0, offsetY = 0}
	},
	"sick",
	false
)
