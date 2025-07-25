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
		{x = 156, y = 237, width = 154, height = 157, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 2: arrowLEFT0000
		{x = 1406, y = 228, width = 218, height = 221, offsetX = -3, offsetY = -4, offsetWidth = 225, offsetHeight = 228, rotated = false}, -- 19: left confirm0000
		{x = 1625, y = 228, width = 218, height = 221, offsetX = -3, offsetY = -4, offsetWidth = 225, offsetHeight = 228, rotated = false}, -- 20: left confirm0001
		{x = 1180, y = 1, width = 225, height = 228, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 21: left confirm0002
		{x = 1180, y = 1, width = 225, height = 228, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 22: left confirm0003
		{x = 289, y = 395, width = 140, height = 142, offsetX = -3, offsetY = -3, offsetWidth = 146, offsetHeight = 149, rotated = false}, -- 23: left press0000
		{x = 289, y = 395, width = 140, height = 142, offsetX = -3, offsetY = -3, offsetWidth = 146, offsetHeight = 149, rotated = false}, -- 24: left press0001
		{x = 765, y = 392, width = 146, height = 149, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 25: left press0002
		{x = 765, y = 392, width = 146, height = 149, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 26: left press0003
		{x = 795, y = 234, width = 154, height = 157, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 27: purple0000
		{x = 1102, y = 444, width = 50, height = 44, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 29: purple hold piece0000
		{x = 1051, y = 444, width = 50, height = 64, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 28: purple hold end0000
	},
	{
		["off"] = {start = 1, stop = 1, speed = 0, offsetX = 0, offsetY = 0},
		["confirm"] = {start = 2, stop = 5, speed = 24, offsetX = 0, offsetY = 0},
		["press"] = {start = 6, stop = 9, speed = 24, offsetX = 0, offsetY = 0},
		["end"] = {start = 12, stop = 12, speed = 0, offsetX = 0, offsetY = 0},
		["on"] = {start = 10, stop = 10, speed = 0, offsetX = 0, offsetY = 0},
		["hold"] = {start = 11, stop = 11, speed = 0, offsetX = 0, offsetY = 0}
	},
	"off",
	false
)
