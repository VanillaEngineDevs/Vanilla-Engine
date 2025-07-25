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

-- You do not need to mess with this file. You just need to press 7 when loaded into the game

local selection
local curDir, dirTable
local sprite, spriteAnims, overlaySprite

local curFrameOverlaySpr, curFrameSpr

return {
	spriteViewerSearch = function(self, dir)
		svMode = 1

		if curDir then
			curDir = curDir .. "/" .. dir
		else
			curDir = dir
		end
		selection = 1
		dirTable = love.filesystem.getDirectoryItems(curDir)
		curFrameOverlaySpr = 1
		curFrameSpr = 1
	end,

	enter = function(self, previous)
		selection = 3

		love.keyboard.setKeyRepeat(true)

		graphics.setFade(0)
		graphics.fadeIn(0.5)
	end,

	keypressed = function(self, key)
		if svMode == 2 then
			if key == "w" then
				overlaySprite.y = overlaySprite.y - 1
			elseif key == "a" then
				overlaySprite.x = overlaySprite.x - 1
			elseif key == "s" then
				overlaySprite.y = overlaySprite.y + 1
			elseif key == "d" then
				overlaySprite.x = overlaySprite.x + 1
			elseif key == "q" then
				curFrameOverlaySpr = curFrameOverlaySpr - 1
				if curFrameOverlaySpr < 1 then
					curFrameOverlaySpr = #overlaySprite:getAllFrames()
				end
				overlaySprite:animateFromFrame(curFrameOverlaySpr, false)
				overlaySprite:update(0)
			elseif key == "e" then
				curFrameOverlaySpr = curFrameOverlaySpr + 1
				if curFrameOverlaySpr > #overlaySprite:getAllFrames() then
					curFrameOverlaySpr = 1
				end
				overlaySprite:animateFromFrame(curFrameOverlaySpr, false)
				overlaySprite:update(0)
			elseif key == "z" then
				curFrameSpr = curFrameSpr - 1
				if curFrameSpr < 1 then
					curFrameSpr = #sprite:getAllFrames()
				end
				sprite:animateFromFrame(curFrameSpr, false)
				sprite:update(0)
			elseif key == "c" then
				curFrameSpr = curFrameSpr + 1
				if curFrameSpr > #sprite:getAllFrames() then
					curFrameSpr = 1
				end
				sprite:animateFromFrame(curFrameSpr, false)
				sprite:update(0)
			end
		end
	end,

	spriteViewer = function(self, spritePath)
		local spriteData = love.filesystem.load(spritePath)

		svMode = 2

		sprite = spriteData()
		overlaySprite = spriteData()

		spriteAnims = {}
		for i, _ in pairs(sprite.getAnims()) do
			table.insert(spriteAnims, i)
		end

		sprite:animate(spriteAnims[1], false)
		overlaySprite:animate(spriteAnims[1], false)
	end,

	update = function(self, dt)
		if graphics.isFading() then return end
		
		if svMode == 2 then
			if input:pressed("up") then
				selection = selection - 1

				if selection < 1 then
					selection = #spriteAnims
				end

				sprite:animate(spriteAnims[selection], false)
			end
			if input:pressed("down") then
				selection = selection + 1

				if selection > #spriteAnims then
					selection = 1
				end

				sprite:animate(spriteAnims[selection], false)
			end
			if input:pressed("confirm") then
				overlaySprite:animate(spriteAnims[selection], false)
				curFrameOverlaySpr = overlaySprite:getFrameFromCurrentAnim()
			end
		else
			if input:pressed("up") then
				selection = selection - 1
				if selection < 1 then
					selection = #dirTable
				end
			end
			if input:pressed("down") then
				selection = selection + 1
				if selection > #dirTable then
					selection = 1
				end
			end
			if input:pressed("confirm") then
				if love.filesystem.getInfo(curDir .. "/" .. dirTable[selection]).type == "directory" then
					self:spriteViewerSearch(dirTable[selection])
				else
					self:spriteViewer(curDir .. "/" .. dirTable[selection])
				end
			end
		end

		if input:pressed("back") then
			graphics.fadeOut(0.5, love.event.quit)
		end
		if input:pressed("debugZoomOut") then
			camera.zoom = camera.zoom - 0.05
		end
		if input:pressed("debugZoomIn") then
			camera.zoom = camera.zoom + 0.05
		end
	end,

	draw = function(self)
		if svMode == 2 then
			graphics.clear(0.5, 0.5, 0.5)

			love.graphics.push()
				love.graphics.translate(push:getWidth() / 2, push:getHeight() / 2)
				love.graphics.scale(camera.zoom, camera.zoom)

				sprite:draw()
				graphics.setColor(1, 1, 1, 0.5)
				overlaySprite:draw()
				graphics.setColor(1, 1, 1)

			love.graphics.pop()

			for i = 1, #spriteAnims do
				if i == selection then
					graphics.setColor(1, 1, 0)
				end
				love.graphics.print(spriteAnims[i], 0, (i - 1) * 20)
				graphics.setColor(1, 1, 1)
			end
			
			love.graphics.print("Frame (overlay): " .. tostring(curFrameOverlaySpr), 0, (#spriteAnims + 1) * 20)
			love.graphics.print("Frame (sprite): " .. tostring(curFrameSpr), 0, (#spriteAnims + 2) * 20)
			local frameData = overlaySprite:getFrameData(curFrameOverlaySpr)
			love.graphics.print("Frame Data (overlay): " .. frameData.offsetX + overlaySprite.x .. ", " .. frameData.offsetY + overlaySprite.y .. ", " .. tostring(frameData.rotated), 0, (#spriteAnims + 3) * 20)
			falserameData = sprite:getFrameData(curFrameSpr)
			love.graphics.print("Frame Data (sprite): " .. frameData.offsetX .. ", " .. frameData.offsetY .. ", " .. tostring(frameData.rotated), 0, (#spriteAnims + 4) * 20)
		else
			for i = 1, #dirTable do
				if i == selection then
					graphics.setColor(1, 1, 0)
				elseif love.filesystem.getInfo(curDir .. "/" .. dirTable[i]).type == "directory" then
					graphics.setColor(1, 0, 1)
				end
				love.graphics.print(dirTable[i], 0, (i - 1) * 20)
				graphics.setColor(1, 1, 1)
			end
		end
	end
}
