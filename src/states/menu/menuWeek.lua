local downFunc, confirmFunc, backFunc, drawFunc, menuFunc, menuDesc

local menuState

local menuNum = 1
local theTracks
weekNum = 1
local songNum, songAppend
local songDifficulty = 2

local difficultyStrs = {
	"easy",
	"normal",
	"hard"
}

-- TODO: Revamp this?

return {
	enter = function(self, previous)
		if not music:isPlaying() then
			music:play()
		end
		songNum = 0
		weekNum = 1
		theTracks = ""
		for trackLength = 1, #(weekData[weekNum].songs or {}) do
			local song = weekData[weekNum].songs[trackLength]
			if type(song) == "string" then
				if theTracks ~= "" then
					theTracks = theTracks .. " | " .. song
				else
					theTracks = song
				end
			end

			::continue::
		end

		currentWeek = 0


		function colourTween()
			Timer.tween(
				0.1,
				freeColour, 
				{
					[1] = freeplayColours[weekNum][1],
					[2] = freeplayColours[weekNum][2],
					[3] = freeplayColours[weekNum][3]
				}, 
				"linear"
			)
		end
		function colourTweenAlt()
			Timer.tween(
				0.1,
				freeColour, 
				{
					[1] = freeplayColours[1][1],
					[2] = freeplayColours[1][2],
					[3] = freeplayColours[1][3]
				}, 
				"linear"
			)
		end

		camera.zoom = 0.9

		freeColour = {
			255,255,255
		}
		freeplayColours = {
			{146,0,68}, -- Tutorial
			{129,100,223}, -- Week 1
			{57,60,198}, -- Week 2
			{82,231,90}, -- Week 3
			{255,166,239}, -- Week 4
			{247,243,247}, -- Week 5
			{173,235,247}, -- Week 6
			{231,139,8} -- Week 7
		}
		Timer.tween(
			0.1,
			freeColour, 
			{
				[1] = freeplayColours[1][1],
				[2] = freeplayColours[1][2],
				[3] = freeplayColours[1][3]
			}, 
			"linear"
		)
		
		titleBG = graphics.newImage(graphics.imagePath("menu/weekMenu"))

		arrowUp = love.filesystem.load("sprites/menu/menuArrow.lua")()
		arrowDown = love.filesystem.load("sprites/menu/menuArrow.lua")()
		arrowLeft = love.filesystem.load("sprites/menu/menuArrow.lua")()
		arrowRight = love.filesystem.load("sprites/menu/menuArrow.lua")()

		arrowUp.x, arrowUp.y = 0, 175
		arrowDown.x, arrowDown.y = 0, 305

		arrowLeft.x, arrowLeft.y = -250, -270
		arrowRight.x, arrowRight.y = 250, -270

		--amongus


		arrowUp.orientation = 1.5707963267949
		arrowDown.orientation = 1.5707963267949*3
		arrowRight.orientation = 1.5707963267949*2

		difficultyAnim = love.filesystem.load("sprites/menu/difficulty.lua")()

		difficultyAnim.x, difficultyAnim.y = 0, 240

		--week images
		weekImages = {}
		for i = 1, #weekData do
			table.insert(weekImages, graphics.newImage(graphics.imagePath("menu/" .. weekData[i].id)))
		end

		for i = 1, #weekImages do
			weekImages[i].y = -270
		end

		graphics:fadeInWipe(0.6)

		function confirmFunc()
			music:stop()
			songNum = 1

			status.setLoading(true)

			graphics:fadeOutWipe(
				0.7,
				function()
					storyMode = true

					music:stop()

					local selectedWeek = weekData[weekNum]
					local dif = difficultyStrs[songDifficulty] or "normal"
					
					weeks.songs = {}
					-- add all songs from weekData
					for _, song in ipairs(selectedWeek.songs or {}) do
						table.insert(weeks.songs, song)
					end
					
					poly:setPriority(selectedWeek.mod)
					Gamestate.switch(weeks, 1, dif, nil, nil, nil)
				end
			)
		end
	end,

	update = function(self, dt)
		function menuFunc()
			theTracks = ""
			for trackLength = 1, #(weekData[weekNum].songs or {}) do
				local song = weekData[weekNum].songs[trackLength]
				if type(song) == "string" then
					if theTracks ~= "" then
						theTracks = theTracks .. " | " .. song
					else
						theTracks = song
					end
				end

				::continue::
			end
		end

		arrowUp:update(dt)
		arrowDown:update(dt)
		arrowLeft:update(dt)
		arrowRight:update(dt)

		if songDifficulty == 1 then
			difficultyAnim:animate("easy", true)
		elseif songDifficulty == 2 then
			difficultyAnim:animate("normal", true)
		elseif songDifficulty == 3 then
			difficultyAnim:animate("hard", true)
		end

		difficultyAnim:update(dt)

		if not graphics.isFading() then
			if input:pressed("left") then
				audio.playSound(selectSound)

				Timer.script(function(wait)
					arrowLeft:animate("arrow pressed", false)
					wait(0.1)
					arrowLeft:animate("arrow", true)
				end)

				if currentWeek ~= 0 then
					currentWeek = currentWeek - 1
					weekNum = weekNum - 1
				else
					currentWeek = #weekData - 1
					weekNum = #weekData
				end
				if freeplayColours[weekNum] then colourTween() else colourTweenAlt() end
				menuFunc()
			elseif input:pressed("right") then
				audio.playSound(selectSound)

				Timer.script(function(wait)
					arrowRight:animate("arrow pressed", false)
					wait(0.1)
					arrowRight:animate("arrow", true)
				end)

				if currentWeek ~= #weekData - 1 then
					currentWeek = currentWeek + 1
					weekNum = weekNum + 1
				else
					currentWeek = 0
					weekNum = 1
				end
				if freeplayColours[weekNum] then colourTween() else colourTweenAlt() end
				menuFunc()
			elseif input:pressed("down") then
				audio.playSound(selectSound)

				Timer.script(function(wait)
					arrowDown:animate("arrow pressed", false)
					wait(0.1)
					arrowDown:animate("arrow", true)
				end)

				if songDifficulty ~= 1 then
					songDifficulty = songDifficulty - 1
				else
					songDifficulty = 3 
				end

			elseif input:pressed("up") then
				audio.playSound(selectSound)

				Timer.script(function(wait)
					arrowUp:animate("arrow pressed", false)
					wait(0.1)
					arrowUp:animate("arrow", true)
				end)

				if songDifficulty ~= 3 then
					songDifficulty = songDifficulty + 1
				else
					songDifficulty = 1
				end

			elseif input:pressed("confirm") then
				audio.playSound(confirmSound)

				confirmFunc()
			elseif input:pressed("back") then
				audio.playSound(selectSound)

				Gamestate.switch(menuSelect)
			end
		end

	end,

	draw = function(self)
		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)

			--titleBG:draw()

			love.graphics.push()

				love.graphics.setColor(freeColour[1]/255, freeColour[2]/255, freeColour[3]/255)
				love.graphics.scale(camera.zoom, camera.zoom)
				for i = 1, #weekData do
					if weekImages[i] then weekImages[i]:draw() end
				end

				titleBG:draw()

				love.graphics.setColor(1, 1, 1)

				difficultyAnim:draw()

				--weekImages[currentWeek + 1]:draw()
				love.graphics.setColor(freeColour[1]/255, freeColour[2]/255, freeColour[3]/255)

				if weekImages[currentWeek+1]then weekImages[currentWeek+1]:draw() end

				love.graphics.printf({{freeColour[1], freeColour[2], freeColour[3]}, weekData[weekNum].name or ""}, -639, -395, 853, "center", nil, 1.5, 1.5)

				love.graphics.printf({{freeColour[1], freeColour[2], freeColour[3]}, theTracks}, -639, 350, 853, "center", nil, 1.5, 1.5)

				love.graphics.setColor(1, 1, 1)
				arrowUp:draw()
				arrowLeft:draw()
				arrowRight:draw()
				arrowDown:draw()

			love.graphics.pop()
		love.graphics.pop()
	end,

	leave = function(self)
		titleBG = nil
		difficultyAnim = nil
		Timer.clear()
	end
}