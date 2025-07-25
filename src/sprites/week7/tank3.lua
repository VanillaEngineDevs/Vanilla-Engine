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
	love.graphics.newImage(graphics.imagePath("week7/tank3")),
	-- Automatically generated from tank3.xml
	{
		{x = 0, y = 422, width = 590, height = 124, offsetX = 0, offsetY = -11, offsetWidth = 590, offsetHeight = 135}, -- 1: fg tankhead 4 instance 10000
		{x = 0, y = 422, width = 590, height = 124, offsetX = 0, offsetY = -11, offsetWidth = 590, offsetHeight = 135}, -- 2: fg tankhead 4 instance 10001
		{x = 0, y = 286, width = 585, height = 126, offsetX = -2, offsetY = -9, offsetWidth = 590, offsetHeight = 135}, -- 3: fg tankhead 4 instance 10002
		{x = 0, y = 286, width = 585, height = 126, offsetX = -2, offsetY = -9, offsetWidth = 590, offsetHeight = 135}, -- 4: fg tankhead 4 instance 10003
		{x = 0, y = 145, width = 580, height = 131, offsetX = -5, offsetY = -4, offsetWidth = 590, offsetHeight = 135}, -- 5: fg tankhead 4 instance 10004
		{x = 0, y = 145, width = 580, height = 131, offsetX = -5, offsetY = -4, offsetWidth = 590, offsetHeight = 135}, -- 6: fg tankhead 4 instance 10005
		{x = 0, y = 0, width = 574, height = 135, offsetX = -9, offsetY = 0, offsetWidth = 590, offsetHeight = 135}, -- 7: fg tankhead 4 instance 10006
		{x = 0, y = 0, width = 574, height = 135, offsetX = -9, offsetY = 0, offsetWidth = 590, offsetHeight = 135}, -- 8: fg tankhead 4 instance 10007
		{x = 0, y = 0, width = 574, height = 135, offsetX = -9, offsetY = 0, offsetWidth = 590, offsetHeight = 135}, -- 9: fg tankhead 4 instance 10008
		{x = 0, y = 0, width = 574, height = 135, offsetX = -9, offsetY = 0, offsetWidth = 590, offsetHeight = 135}, -- 10: fg tankhead 4 instance 10009
		{x = 0, y = 0, width = 574, height = 135, offsetX = -9, offsetY = 0, offsetWidth = 590, offsetHeight = 135}, -- 11: fg tankhead 4 instance 10010
		{x = 0, y = 0, width = 574, height = 135, offsetX = -9, offsetY = 0, offsetWidth = 590, offsetHeight = 135}, -- 12: fg tankhead 4 instance 10011
		{x = 0, y = 0, width = 574, height = 135, offsetX = -9, offsetY = 0, offsetWidth = 590, offsetHeight = 135}, -- 13: fg tankhead 4 instance 10012
		{x = 0, y = 0, width = 574, height = 135, offsetX = -9, offsetY = 0, offsetWidth = 590, offsetHeight = 135}, -- 14: fg tankhead 4 instance 10013
		{x = 0, y = 0, width = 574, height = 135, offsetX = -9, offsetY = 0, offsetWidth = 590, offsetHeight = 135} -- 15: fg tankhead 4 instance 10014
	},
    {
        -- no more bob.
		["anim"] = {start = 1, stop = 15, speed = 24, offsetX = 0, offsetY = 0}
    },
    "anim",
	true
)
