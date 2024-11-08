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
		if curDir == "sprites" then
			local modsDirTable = importMods.getAllModsSprites()
			for i, v in ipairs(modsDirTable) do
				table.insert(dirTable, v.name)
			end
		end
		-- sort so directories are first
		table.sort(dirTable, function(a, b)
			local isDir = false
			if love.filesystem.getInfo(curDir .. "/" .. a) and love.filesystem.getInfo(curDir .. "/" .. a).type == love.filesystem.getInfo(curDir .. "/" .. b).type then
				return a < b
			else
				return love.filesystem.getInfo(curDir .. "/" .. a) and love.filesystem.getInfo(curDir .. "/" .. a).type == "directory"
			end
		end)
	end,

	enter = function(self, previous)
		selection = 3

		love.keyboard.setKeyRepeat(true)

		self:spriteViewerSearch("sprites")

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
			end
		end
	end,

	spriteViewer = function(self, spritePath)
		local spriteData = nil--[[ love.filesystem.load(spritePath) ]]
		if love.filesystem.getInfo(spritePath) then
			spriteData = love.filesystem.load(spritePath)
		else
			importMods.setCurrentMod(importMods.getModFromSprite(spritePath))
			importMods.inMod = true
			spriteData = importMods.getSpriteFileFromName(spritePath)
		end

		svMode = 2

		sprite = spriteData()
		overlaySprite = spriteData()

		print(spritePath, spriteData, overlaySprite, sprite)

		spriteAnims = {}
		for i, _ in pairs(sprite.getAnims()) do
			table.insert(spriteAnims, i)
		end

		sprite:animate(spriteAnims[1], false, nil, false)
		overlaySprite:animate(spriteAnims[1], false, nil, false)
	end,

	update = function(self, dt)
		if graphics.isFading() then return end

		if svMode == 2 then
			sprite:update(dt)
			overlaySprite:update(dt)

			if input:pressed("up") then
				selection = selection - 1

				if selection < 1 then
					selection = #spriteAnims
				end

				sprite:animate(spriteAnims[selection], false, nil, false)
			end
			if input:pressed("down") then
				selection = selection + 1

				if selection > #spriteAnims then
					selection = 1
				end

				sprite:animate(spriteAnims[selection], false, nil, false)
			end
			if input:pressed("confirm") then
				overlaySprite:animate(spriteAnims[selection], false, nil, false)
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
				if love.filesystem.getInfo(curDir .. "/" .. dirTable[selection]) then
					if love.filesystem.getInfo(curDir .. "/" .. dirTable[selection]).type == "directory" then
						self:spriteViewerSearch(dirTable[selection])
					else
						self:spriteViewer(curDir .. "/" .. dirTable[selection])
					end
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
				uitextColored(spriteAnims[i], 0, (i - 1) * 20, 0, nil, (i == selection and {1, 1, 0} or {1, 1, 1}))
				graphics.setColor(1, 1, 1)

				uitextColored("X: " .. tostring((sprite.x - overlaySprite.x)), 0, (#spriteAnims + 1) * 20)
				uitextColored("Y: " .. tostring((sprite.y - overlaySprite.y)), 0, (#spriteAnims + 2) * 20)
				uitextColored("Frame: " .. tostring(overlaySprite:getFrameFromCurrentAnim()), 0, (#spriteAnims + 3) * 20)
			end
		else
			for i = 1, #dirTable do
				uitextColored(dirTable[i], 0, (i - 1) * 20, 0, nil,
					(
						i == selection and {1, 1, 0} or
						love.filesystem.getInfo(curDir .. "/" .. dirTable[i]) and love.filesystem.getInfo(curDir .. "/" .. dirTable[i]).type == "directory" and {1, 0, 1} or
						{1, 1, 1}
					)
				)
				graphics.setColor(1, 1, 1)
			end
		end
	end
}
