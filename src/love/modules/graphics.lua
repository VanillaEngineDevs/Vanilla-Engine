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

return {
	screenBase = function(width, height)
		screenWidth, screenHeight = width, height
	end,
	getWidth = function()
		return screenWidth
	end,
	getHeight = function()
		return screenHeight
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

		if love.filesystem.getInfo(pathStr) then
			return pathStr
		else
			return "images/png/" .. path .. ".png"
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
		if not graphics.cache[pathStr] then 
			graphics.cache[pathStr] = love.graphics.newImage(pathStr)
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

			setImage = function(self, image)
				image = image
				width = image:getWidth()
				height = image:getHeight()
			end,

			getImage = function(self)
				return image
			end,

			draw = function(self)
				local x = self.x
				local y = self.y

				if options and options.floored then
					x = math.floor(x)
					y = math.floor(y)
				end

				if self.visible then
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
			end,

			udraw = function(self, sx, sy)
				local sx = sx or 7
				local sy = sy or 7
				local x = self.x
				local y = self.y

				if options and options.floored then
					x = math.floor(x)
					y = math.floor(y)
				end

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
		}

		object:setImage(image)

		options = optionsTable

		return object
	end,

	newSprite = function(imageData, frameData, animData, animName, loopAnim, optionsTable)
		local sheet, sheetWidth, sheetHeight

		local frames = {}
		local frame
		local anims = animData
		local anim = {
			name = nil,
			start = nil,
			stop = nil,
			speed = nil,
			offsetX = nil,
			offsetY = nil
		}

		local isAnimated
		local isLooped

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

			scrollFactor = {x=1,y=1},

			holdTimer = 2,
			lastHit = 0,

			heyTimer = 0,
			specialAnim = false,

			clipRect = nil,
			stencilInfo = nil,

			alpha = 1,

			flipX = optionsTable and optionsTable.flipX or false,

			singDuration = optionsTable and optionsTable.singDuration or 4,
			isCharacter = optionsTable and optionsTable.isCharacter or false,
			danceSpeed = optionsTable and optionsTable.danceSpeed or 2,
			danceIdle = optionsTable and optionsTable.danceIdle or false,
			maxHoldTimer = optionsTable and optionsTable.maxHoldTimer or 0.1,

			visible = true,

			danced = false,

			setSheet = function(self, imageData)
				sheet = imageData
				sheetWidth = sheet:getWidth()
				sheetHeight = sheet:getHeight()
			end,

			getSheet = function(self)
				return sheet
			end,

			isAnimName = function(self, name)
				return anims[name] ~= nil
			end,

			animate = function(self, animName, loopAnim, func)
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
				anim.name = animName
				anim.start = anims[animName].start
				anim.stop = anims[animName].stop
				anim.speed = anims[animName].speed
				anim.offsetX = anims[animName].offsetX
				anim.offsetY = anims[animName].offsetY

				if not (util.startsWith(animName, "sing") or self:getAnimName() == "idle") then -- its a special anim
					self.heyTimer = 0.6
					self.specialAnim = true
				else
					self.heyTimer = 0
					self.specialAnim = false
				end

				self.func = func
				
				frame = anim.start
				isLooped = loopAnim

				isAnimated = true
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

			setOptions = function(self, optionsTable)
				options = optionsTable
			end,
			getOptions = function(self)
				return options
			end,

			update = function(self, dt)
				if isAnimated then
					frame = frame + anim.speed * dt
				end

				if isAnimated and frame > anim.stop then
					if self.func then
						self.func()
						self.func = nil
					end
					if isLooped then
						frame = anim.start
					else
						isAnimated = false
					end
				end

				self.holdTimer = self.holdTimer + dt

				if self.specialAnim then 
					self.heyTimer = self.heyTimer - dt 
					if self.heyTimer <= 0 and not self:isAnimated() and not (self:getAnimName() == "dies" or self:getAnimName() == "dead" or self:getAnimName() == "dead confirm" or self:getAnimName() == "danceLeft" or self:getAnimName() == "danceRight") then 
						self.heyTimer = 0 
						self.specialAnim = false
						self:animate("idle", false) 
					end
				end
			end,

			getFrameWidth = function(self)
				return frameData[self.curFrame].width
			end,

			getFrameHeight = function(self)
				return frameData[self.curFrame].height
			end,

			beat = function(self, beat)
				local beat = math.floor(beat) or 0
				if self.isCharacter then
					if beatHandler.onBeat() then
						if not self.danceIdle then
							if (not self:isAnimated() and util.startsWith(self:getAnimName(), "sing")) or (self:getAnimName() == "idle" or self:getAnimName() == "idle loop") then
								if beat % self.danceSpeed == 0 then 
									if self.lastHit > 0 then
										if beat % math.max(self.danceSpeed, 2) == 0 and self.lastHit + beatHandler.stepCrochet * self.singDuration <= musicTime then
											self:animate("idle", false, function()
												if self:isAnimName("idle loop") then 
													self:animate("idle loop", true)
												end
											end)
											self.lastHit = 0
										end
									elseif beat % self.danceSpeed == 0 then
										self:animate("idle", false, function()
											if self:isAnimName("idle loop") then 
												self:animate("idle loop", true)
											end
										end)
									end
								end
							end
						else
							if beat % self.danceSpeed == 0 then 
								if (not self:isAnimated() and util.startsWith(self:getAnimName(), "sing")) or (self:getAnimName() == "danceLeft" or self:getAnimName() == "danceRight" or (not self:isAnimated() and self:getAnimName() == "sad")) then
									self.danced = not self.danced
									if self.danced then
										self:animate("danceLeft", false)
									else
										self:animate("danceRight", false)
									end	
								end
							end
						end
					end
				end
			end,
			
			draw = function(self)
				self.curFrame = math.floor(frame)

				if self.curFrame <= anim.stop then
					local x = self.x
					local y = self.y
					local width
					local height

					if options and options.floored then
						x = math.floor(x)
						y = math.floor(y)
					end

					if options and options.noOffset then
						if frameData[self.curFrame].offsetWidth ~= 0 then
							width = frameData[self.curFrame].offsetX
						end
						if frameData[self.curFrame].offsetHeight ~= 0 then
							height = frameData[self.curFrame].offsetY
						end
					else
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

					if self.visible then
						love.graphics.draw(
							sheet,
							frames[self.curFrame],
							x,
							y,
							self.orientation,
							self.sizeX * (self.flipX and -1 or 1),
							self.sizeY,
							width + anim.offsetX + self.offsetX,
							height + anim.offsetY + self.offsetY,
							self.shearX,
							self.shearY
						)
					end

					if self.clipRect then 
						self.stencilInfo = nil
						love.graphics.setStencilTest()
					end
				end
			end,

			udraw = function(self, sx, sy)
				local sx = sx or 7
				local sy = sy or 7
				self.curFrame = math.floor(frame)

				if self.curFrame <= anim.stop then
					local x = self.x
					local y = self.y
					local width
					local height

					if options and options.floored then
						x = math.floor(x)
						y = math.floor(y)
					end

					if options and options.noOffset then
						if frameData[self.curFrame].offsetWidth ~= 0 then
							width = frameData[self.curFrame].offsetX
						end
						if frameData[self.curFrame].offsetHeight ~= 0 then
							height = frameData[self.curFrame].offsetY
						end
					else
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
					end

					if self.visible then
						love.graphics.draw(
							sheet,
							frames[self.curFrame],
							self.x,
							self.y,
							self.orientation,
							sx * (self.flipX and -1 or 1),
							sy,
							width + anim.offsetX + self.offsetX,
							height + anim.offsetY + self.offsetY,
							self.shearX,
							self.shearY
						)
					end
				end
			end,

			clone = function(self) 
				return self
			end
		}

		object:setSheet(imageData)

		for i = 1, #frameData do
			table.insert(
				frames,
				love.graphics.newQuad(
					frameData[i].x,
					frameData[i].y,
					frameData[i].width,
					frameData[i].height,
					sheetWidth,
					sheetHeight
				)
			)
		end

		object:animate(animName, loopAnim)

		options = optionsTable

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

		fade.height = push:getHeight() * 2
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

		fade.height = push:getHeight() * 2
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
