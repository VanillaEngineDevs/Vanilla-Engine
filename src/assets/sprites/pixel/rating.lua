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
	love.graphics.newImage(graphics.imagePath("pixel/rating")),
	{
		{x = 0, y = 0, width = 51, height = 20, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 1: Sick
		{x = 52, y = 0, width = 39, height = 16, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 2: Good
		{x = 92, y = 0, width = 28, height = 19, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 3: Bad
		{x = 121, y = 0, width = 35, height = 20, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 4: Shit

		{x = 0, y = 21, width = 9, height = 12, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 1: 0
		{x = 10, y = 21, width = 9, height = 12, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 2: 1
		{x = 20, y = 21, width = 10, height = 12, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 3: 2
		{x = 31, y = 21, width = 10, height = 12, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 4: 3
		{x = 42, y = 21, width = 10, height = 12, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 5: 4
		{x = 53, y = 21, width = 10, height = 12, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 6: 5
		{x = 64, y = 21, width = 10, height = 12, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 7: 6
		{x = 75, y = 21, width = 9, height = 12, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 8: 7
		{x = 85, y = 21, width = 9, height = 12, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 9: 8
        {x = 95, y = 21, width = 9, height = 12, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 10: 9
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
	false,
    {
		floored = true
	}
)
