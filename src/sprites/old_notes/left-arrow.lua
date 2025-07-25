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
		{x = 488, y = 238, width = 155, height = 158, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 1: arrowLEFT0000
		{x = 972, y = 0, width = 230, height = 232, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 19: left confirm0000
		{x = 1438, y = 233, width = 220, height = 222, offsetX = -5, offsetY = -5, offsetWidth = 230, offsetHeight = 232}, -- 20: left confirm0001
		{x = 1438, y = 0, width = 227, height = 229, offsetX = -2, offsetY = -1, offsetWidth = 230, offsetHeight = 232}, -- 21: left confirm0002
		{x = 1438, y = 0, width = 227, height = 229, offsetX = -2, offsetY = -1, offsetWidth = 230, offsetHeight = 232}, -- 22: left confirm0003
		{x = 1898, y = 449, width = 139, height = 142, offsetX = -4, offsetY = -3, offsetWidth = 146, offsetHeight = 149}, -- 23: left press0000
		{x = 1898, y = 449, width = 139, height = 142, offsetX = -4, offsetY = -3, offsetWidth = 146, offsetHeight = 149}, -- 24: left press0001
		{x = 1898, y = 150, width = 146, height = 149, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 25: left press0002
		{x = 1898, y = 150, width = 146, height = 149, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 26: left press0003
		{x = 1117, y = 452, width = 51, height = 64, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 43: purple tail0000
		{x = 0, y = 398, width = 154, height = 157, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 45: purple alone0000
		{x = 1337, y = 457, width = 51, height = 44, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 44: purple hold0000
	},
	{
		["off"] = {start = 1, stop = 1, speed = 0, offsetX = 0, offsetY = 0},
		["confirm"] = {start = 2, stop = 5, speed = 24, offsetX = 0, offsetY = 0},
		["press"] = {start = 6, stop = 9, speed = 24, offsetX = 0, offsetY = 0},
		["end"] = {start = 10, stop = 10, speed = 0, offsetX = 0, offsetY = 0},
		["on"] = {start = 11, stop = 11, speed = 0, offsetX = 0, offsetY = 0},
		["hold"] = {start = 12, stop = 12, speed = 0, offsetX = 0, offsetY = 0}
	},
	"off",
	false
)
