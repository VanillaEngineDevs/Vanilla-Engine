-- uhhhh this file was uh made by GuglioIsStupid
-- Some code was used from sprite debug ig
local menuID, selection
local curDir, dirTable
local stageImgNames = {}
local curChanging = "stage"
return {
    stageViewerSearch = function(self, dir)
        svMode = 1

		if curDir then
			curDir = curDir .. "/" .. dir
		else
			curDir = dir
		end
		selection = 1
		dirTable = love.filesystem.getDirectoryItems(curDir)
    end,

    enter = function(self, previous)
        selection = 3

        love.keyboard.setKeyRepeat(true)

		self:stageViewerSearch("stages")

        graphics.setFade(0)
        graphics.fadeIn(0.5)
    end,

    keypressed = function(self, key)
		if svMode == 2 then
            -- Stage Positions
			if curChanging == "stage" then
				if key == "a" then
					stageImages[stageImgNames[selection]].x = stageImages[stageImgNames[selection]].x - 1
				elseif key == "d" then
					stageImages[stageImgNames[selection]].x = stageImages[stageImgNames[selection]].x + 1
				elseif key == "w" then
					stageImages[stageImgNames[selection]].y = stageImages[stageImgNames[selection]].y - 1
				elseif key == "s" then
					stageImages[stageImgNames[selection]].y = stageImages[stageImgNames[selection]].y + 1
				elseif key == "q" then 
					stageImages[stageImgNames[selection]].sizeX = stageImages[stageImgNames[selection]].sizeX - 0.1
					stageImages[stageImgNames[selection]].sizeY = stageImages[stageImgNames[selection]].sizeY - 0.1
				elseif key == "e" then
					stageImages[stageImgNames[selection]].sizeX = stageImages[stageImgNames[selection]].sizeX + 0.1
					stageImages[stageImgNames[selection]].sizeY = stageImages[stageImgNames[selection]].sizeY + 0.1
				end
			elseif curChanging == "boyfriend" then 
				if key == "a" then
					boyfriend.x = boyfriend.x - 1
				elseif key == "d" then
					boyfriend.x = boyfriend.x + 1
				elseif key == "w" then
					boyfriend.y = boyfriend.y - 1
				elseif key == "s" then
					boyfriend.y = boyfriend.y + 1
				elseif key == "q" then 
					boyfriend.sizeX = boyfriend.sizeX - 0.1
					boyfriend.sizeY = boyfriend.sizeY - 0.1
				elseif key == "e" then
					boyfriend.sizeX = boyfriend.sizeX + 0.1
					boyfriend.sizeY = boyfriend.sizeY + 0.1
				end
			elseif curChanging == "girlfriend" then 
				if key == "a" then
					girlfriend.x = girlfriend.x - 1
				elseif key == "d" then
					girlfriend.x = girlfriend.x + 1
				elseif key == "w" then
					girlfriend.y = girlfriend.y - 1
				elseif key == "s" then
					girlfriend.y = girlfriend.y + 1
				elseif key == "q" then
					girlfriend.sizeX = girlfriend.sizeX - 0.1
					girlfriend.sizeY = girlfriend.sizeY - 0.1
				elseif key == "e" then
					girlfriend.sizeX = girlfriend.sizeX + 0.1
					girlfriend.sizeY = girlfriend.sizeY + 0.1
				end
			elseif curChanging == "enemy" then 
				if key == "a" then
					enemy.x = enemy.x - 1
				elseif key == "d" then
					enemy.x = enemy.x + 1
				elseif key == "w" then
					enemy.y = enemy.y - 1
				elseif key == "s" then
					enemy.y = enemy.y + 1
				elseif key == "q" then
					enemy.sizeX = enemy.sizeX - 0.1
					enemy.sizeY = enemy.sizeY - 0.1
				elseif key == "e" then
					enemy.sizeX = enemy.sizeX + 0.1
					enemy.sizeY = enemy.sizeY + 0.1
				end
			end

			if key == "i" then 
				camera.y = camera.y + 1
			elseif key == "k" then
				camera.y = camera.y - 1
			elseif key == "j" then
				camera.x = camera.x + 1
			elseif key == "l" then
				camera.x = camera.x - 1
			end

			if key == "1" then 
				camera:moveToPoint(1.25, "boyfriend")
			elseif key == "2" then
				camera:moveToPoint(1.25, "enemy")
			end
		end
	end,

    update = function(self, dt)
		if graphics.isFading() then return end
		if svMode == 2 then
            stages[fileStr]:update(dt)
            boyfriend:update(dt)
            girlfriend:update(dt)
			enemy:update(dt)
			if input:pressed("up") then
				selection = selection - 1

				if selection < 1 then
					selection = #stageImgNames
				end
			end
			if input:pressed("down") then
				selection = selection + 1

				if selection > #stageImgNames then
					selection = 1
				end
			end
			if input:pressed("right") then 
				if curChanging == "stage" then 
					curChanging = "boyfriend"
				elseif curChanging == "boyfriend" then
					curChanging = "girlfriend"
				elseif curChanging == "girlfriend" then
					curChanging = "enemy"
				elseif curChanging == "enemy" then
					curChanging = "stage"
				end
			elseif input:pressed("left") then 
				if curChanging == "stage" then 
					curChanging = "enemy"
				elseif curChanging == "boyfriend" then
					curChanging = "stage"
				elseif curChanging == "girlfriend" then
					curChanging = "boyfriend"
				elseif curChanging == "enemy" then
					curChanging = "girlfriend"
				end
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
                    fileStr = dirTable[selection]
                    fileStr = fileStr:sub(1, -5)
                    stages[fileStr]:enter()
                    selection = 1
					self:stageViewerSearch(dirTable[selection])
				else
                    fileStr = dirTable[selection]
                    fileStr = fileStr:sub(1, -5)
                    boyfriend = love.filesystem.load("sprites/boyfriend.lua")()
                    girlfriend = love.filesystem.load("sprites/girlfriend.lua")()
                    stages[fileStr]:enter()
					if not camera.points["enemy"] then camera:addPoint("enemy", -boyfriend.x + 100, -boyfriend.y + 75) end
					if not camera.points["boyfriend"] then camera:addPoint("boyfriend", -enemy.x - 100, -enemy.y + 75) end
					for i, v in pairs(stageImages) do
						-- insert into the stageImgNames table
						table.insert(stageImgNames, i)
					end
                    selection = 1
					svMode = 2
					boyfriend:animate("idle", true)
					girlfriend:animate("idle", true)
					enemy:animate("idle", true)
				end
			end
		end

		if input:pressed("back") then
			graphics.fadeOut(0.5, love.event.quit)
		end
		if input:pressed("debugZoomOut") then
			camera.zoom = camera.zoom - 0.1
		end
		if input:pressed("debugZoomIn") then
			camera.zoom = camera.zoom + 0.1
		end
	end,

    draw = function()
		if svMode == 2 then
			graphics.clear(0.5, 0.5, 0.5)

			love.graphics.push()
				love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
				love.graphics.scale(camera.zoom, camera.zoom)
                stages[fileStr]:draw()
			love.graphics.pop()

			if curChanging == "stage" then
				love.graphics.print(stageImgNames[selection], 0, 0)
				love.graphics.print("X: " .. stageImages[stageImgNames[selection]].x ..
					"\nY:" .. stageImages[stageImgNames[selection]].y ..
					"\nSizeX:" .. stageImages[stageImgNames[selection]].sizeX ..
					"\nSizeY:" .. stageImages[stageImgNames[selection]].sizeY, 0, 40
				)
			elseif curChanging == "boyfriend" then
				love.graphics.print("Boyfriend", 0, 0)
				love.graphics.print("X: " .. boyfriend.x ..
					"\nY:" .. boyfriend.y ..
					"\nSizeX:" .. boyfriend.sizeX ..
					"\nSizeY:" .. boyfriend.sizeY, 0, 40
				)
			elseif curChanging == "girlfriend" then
				love.graphics.print("Girlfriend", 0, 0)
				love.graphics.print("X: " .. girlfriend.x ..
					"\nY:" .. girlfriend.y ..
					"\nSizeX:" .. girlfriend.sizeX ..
					"\nSizeY:" .. girlfriend.sizeY, 0, 40
				)
			elseif curChanging == "enemy" then
				love.graphics.print("Enemy", 0, 0)
				love.graphics.print("X: " .. enemy.x ..
					"\nY:" .. enemy.y ..
					"\nSizeX:" .. enemy.sizeX ..
					"\nSizeY:" .. enemy.sizeY, 0, 40
				)
			end

            love.graphics.print("\n\n\n\n\n\nCamX: " .. camera.x .. "\nCamY: " .. camera.y ..
				"\n\nPress Esc to exit at any time", 0, 40)
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