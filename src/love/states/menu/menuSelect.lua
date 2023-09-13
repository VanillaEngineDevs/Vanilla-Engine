local leftFunc, rightFunc, confirmFunc, backFunc, drawFunc

local menuState

local menuButton

local function switchMenu(menu)
	menuState = 1
end

return {
	enter = function(self, previous)
        
		menuButton = 1
		songNum = 0
        selectBGRandom = love.math.random(0, 200)

        if selectBGRandom == 0 then
            selectBG = graphics.newImage(graphics.imagePath("menu/quagmire_car"))
            selectBG.x = 430
            selectBG.y = 300
        else
            selectBG = graphics.newImage(graphics.imagePath("menu/selectBG"))
        end

        selectBG.y = 20

        selectBGOverlay = graphics.newImage(graphics.imagePath("menu/selectBGOverlay"))

        options = love.filesystem.load("sprites/menu/menuButtons.lua")()
        story = love.filesystem.load("sprites/menu/menuButtons.lua")()
        freeplay = love.filesystem.load("sprites/menu/menuButtons.lua")()
        credits = love.filesystem.load("sprites/menu/credits.lua")()
        story:animate("story hover", true)
        freeplay:animate("freeplay", true)
        options:animate("options", true)
        credits:animate("credits", true)
        story.y,freeplay.y,options.y,credits.y = -200, -50, 100, 250
        story.sizeX, story.sizeY = 0.75, 0.75
        freeplay.sizeX, freeplay.sizeY = 0.75, 0.75
        options.sizeX, options.sizeY = 0.75, 0.75
        credits.sizeX, credits.sizeY = 0.75, 0.75

        story.x, freeplay.x, options.x, credits.x = -500, -500, -500, -500
        Timer.tween(1, story, {x = -295}, "out-expo")
        Timer.tween(1, freeplay, {x = -320}, "out-expo")
        Timer.tween(1, options, {x = -345}, "out-expo")
        Timer.tween(1, credits, {x = -370}, "out-expo")
        --Timer.tween(0.88, cam, {y = 35, sizeX = 1.1, sizeY = 1.1}, "out-quad")

        function changeSelect()
            if menuButton == 1 then
                story:animate("story hover", true)
                freeplay:animate("freeplay", true)
                options:animate("options", true)
                credits:animate("credits", true)

            elseif menuButton == 2 then
                story:animate("story", true)
                freeplay:animate("freeplay hover", true)
                options:animate("options", true)
                credits:animate("credits", true)

            elseif menuButton == 3 then
                story:animate("story", true)
                freeplay:animate("freeplay", true)
                options:animate("options hover", true)
                credits:animate("credits", true)

            elseif menuButton == 4 then
                story:animate("story", true)
                freeplay:animate("freeplay", true)
                options:animate("options", true)
                credits:animate("credits hover", true)
            end
        end

        function confirmFunc()
            if menuButton == 1 then
                status.setLoading(true)
                graphics:fadeOutWipe(
                    0.7,
                    function()
                        Gamestate.switch(menuWeek)
                        status.setLoading(false)
                    end
                )
                Timer.tween(0.9, story, {x = 0}, "out-expo")
                Timer.tween(0.9, freeplay, {y = 700}, "out-expo")
                Timer.tween(0.9, options, {y = 700}, "out-expo")
                Timer.tween(0.9, credits, {y = 700}, "out-expo")
            elseif menuButton == 2 then
                status.setLoading(true)
                graphics:fadeOutWipe(
                    0.7,
                    function()
                        Gamestate.switch(menuFreeplay)
                        status.setLoading(false)
                    end
                )
                Timer.tween(0.9, freeplay, {y = 0}, "out-expo")
                Timer.tween(0.9, story, {y = -700}, "out-expo")
                Timer.tween(0.9, options, {y = 700}, "out-expo")
                Timer.tween(0.9, credits, {y = 700}, "out-expo")
            elseif menuButton == 3 then
                status.setLoading(true)
                graphics:fadeOutWipe(
                    0.7,
                    function()
                        Gamestate.push(menuSettings)
                        status.setLoading(false)
                    end
                )
                Timer.tween(0.9, freeplay, {y = -700}, "out-expo")
                Timer.tween(0.9, options, {y = 0}, "out-expo")
                Timer.tween(0.9, story, {y = -700}, "out-expo")
                Timer.tween(0.9, credits, {y = 700}, "out-expo")
            elseif menuButton == 4 then
                status.setLoading(true)
                graphics:fadeOutWipe(
                    0.7,
                    function()
                        Gamestate.switch(menuCredits)
                        status.setLoading(false)
                    end
                )
                Timer.tween(0.9, credits, {y = 0}, "out-expo")
                Timer.tween(0.9, options, {y = -700}, "out-expo")
                Timer.tween(0.9, freeplay, {y = -700}, "out-expo")
                Timer.tween(0.9, story, {y = -700}, "out-expo")
            end
        end

		switchMenu(1)

		graphics:fadeInWipe(0.6)

	end,

	update = function(self, dt)
        options:update(dt)
        story:update(dt)
        freeplay:update(dt)
        credits:update(dt)

        selectBG.y = 20 + math.sin(love.timer.getTime() * 1.5) * 2

		if not graphics.isFading() then
			if input:pressed("up") then
				audio.playSound(selectSound)

                menuButton = menuButton ~= 1 and menuButton - 1 or 4

                changeSelect()

			elseif input:pressed("down") then
				audio.playSound(selectSound)

                menuButton = menuButton ~= 4 and menuButton + 1 or 1

                changeSelect()

			elseif input:pressed("confirm") then
				audio.playSound(confirmSound)

				confirmFunc()
			elseif input:pressed("back") then
				audio.playSound(selectSound)

				Gamestate.switch(menu)
			end
		end
	end,

	draw = function(self)
		love.graphics.push()
            love.graphics.setFont(uiFont)
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
            love.graphics.push()
                selectBG:draw()
            love.graphics.pop()
            love.graphics.push()
                selectBGOverlay:draw()
            love.graphics.pop()
            love.graphics.push()
                graphics.setColor(0,0,0)
                love.graphics.print("Vanilla Engine " .. (__VERSION__ or "???") .. "\nBuilt on: Funkin Rewritten v1.1.0 Beta 2", -635, -360)
                graphics.setColor(1,1,1)
                story:draw()
                freeplay:draw()
                options:draw()
                credits:draw()
            love.graphics.pop()
            love.graphics.setFont(font)
		love.graphics.pop()
        
	end,

	leave = function(self)
        titleBG = nil
        story = nil
        freeplay = nil
        options = nil
        credits = nil
		Timer.clear()
	end
}