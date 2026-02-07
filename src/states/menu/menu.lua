local upFunc, downFunc, confirmFunc, drawFunc, musicStop

local menuState

local menuNum = 1

local songNum, songAppend
local songDifficulty = 2

local transparency, isIShowSpeed
local danced = false

return {
	enter = function(self, previous)
		beatHandler.setBPM(102)
		if not music:isPlaying() then
			music:play()
		end
		function tweenMenu()
			if logo.y == -150 then
				Timer.tween(1, logo, {y = -100}, "out-expo")
			end
			if girlfriendTitle.x == 1280*0.5 then
				Timer.tween(1, girlfriendTitle, {x = 1280 * 0.4}, "out-expo")
			end
		end

		transparency = {0}
		Timer.tween(
			1,
			transparency,
			{[1] = 1},
			"out-quad"
		)
		titleBG = graphics.newSparrowAtlas()
		titleBG:load("states/title/titleBG")
		changingMenu = false
		isIShowSpeed = love.math.random(0, 200) == 0
		if not isIShowSpeed then
			logo = graphics.newSparrowAtlas(-150, -150)
			logo:load("states/title/logoBumpin")
			logo:addAnimByPrefix("bump", "logo bumpin", 24, false)
			logo:updateHitbox()
		else
			logo = GIF.new("assets/ishowmeat.gif")
		end

		--[[ girlfriendTitle = love.filesystem.load("assets/sprites/menu/girlfriend-title.lua")() ]]
		girlfriendTitle = graphics.newSparrowAtlas(1280 * 0.5, 720 * 0.07)
		print(girlfriendTitle.x, girlfriendTitle.y)
		girlfriendTitle:load("states/title/gfDanceTitle")
		girlfriendTitle:addAnimByIndices("danceLeft", "gfDance", {
			30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14
		}, nil, 24, false)
		girlfriendTitle:addAnimByIndices("danceRight", "gfDance", {
			15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29
		}, nil, 24, false)
		girlfriendTitle:play("danceRight")

		tweenMenu()

		songNum = 0

		if firstStartup then
			graphics.setFade(0)
			graphics.fadeIn(0.5)
		else graphics:fadeInWipe(0.6) end

		firstStartup = false
	end,

	update = function(self, dt)
		girlfriendTitle:update(dt)
		logo:update(dt)

		beatHandler.update(dt)

		if beatHandler.onBeat() then
			if logo and not isIShowSpeed then logo:play("bump", true) end
			if girlfriendTitle then
				if danced then
					girlfriendTitle:play("danceRight", true)
				else
					girlfriendTitle:play("danceLeft", true)
				end
				danced = not danced
			end
		end

		if not graphics.isFading() then
			if input:pressed("confirm") then
				if not changingMenu then
					audio.playSound(confirmSound)
					changingMenu = true
					graphics:fadeOutWipe(0.7, function()
						Gamestate.switch(menuSelect)
						status.setLoading(false)							
					end)
				end
			elseif input:pressed("back") then
				audio.playSound(selectSound)
				love.event.quit()
			end
		end
	end,

	draw = function(self)
		love.graphics.push()
			love.graphics.push()
				love.graphics.push()
					titleBG:draw()
				love.graphics.pop()
				love.graphics.push()
					logo:draw(isIShowSpeed and 50 or nil, isIShowSpeed and 50 or nil)
				love.graphics.pop()
				love.graphics.push()
					girlfriendTitle:draw()
				love.graphics.pop()
			love.graphics.pop()

		love.graphics.pop()
	end,

	leave = function(self)
		girlfriendTitle = nil
		logo = nil

		Timer.clear()
	end
}
