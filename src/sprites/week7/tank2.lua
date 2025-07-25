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
	love.graphics.newImage(graphics.imagePath("week7/tank2")),
	-- Automatically generated from tank2.xml
	{
		{x = 595, y = 327, width = 293, height = 305, offsetX = -2, offsetY = -17, offsetWidth = 295, offsetHeight = 322}, -- 1: foreground man 3 instance 10000
		{x = 595, y = 327, width = 293, height = 305, offsetX = -2, offsetY = -17, offsetWidth = 295, offsetHeight = 322}, -- 2: foreground man 3 instance 10001
		{x = 0, y = 331, width = 288, height = 310, offsetX = -4, offsetY = -12, offsetWidth = 295, offsetHeight = 322}, -- 3: foreground man 3 instance 10002
		{x = 0, y = 331, width = 288, height = 310, offsetX = -4, offsetY = -12, offsetWidth = 295, offsetHeight = 322}, -- 4: foreground man 3 instance 10003
		{x = 595, y = 0, width = 288, height = 317, offsetX = -1, offsetY = -5, offsetWidth = 295, offsetHeight = 322}, -- 5: foreground man 3 instance 10004
		{x = 595, y = 0, width = 288, height = 317, offsetX = -1, offsetY = -5, offsetWidth = 295, offsetHeight = 322}, -- 6: foreground man 3 instance 10005
		{x = 0, y = 0, width = 288, height = 321, offsetX = 0, offsetY = -1, offsetWidth = 295, offsetHeight = 322}, -- 7: foreground man 3 instance 10006
		{x = 0, y = 0, width = 288, height = 321, offsetX = 0, offsetY = -1, offsetWidth = 295, offsetHeight = 322}, -- 8: foreground man 3 instance 10007
		{x = 298, y = 0, width = 287, height = 322, offsetX = 0, offsetY = 0, offsetWidth = 295, offsetHeight = 322}, -- 9: foreground man 3 instance 10008
		{x = 298, y = 0, width = 287, height = 322, offsetX = 0, offsetY = 0, offsetWidth = 295, offsetHeight = 322}, -- 10: foreground man 3 instance 10009
		{x = 298, y = 0, width = 287, height = 322, offsetX = 0, offsetY = 0, offsetWidth = 295, offsetHeight = 322}, -- 11: foreground man 3 instance 10010
		{x = 298, y = 0, width = 287, height = 322, offsetX = 0, offsetY = 0, offsetWidth = 295, offsetHeight = 322}, -- 12: foreground man 3 instance 10011
		{x = 298, y = 0, width = 287, height = 322, offsetX = 0, offsetY = 0, offsetWidth = 295, offsetHeight = 322}, -- 13: foreground man 3 instance 10012
		{x = 298, y = 0, width = 287, height = 322, offsetX = 0, offsetY = 0, offsetWidth = 295, offsetHeight = 322} -- 14: foreground man 3 instance 10013
	},
    {
        -- Bob get out.
		["anim"] = {start = 1, stop = 14, speed = 24, offsetX = 0, offsetY = 0}
    },
    "anim",
	true
)
