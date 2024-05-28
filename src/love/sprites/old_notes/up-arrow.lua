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
		{x = 323, y = 240, width = 157, height = 154, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 4: arrowUP0000
		{x = 162, y = 240, width = 157, height = 154, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 18: green alone0000
		{x = 1007, y = 452, width = 51, height = 64, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 16: green tail0000
		{x = 1227, y = 457, width = 51, height = 44, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 17: green hold0000
		{x = 488, y = 0, width = 238, height = 234, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 80: up confirm0000
		{x = 730, y = 0, width = 238, height = 234, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 81: up confirm0001
		{x = 972, y = 236, width = 216, height = 212, offsetX = -11, offsetY = -11, offsetWidth = 238, offsetHeight = 234}, -- 82: up confirm0002
		{x = 972, y = 236, width = 216, height = 212, offsetX = -11, offsetY = -11, offsetWidth = 238, offsetHeight = 234}, -- 83: up confirm0003
		{x = 1898, y = 303, width = 144, height = 142, offsetX = -6, offsetY = -4, offsetWidth = 154, offsetHeight = 151}, -- 84: up press0000
		{x = 1898, y = 303, width = 144, height = 142, offsetX = -6, offsetY = -4, offsetWidth = 154, offsetHeight = 151}, -- 85: up press0001
		{x = 158, y = 398, width = 154, height = 151, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 86: up press0002
		{x = 158, y = 398, width = 154, height = 151, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0} -- 87: up press0003
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
