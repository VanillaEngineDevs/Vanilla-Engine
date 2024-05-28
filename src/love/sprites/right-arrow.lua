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
		{x = 311, y = 237, width = 154, height = 157, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 3: arrowRIGHT0000
		{x = 1, y = 237, width = 154, height = 157, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 30: red0000
		{x = 1051, y = 444, width = 50, height = 64, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 31: red hold end0000
		{x = 1102, y = 444, width = 50, height = 44, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 32: red hold piece0000
		{x = 1406, y = 1, width = 223, height = 226, offsetX = -1, offsetY = -3, offsetWidth = 226, offsetHeight = 230, rotated = false}, -- 33: right confirm0000
		{x = 1630, y = 1, width = 223, height = 226, offsetX = -1, offsetY = -3, offsetWidth = 226, offsetHeight = 230, rotated = false}, -- 34: right confirm0001
		{x = 953, y = 1, width = 226, height = 230, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 35: right confirm0002
		{x = 953, y = 1, width = 226, height = 230, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 36: right confirm0003
		{x = 912, y = 444, width = 138, height = 141, offsetX = -4, offsetY = -5, offsetWidth = 148, offsetHeight = 152, rotated = false}, -- 37: right press0000
		{x = 912, y = 444, width = 138, height = 141, offsetX = -4, offsetY = -5, offsetWidth = 148, offsetHeight = 152, rotated = false}, -- 38: right press0001
		{x = 466, y = 389, width = 148, height = 152, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 39: right press0002
		{x = 466, y = 389, width = 148, height = 152, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 40: right press0003
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
