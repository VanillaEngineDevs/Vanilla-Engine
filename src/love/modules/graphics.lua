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

You should have received a copy of1 the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
------------------------------------------------------------------------------]]

local imageType = "png"
fade = {
	1,
	height = push:getHeight(),
	mesh = nil,
	y = 0,
}
local isFading = false

local fadeTimer

local screenWidth, screenHeight

local function tblPush(t, v, pos)
	if pos then
		table.insert(t, pos, v)
	else
		table.insert(t, v)
	end
end

local graphics = {
	screenBase = function(width, height)
		screenWidth, screenHeight = width, height
	end,
	getWidth = function()
		return 1280 or love.graphics.getWidth()
	end,
	getHeight = function()
		return 720 or love.graphics.getHeight()
	end,

	cache = {},

	clearCache = function()
		graphics.cache = {}
	end,

	clearItemCache = function(path)
		graphics.cache[path] = nil
	end,

	imagePath = function(path)
		local pathStr = "images/" .. imageType .. "/" .. path .. "." .. imageType

		if not importMods.inMod then
			if love.filesystem.getInfo(pathStr) then
				return pathStr
			else
				return "images/png/" .. path .. ".png"
			end
		else
			local currentMod = importMods.getCurrentMod()
			if currentMod and love.filesystem.getInfo(currentMod.path .. "/images/" .. imageType .. "/" .. path .. "." .. imageType) then
				return currentMod.path .. "/images/" .. imageType .. "/" .. path .. "." .. imageType
			elseif currentMod and love.filesystem.getInfo(currentMod.path .. "/images/png/" .. path .. ".png") then
				return currentMod.path .. "/images/png/" .. path .. ".png"
			else
				if love.filesystem.getInfo(pathStr) then
					return pathStr
				else
					return "images/png/" .. path .. ".png"
				end
			end
		end
	end,
	setImageType = function(type)
		imageType = type
	end,
	getImageType = function()
		return imageType
	end,

	newImage = function(image, optionsTable)
		local pathStr = image
		if not graphics.cache[pathStr] and image then
			if love.filesystem.getInfo(pathStr) then
				graphics.cache[pathStr] = love.graphics.newImage(pathStr)
			else
				graphics.cache[pathStr] = love.graphics.newImage("images/missing.png")
			end
		end
		local image, width, height

		image = graphics.cache[pathStr]

		local options

		local object = {
			x = 0,
			y = 0,
			orientation = 0,
			sizeX = 1,
			sizeY = 1,
			offsetX = 0,
			offsetY = 0,
			shearX = 0,
			shearY = 0,

			scrollX = 1,
			scrollY = 1,

			visible = true,
			alpha = 1,

			setImage = function(self, imageData)
				image = imageData
				width = image:getWidth()
				height = image:getHeight()
			end,

			getImage = function(self)
				return image
			end,

			getWidth = function(self)
				return width
			end,

			getHeight = function(self)
				return height
			end,

			setScale = function(self, scale)
				self.sizeX, self.sizeY = scale, scale
			end,

			draw = function(self)
				local x = self.x
				local y = self.y

				if options and options.floored then
					x = math.floor(x)
					y = math.floor(y)
				end

				local lastColor = {love.graphics.getColor()}
				graphics.setColor(lastColor[1], lastColor[2], lastColor[3], lastColor[4] * self.alpha)

				if self.visible then
					if image then
						love.graphics.draw(
							image,
							self.x,
							self.y,
							self.orientation,
							self.sizeX,
							self.sizeY,
							math.floor(width / 2) + self.offsetX,
							math.floor(height / 2) + self.offsetY,
							self.shearX,
							self.shearY
						)
					end
				end

				love.graphics.setColor(lastColor[1], lastColor[2], lastColor[3])
			end,

			udraw = function(self, sx, sy)
				local sx = sx or 7
				local sy = sy or sx 
				local x = self.x
				local y = self.y

				if options and options.floored then
					x = math.floor(x)
					y = math.floor(y)
				end

				local lastColor = {love.graphics.getColor()}
				graphics.setColor(lastColor[1], lastColor[2], lastColor[3], lastColor[4] * self.alpha)

				if self.visible then
					love.graphics.draw(
						image,
						self.x,
						self.y,
						self.orientation,
						sx,
						sy,
						math.floor(width / 2) + self.offsetX,
						math.floor(height / 2) + self.offsetY,
						self.shearX,
						self.shearY
					)
				end

				love.graphics.setColor(lastColor[1], lastColor[2], lastColor[3])
			end
		}

		if image then
			object:setImage(image)
		end

		options = optionsTable

		return object
	end,

	newCanvas = function(width, height, optionsTable)
		-- like new image
		local canvas = love.graphics.newCanvas(width, height)

		local object = {
			x = 0,
			y = 0,
			orientation = 0,
			sizeX = 1,
			sizeY = 1,
			offsetX = 0,
			offsetY = 0,
			shearX = 0,
			shearY = 0,

			scrollX = 1,
			scrollY = 1,

			visible = true,
			alpha = 1,

			setCanvas = function(self, canvas)
				canvas = canvas
				width = canvas:getWidth()
				height = canvas:getHeight()
			end,

			renderTo = function(self, func)
				local last = love.graphics.getCanvas()
				love.graphics.push()
				love.graphics.setCanvas(canvas)
				love.graphics.translate(canvas:getWidth() / 2, canvas:getHeight() / 2)
				love.graphics.scale(self.sizeX, self.sizeY)
				love.graphics.translate(-canvas:getWidth() / 2, -canvas:getHeight() / 2)
				love.graphics.translate(self.x/2, self.y/2)
				func()
				love.graphics.pop()
				love.graphics.setCanvas(last)
			end,

			getCanvas = function(self)
				return canvas
			end,

			getWidth = function(self)
				return width
			end,

			getHeight = function(self)
				return height
			end,

			setScale = function(self, scale)
				self.sizeX, self.sizeY = scale, scale
			end,

			draw = function(self)
				local x = self.x
				local y = self.y

				if options and options.floored then
					x = math.floor(x)
					y = math.floor(y)
				end

				local lastColor = {love.graphics.getColor()}
				graphics.setColor(lastColor[1], lastColor[2], lastColor[3], lastColor[4] * self.alpha)

				if self.visible then
					love.graphics.draw(
						canvas,
						self.x,
						self.y,
						self.orientation,
						self.sizeX,
						self.sizeY,
						math.floor(width / 2) + self.offsetX,
						math.floor(height / 2) + self.offsetY,
						self.shearX,
						self.shearY
					)
				end

				love.graphics.setColor(lastColor[1], lastColor[2], lastColor[3])
			end,

			udraw = function(self, sx, sy)
				local sx = sx or 7
				local sy = sy or sx 
				local x = self.x
				local y = self.y

				if options and options.floored then
					x = math.floor(x)
					y = math.floor(y)
				end

				local lastColor = {love.graphics.getColor()}
				graphics.setColor(lastColor[1], lastColor[2], lastColor[3], lastColor[4] * self.alpha)

				if self.visible then
					love.graphics.draw(
						canvas,
						self.x,
						self.y,
						self.orientation,
						sx,
						sy,
						math.floor(width / 2) + self.offsetX,
						math.floor(height / 2) + self.offsetY,
						self.shearX,
						self.shearY
					)
				end
				
				love.graphics.setColor(lastColor[1], lastColor[2], lastColor[3])
			end
		}

		object:setCanvas(canvas)

		options = optionsTable

		return object
	end,

	newSprite = function(imageData, frameData, animData, animName, loopAnim, optionsTable)
		local sheets = {}

		if type(imageData) ~= "userdata" and type(imageData) == "string" then
			if not graphics.cache[imageData] then 
				if love.filesystem.getInfo(imageData) then
					graphics.cache[imageData] = love.graphics.newImage(imageData)
				else
					graphics.cache[imageData] = love.graphics.newImage("images/missing.png")
				end
			end
			imageData = graphics.cache[imageData]
		end

		local frames = {}
		local frame
		local anims = animData
		local anim = {
			name = nil,
			start = nil,
			stop = nil,
			speed = nil,
			offsetX = nil,
			offsetY = nil,
			sheet = 1,
			flipX = false,
			flipY = false,
		}

		local isAnimated
		local isLooped
		local forceFrameStart

		local options

		optionsTable = optionsTable or {}

		local lastAnimWasForced = false

		local object = {
			x = 0,
			y = 0,
			orientation = 0,
			sizeX = 1,
			sizeY = 1,
			offsetX = 0,
			offsetY = 0,
			offsetX2 = 0,
			offsetY2 = 0,
			shearX = 0,
			shearY = 0,

			scrollFactor = {x=1,y=1},

			holdTimer = 2,
			lastHit = 0,

			heyTimer = 0,
			specialAnim = false,

			clipRect = nil,
			stencilInfo = nil,

			optionsTable = optionsTable or {},

			alpha = 1,

			icon = optionsTable.icon or "boyfriend",

			flipX = optionsTable.flipX or false,

			singDuration = optionsTable.singDuration or 4,
			isCharacter = optionsTable.isCharacter or false,
			danceSpeed = optionsTable.danceSpeed or 2,
			danceIdle = optionsTable.danceIdle or false,
			maxHoldTimer = optionsTable.maxHoldTimer or 0.1,

			visible = true,

			danced = true,

			shader = nil,
			shaderEnabled = true,

			playerInputs = false,

			setSheet = function(self, imageData)
				sheet = imageData
				if #sheets == 0 then
					tblPush(sheets, self, 1)
				end
			end,

			getSheet = function(self)
				return imageData
			end,

			isAnimName = function(self, name)
				return anims[name] ~= nil
			end,

			getAnim = function(self, name)
				return anims[name]
			end,

			getAnims = function(self)
				return anims
			end,
			getAnimName = function(self)
				return anim.name
			end,
			setAnimSpeed = function(self, speed)
				anim.speed = speed
			end,
			isAnimated = function(self)
				return isAnimated
			end,
			isLooped = function(self)
				return isLooped
			end,

			setAnimFrame = function(self, frame)
				frame = frame
			end,
			getAnimFrame = function(self)
				return frame
			end,

			setOptions = function(self, optionsTable)
				options = optionsTable
			end,
			getOptions = function(self)
				return options
			end,

			update = function(self, dt)
				if self.updateOverride then 
					self:updateOverride(dt)
				end
				if isAnimated then
					frame = frame + anim.speed * dt
				end

				if isAnimated and frame > anim.stop then
					if self.func then
						self.func()
						self.func = nil
					end
					if isLooped then
						frame = forceFrameStart or anim.start
					else
						isAnimated = false
					end
				end

				self.holdTimer = self.holdTimer + dt
				local inputTbl = {}
				if self.playerInputs then
					table.insert(inputTbl, input:down("gameLeft"))
					table.insert(inputTbl, input:down("gameRight"))
					table.insert(inputTbl, input:down("gameUp"))
					table.insert(inputTbl, input:down("gameDown"))
				end
				if self.lastHit > 0 and self.lastHit + (stepCrochet or 0) * self.singDuration < math.abs(musicTime) then
					if self.specialAnim then
						self.heyTimer = self.heyTimer - dt

						if self.heyTimer <= 0 and not self:isAnimated() and
							not (self:getAnimName() == "dies" or self:getAnimName() == "dead" or
							self:getAnimName() == "dead confirm" or self:getAnimName() == "danceLeft" or
							self:getAnimName() == "danceRight")
						then

							self.heyTimer = 0
							self.specialAnim = false
							self.lastHit = -1
							if self.parent then self.parent.lastHit = -1 end
							self:dance()
						end
					else
						if not table.includes(inputTbl, true) then
							self:dance()
							self.lastHit = -1
							if self.parent then self.parent.lastHit = -1 end
						end
					end
				end
			end,

			getFrameWidth = function(self, anim)
				if anim and anims then
					return frameData[anims[anim].stop].width
				else
					return frameData[self.curFrame or 1].width
				end
			end,

			getFrameHeight = function(self, anim)
				if anim and anims then
					return frameData[anims[anim].stop].height
				else
					return frameData[self.curFrame or 1].height
				end
			end,

			getFrameNumber = function(self)
				return math.floor(frame)
			end,

			getFrame = function(self)
				local sheet = sheets[anim.sheet or 1]
				local frame = math.floor(frame or 1)
				if frame > #sheet:getAllFrames() then
					frame = #sheet:getAllFrames()
				end
				if frame < 1 then
					frame = 1
				end
				local frameData = sheet:getAllFrames()[frame]
				
				return frameData.x, frameData.y, frameData.width, frameData.height
			end,

			getAllFrames = function(self)
				return frameData
			end,

			getAllFrameQuads = function(self)
				return frames
			end,

			animateFromFrame = function(self, frame_, loopAnim, sheet)
				frame = frame_
				isAnimated = true
				isLooped = loopAnim
				anim.sheet = sheet or 1
				anim.start = frame_
				anim.stop = frame_
			end,

			animate = function(self, animName, loopAnim, func, forceSpecial, frameOverride, keepFrameOverride, forced)
				if lastAnimWasForced and isAnimated then
					return
				end
				lastAnimWasForced = forced or false
				forceSpecial = forceSpecial == nil and true or forceSpecial
				self.holdTimer = 0
				if not self:isAnimName(animName) then
					return
				end
				if self.flipX and self.isCharacter then
					if animName == "singLEFT" then
						animName = "singRIGHT"
					elseif animName == "singRIGHT" then
						animName = "singLEFT"
					end
				end
				local a = self:getAnim(animName)
				anim.name = animName
				anim.start = a.start
				anim.stop = a.stop
				anim.speed = a.speed
				anim.offsetX = a.offsetX
				anim.offsetY = a.offsetY
				anim.sheet = a.sheet or 1
				anim.flipX = a.flipX or false
				anim.flipY = a.flipY or false

				if not (util.startsWith(animName, "sing") or self:getAnimName() == "idle") and forceSpecial then -- its a special anim
					self.heyTimer = 0.6
					self.specialAnim = true
				else
					self.heyTimer = 0
					self.specialAnim = false
				end

				if not func then
					func = function()
						if self:isAnimName(self:getAnimName() .. " loop") then
							self:animate(self:getAnimName() .. " loop", true)
						end
					end
				end
				self.func = func
				
				frame = frameOverride or anim.start
				isLooped = loopAnim

				isAnimated = true

				if not keepFrameOverride then
					forceFrameStart = nil
				else
					forceFrameStart = frameOverride
				end
			end,

			getFrameQuad = function(self, frame, sheet)
				local sheet = sheets[sheet or anim.sheet]

				return sheet:getAllFrameQuads()[frame]
			end,

			getFrameData = function(self, curFrame, sheet)
				-- get frame data from the current frame and sheet
				local sheet = sheets[sheet or anim.sheet]

				return sheet:getAllFrames()[curFrame]
			end,

			getFrameDatas = function(self, sheet)
				local sheet = sheets[sheet or anim.sheet]

				return sheet:getAllFrames()
			end,

			getAnimStart = function(self)
				return anim.start
			end,

			getAnimStop = function(self)
				return anim.stop
			end,

			getFrameFromCurrentAnim = function(self)
				return math.floor(frame - anim.start + 1)
			end,

			getFrameCountFromCurrentAnim = function(self)
				return anim.stop - anim.start + 1
			end,

			getCurrentAnim = function(self)
				return anim
			end,

			beat = function(self, beat)
				local beat = math.floor(beat) or 0
				if self.lastHit <= 0 and beat % self.danceSpeed == 0 then
					self:dance(self:isAnimName("danceLeft") and self:isAnimName("danceRight"))
				end
			end,

			dance = function(self, isDanceIdle)
				if isDanceIdle then
					self.danced = not self.danced
					if self.danced then
						self:animate("danceRight")
					else
						self:animate("danceLeft")
					end
				else
					self:animate("idle")
				end
			end,

			draw = function(self)
				if not self.visible then
					return
				end
				self.curFrame = math.floor(frame or 1)
				anim = self:getCurrentAnim()
				if self.curFrame <= anim.stop then
					local x = self.x
					local y = self.y
					local width
					local height

					if options and options.floored then
						x = math.floor(x)
						y = math.floor(y)
					end

					if self.clipRect then
						self.stencilInfo = {
							x = self.clipRect.x,
							y = self.clipRect.y,
							width = self.clipRect.width,
							height = self.clipRect.height
						}
						love.graphics.stencil(function()
							love.graphics.push()
							love.graphics.translate(self.stencilInfo.x, self.stencilInfo.y)
							love.graphics.translate(-self.stencilInfo.width / 2, -self.stencilInfo.height / 2)
							love.graphics.rotate(self.orientation)
							love.graphics.rectangle("fill", 0, 0, self.stencilInfo.width, self.stencilInfo.height)
							love.graphics.pop()
						end, "replace", 1)
						love.graphics.setStencilTest("greater", 0)
					end

					local ox, oy = 0, 0

					local frameData = self:getFrameDatas()
					if options and options.noOffset then
						if frameData[self.curFrame].offsetWidth ~= 0 then
							width = frameData[self.curFrame].offsetX
						end
						if frameData[self.curFrame].offsetHeight ~= 0 then
							height = frameData[self.curFrame].offsetY
						end
					else
						-- erm... what the sigma?
						if not frameData[self.curFrame].rotated then
							if frameData[self.curFrame].offsetWidth == 0 then
								width = math.floor(frameData[self.curFrame].width / 2)
							else
								width = math.floor(frameData[self.curFrame].offsetWidth / 2) + frameData[self.curFrame].offsetX
							end
							if frameData[self.curFrame].offsetHeight == 0 then
								height = math.floor(frameData[self.curFrame].height / 2)
							else
								height = math.floor(frameData[self.curFrame].offsetHeight / 2) + frameData[self.curFrame].offsetY
							end
						else
							if frameData[self.curFrame].offsetHeight == 0 then
								width = math.floor(frameData[self.curFrame].height / 2)
							else
								width = math.floor(frameData[self.curFrame].offsetHeight / 2) +  frameData[self.curFrame].offsetY
							end
							if frameData[self.curFrame].offsetWidth == 0 then
								height = math.floor(frameData[self.curFrame].width / 2)
							else
								height = math.floor(frameData[self.curFrame].offsetWidth / 2) + frameData[self.curFrame].offsetX
							end
						end
					end

					if not frameData[self.curFrame].rotated then
						ox = width + anim.offsetX + self.offsetX
						oy = height + anim.offsetY + self.offsetY
					else
						ox = width + anim.offsetY + self.offsetY
						oy = height + anim.offsetX + self.offsetX
					end

					local lastShader = love.graphics.getShader()
					if self.shaderEnabled then
						love.graphics.setShader(self.shader)
					end
					local lastColor = {love.graphics.getColor()}
					graphics.setColor(lastColor[1], lastColor[2], lastColor[3], lastColor[4] * self.alpha)

					if self.visible then
						love.graphics.draw(
							sheets[anim.sheet]:getSheet(),
							sheets[anim.sheet]:getFrameQuad(self.curFrame),
							x + self.offsetX2,
							y + self.offsetY2,
							self.orientation + (frameData[self.curFrame].rotated and -math.rad(90) or 0),
							self.sizeX * (self.flipX and -1 or 1) * (anim.flipX and -1 or 1),
							self.sizeY * (self.flipY and -1 or 1) * (anim.flipY and -1 or 1),
							ox,
							oy,
							self.shearX,
							self.shearY
						)
					end

					if self.clipRect then 
						self.stencilInfo = nil
						love.graphics.setStencilTest()
					end

					love.graphics.setShader(lastShader)
					love.graphics.setColor(lastColor)
				end
			end,

			udraw = function(self, sx, sy)
				sx = sx or 7
				sy = sy or sx
				if not self.visible then
					return
				end
				self.curFrame = math.floor(frame or 1)
				anim = self:getCurrentAnim()
				if self.curFrame <= anim.stop then
					local x = self.x
					local y = self.y
					local width
					local height

					if options and options.floored then
						x = math.floor(x)
						y = math.floor(y)
					end

					local ox, oy = 0, 0

					local frameData = self:getFrameDatas()
					if options and options.noOffset then
						if frameData[self.curFrame].offsetWidth ~= 0 then
							width = frameData[self.curFrame].offsetX
						end
						if frameData[self.curFrame].offsetHeight ~= 0 then
							height = frameData[self.curFrame].offsetY
						end
					else
						-- erm... what the sigma?
						if not frameData[self.curFrame].rotated then
							if frameData[self.curFrame].offsetWidth == 0 then
								width = math.floor(frameData[self.curFrame].width / 2)
							else
								width = math.floor(frameData[self.curFrame].offsetWidth / 2) + frameData[self.curFrame].offsetX
							end
							if frameData[self.curFrame].offsetHeight == 0 then
								height = math.floor(frameData[self.curFrame].height / 2)
							else
								height = math.floor(frameData[self.curFrame].offsetHeight / 2) + frameData[self.curFrame].offsetY
							end
						else
							if frameData[self.curFrame].offsetHeight == 0 then
								width = math.floor(frameData[self.curFrame].height / 2)
							else
								width = math.floor(frameData[self.curFrame].offsetHeight / 2) +  frameData[self.curFrame].offsetY
							end
							if frameData[self.curFrame].offsetWidth == 0 then
								height = math.floor(frameData[self.curFrame].width / 2)
							else
								height = math.floor(frameData[self.curFrame].offsetWidth / 2) + frameData[self.curFrame].offsetX
							end
						end
					end

					if not frameData[self.curFrame].rotated then
						ox = width + anim.offsetX + self.offsetX
						oy = height + anim.offsetY + self.offsetY
					else
						ox = width + anim.offsetY + self.offsetY
						oy = height + anim.offsetX + self.offsetX
					end
					
					local lastColor = {love.graphics.getColor()}
					graphics.setColor(lastColor[1], lastColor[2], lastColor[3], lastColor[4] * self.alpha)

					if self.visible then
						love.graphics.draw(
							sheets[anim.sheet]:getSheet(),
							sheets[anim.sheet]:getFrameQuad(self.curFrame),
							x + self.offsetX2,
							y + self.offsetY2,
							self.orientation + (frameData[self.curFrame].rotated and -math.rad(90) or 0),
							sx * (self.flipX and -1 or 1) * (anim.flipX and -1 or 1),
							sy * (self.flipY and -1 or 1) * (anim.flipY and -1 or 1),
							ox,
							oy,
							self.shearX,
							self.shearY
						)
					end

					love.graphics.setColor(lastColor)
				end
			end,

			clone = function(self) 
				return self
			end
		}

		object:setSheet(imageData)
		if optionsTable.sheets then
			for _, sheet in ipairs(optionsTable.sheets) do
				table.insert(sheets, sheet)
			end
		end

		for i = 1, #frameData do
			local sw, sh = sheets[frameData[i].sheet or 1]:getSheet():getDimensions()
			table.insert(
				frames,
				love.graphics.newQuad(
					frameData[i].x,
					frameData[i].y,
					frameData[i].width,
					frameData[i].height,
					sw,
					sh
				)
			)
		end

		object:animate(animName, loopAnim)

		options = optionsTable

		return object
	end,

	newAtlas = function(atlasPath, optionsTable)
		optionsTable = optionsTable or {}
		local object = {}
		object.atlas = love.animate.newTextureAtlas()
		object.atlas:load(atlasPath, object)

		-- TODO: Wrapper for atlas

		object.x, object.y = 0, 0
		object.orientation = 0
		object.sizeX, object.sizeY = 1, 1
		object.offsetX, object.offsetY = 0, 0
		object.shearX, object.shearY = 0, 0
		object.scrollFactor = {x=1,y=1}

		object.holdTimer = 2
		object.lastHit = 0
		object.heyTimer = 0
		object.specialAnim = false
		--object.clipRect = nil
		--object.stencilInfo = nil

		object.optionsTable = optionsTable
		object.alpha = 1
		object.alpha = 1
		object.icon = optionsTable.icon or "boyfriend"
		object.flipX = optionsTable.flipX or false

		object.singDuration = optionsTable.singDuration or 4
		object.isCharacter = optionsTable.isCharacter or false
		object.danceSpeed = optionsTable.danceSpeed or 2
		object.danceIdle = optionsTable.danceIdle or false
		object.maxHoldTimer = optionsTable.maxHoldTimer or 0.1

		object.visible = true
		object.danced = true

		-- shaders no worky rn
		object.playerInputs = false

		object._symbols = {}
		function object:addSymbol(name, SN)
			self._symbols[name] = SN
		end

		function object:animate(animName, _, func, forceSpecial, frameOverride, keepFrameOverride)
			self.__currentAnim = animName

			if self._symbols[animName] then
				self.atlas:play(self._symbols[animName])
			else
				self.atlas:play(animName)
			end

			self.atlas._callback = func
		end

		function object:isAnimName(name)
			return self.atlas:isSymbol(name)
		end

		function object:getAnim(name)
			return nil
		end

		function object:getAnimName()
			return self.__currentAnim
		end
		function object:isAnimated()
			return self.atlas.playing
		end
		function object:isLooped()
			-- too lazy
		end

		function object:setAnimFrame(frame)
			---@diagnostic disable-next-line: invisible
			self.atlas._frameTimer = 0
			self.atlas.frame = frame or 0
		end
		function object:getAnimFrame()
			return self.atlas.frame
		end

		function object:setOptions(optionsTable)
			self.options = optionsTable
		end
		function object:getOptions()
			return self.options
		end

		function object:update(dt)
			if self.updateOverride then
				self:updateOverride(dt)
			end
			self.atlas:update(dt)

			self.holdTimer = self.holdTimer + dt
			local inputTbl = {}
			if self.playerInputs then
				table.insert(inputTbl, input:down("gameLeft"))
				table.insert(inputTbl, input:down("gameRight"))
				table.insert(inputTbl, input:down("gameUp"))
				table.insert(inputTbl, input:down("gameDown"))
			end
			if self.lastHit > 0 and self.lastHit + (stepCrochet or 0) * self.singDuration < math.abs(musicTime) then
				if self.specialAnim then
					self.heyTimer = self.heyTimer - dt

					if self.heyTimer <= 0 and not self:isAnimated() and
						not (self:getAnimName() == "dies" or self:getAnimName() == "dead" or
						self:getAnimName() == "dead confirm" or self:getAnimName() == "danceLeft" or
						self:getAnimName() == "danceRight")
					then

						self.heyTimer = 0
						self.specialAnim = false
						self.lastHit = -1
						if self.parent then self.parent.lastHit = -1 end
						self:dance()
					end
				else
					if not table.includes(inputTbl, true) then
						self:dance()
						self.lastHit = -1
						if self.parent then self.parent.lastHit = -1 end
					end
				end
			end
		end

		function object:getFrameWidth(anim)
			return 0
		end
		function object:getFrameHeight(anim)
			return 0
		end

		function object:beat(beat)
			local beat = math.floor(beat) or 0
			if self.lastHit <= 0 and beat % self.danceSpeed == 0 then
				self:dance(self:isAnimName("danceLeft") and self:isAnimName("danceRight"))
			end
		end

		function object:dance(isDanceIdle)
			if isDanceIdle then
				self.danced = not self.danced
				if self.danced then
					self:animate("danceRight")
				else
					self:animate("danceLeft")
				end
			else
				self:animate("idle")
			end
		end

		function object:draw()
			if not self.visible then
				return
			end

			local x = self.x
			local y = self.y

			if options and options.floored then
				x = math.floor(x)
				y = math.floor(y)
			end

			local lastColor = {love.graphics.getColor()}
			graphics.setColor(lastColor[1], lastColor[2], lastColor[3], lastColor[4] * self.alpha)

			if self.visible then
				self.atlas:draw(
					self.x,
					self.y,
					self.orientation,
					self.sizeX * (self.flipX and -1 or 1),
					self.sizeY * (self.flipY and -1 or 1),
					self.offsetX,
					self.offsetY
				)
			end

			love.graphics.setColor(lastColor[1], lastColor[2], lastColor[3])
		end

		print(object.addSymbol)

		return object
	end,

	newGradient = function(...)
		local colourLen, data = select("#", ...), {}

		for i = 1, colourLen do
			local colour = select(i, ...)
			local y = (i - 1) / (colourLen - 1)

			data[#data + 1] = {
				1, y, 1, y, colour[1], colour[2], colour[3], colour[4] or 1
			}
			data[#data + 1] = {
				0, y, 0, y, colour[1], colour[2], colour[3], colour[4] or 1
			}

		end

		return love.graphics.newMesh(data, "strip", "static")
	end,

	newGradientHorizontal = function(...)
		local colourLen, data = select("#", ...), {}

		for i = 1, colourLen do
			local colour = select(i, ...)
			local x = (i - 1) / (colourLen - 1)

			data[#data + 1] = {
				x, 0, x, 0, colour[1], colour[2], colour[3], colour[4] or 1
			}
			data[#data + 1] = {
				x, 1, x, 1, colour[1], colour[2], colour[3], colour[4] or 1
			}

		end

		return love.graphics.newMesh(data, "strip", "static")
	end,

	setFade = function(value)
		if fadeTimer then
			Timer.cancel(fadeTimer)

			isFading = false
		end

		fade[1] = value
	end,
	getFade = function(value)
		return fade[1]
	end,
	fadeOut = function(duration, func)
		if fadeTimer then
			Timer.cancel(fadeTimer)
		end

		isFading = true

		fadeTimer = Timer.tween(
			duration,
			fade,
			{0},
			"linear",
			function()
				isFading = false

				if func then func() end
			end
		)
	end,
	fadeIn = function(duration, func)
		if fadeTimer then
			Timer.cancel(fadeTimer)
		end

		isFading = true

		fadeTimer = Timer.tween(
			duration,
			fade,
			{1},
			"linear",
			function()
				isFading = false

				if func then func() end
			end
		)
	end,
	
	fadeOutWipe = function(self, duration, func)
		if fadeTimer then
			Timer.cancel(fadeTimer)
		end

		fade.height = (push:getHeight() or 720) * 2
		fade.mesh = self.newGradient({0,0,0}, {0,0,0}, {0,0,0,0})

		isFading = true

		fade.y = -fade.height
		fadeTimer = Timer.tween(
			duration,
			fade,
			{
				y = 0
			},
			"linear",
			function()
				isFading = false

				fade.mesh = nil
				if func then func() end
			end
		)
	end,
	fadeInWipe = function(self, duration, func)
		if fadeTimer then
			Timer.cancel(fadeTimer)
		end

		fade.height = (push:getHeight() or 720) * 2
		fade.mesh = self.newGradient({0,0,0,0}, {0,0,0}, {0,0,0})

		isFading = false

		fade.y = -fade.height/2
		fadeTimer = Timer.tween(
			duration*2,
			fade,
			{
				y = fade.height
			},
			"linear",
			function()
				isFading = false

				fade.mesh = nil
				if func then func() end
			end
		)
	end,

	isFading = function()
		return isFading
	end,

	clear = function(r, g, b, a, s, d)
		local fade = fade[1]

		love.graphics.clear(fade * r, fade * g, fade * b, a, s, d)
	end,
	setColor = function(r, g, b, a)
		local fade = fade[1]

		love.graphics.setColor(fade * r, fade * g, fade * b, a)
	end,
	setBackgroundColor = function(r, g, b, a)
		local fade = fade[1]

		love.graphics.setBackgroundColor(fade * r, fade * g, fade * b, a)
	end,
	getColor = function()
		local r, g, b, a = love.graphics.getColor()
		local fade = fade[1]

		return r / fade, g / fade, b / fade, a
	end
}

function graphics:initStickerData()
	self.stickerGroup = Group()
	self.stickerInfo = json.decode(love.filesystem.read("data/stickers/stickers-set1.json"))
	self.unnamedIndexStickers = {}
	for _, BALLS in pairs(self.stickerInfo.stickers) do
		table.insert(self.unnamedIndexStickers, BALLS)
	end

	self.stickerSoundsPaths = love.filesystem.getDirectoryItems("sounds/stickers/keys/")
	self.allStickerSounds = {}

	for i, _ in ipairs(self.stickerSoundsPaths) do
		table.insert(self.allStickerSounds, love.audio.newSource("sounds/stickers/keys/" .. self.stickerSoundsPaths[i], "stream"))
	end
end

function graphics:newSticker(stickerName)
	local s = self.newImage(graphics.imagePath("stickers/" .. stickerName))
	s.timing = 0

	return s
end

function graphics:doStickerTrans(func)
	isFading = true
	self.stickerGroup:clear()

	local xPos = -25
	local yPos = -25
	while xPos <= push:getWidth() do
		local rndStickerPack = self.unnamedIndexStickers[love.math.random(1, #self.unnamedIndexStickers)]
		
		local sticker = self:newSticker(rndStickerPack[love.math.random(1, #rndStickerPack)])
		sticker.visible = false

		sticker.x, sticker.y = xPos, yPos

		xPos = xPos + sticker:getWidth()/3

		if xPos >= push:getWidth() then
			if yPos <= push:getHeight() then
				xPos = -25
				yPos = yPos + love.math.random(70, 120)
			end
		end

		sticker.orientation = math.rad(love.math.random(-60, 70))


		self.stickerGroup:add(sticker)
	end

	table.shuffle(self.stickerGroup.members)

	for i, sticker in ipairs(self.stickerGroup.members) do
		sticker.timing = math.remap(i, 0, #self.stickerGroup.members, 0, 0.9)

		Timer.after(sticker.timing, function()
			sticker.visible = true
			local daSound = self.allStickerSounds[love.math.random(1, #self.allStickerSounds)]
			daSound:play()

			func()

			Timer.after(sticker.timing, function()
				sticker.visible = false
				local daSound = self.allStickerSounds[love.math.random(1, #self.allStickerSounds)]
				daSound:play()
				if i == #self.stickerGroup.members then
					isFading = false
				end
			end)
		end)
	end

	table.sort(self.stickerGroup.members, function(a, b)
		return a.timing < b.timing
	end)

	local last = self.stickerGroup.members[#self.stickerGroup.members]
	last.angle = 0
	last.x, last.y = push:getWidth()/2, push:getHeight()/2
end

function graphics:drawStickers()
	if not self.stickerGroup then return end 
	self.stickerGroup:draw()
end

return graphics