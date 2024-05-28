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
		{x = 808, y = 238, width = 155, height = 157, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 3: arrowRIGHT0000
		{x = 647, y = 397, width = 154, height = 157, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 48: red alone0000
		{x = 952, y = 452, width = 51, height = 64, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 46: red tail0000
		{x = 1172, y = 457, width = 51, height = 44, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 47: red hold0000
		{x = 1669, y = 0, width = 225, height = 228, offsetX = -1, offsetY = -2, offsetWidth = 228, offsetHeight = 231}, -- 49: right confirm0000
		{x = 1669, y = 232, width = 225, height = 228, offsetX = -1, offsetY = -2, offsetWidth = 228, offsetHeight = 231}, -- 50: right confirm0001
		{x = 1206, y = 0, width = 228, height = 231, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 51: right confirm0002
		{x = 1206, y = 0, width = 228, height = 231, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 52: right confirm0003
		{x = 469, y = 400, width = 139, height = 142, offsetX = -3, offsetY = -7, offsetWidth = 149, offsetHeight = 152}, -- 53: right press0000
		{x = 469, y = 400, width = 139, height = 142, offsetX = -3, offsetY = -7, offsetWidth = 149, offsetHeight = 152}, -- 54: right press0001
		{x = 316, y = 398, width = 149, height = 152, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 55: right press0002
		{x = 316, y = 398, width = 149, height = 152, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 56: right press0003
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
