--[[
	File created for Vanilla Engine
]]

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

        buttons = {
            {
                sprite = love.filesystem.load("sprites/menu/storymode.lua")(),
                confirm = function()
                    status.setLoading(true)
                    graphics:fadeOutWipe(
                        0.7,
                        function()
                            Gamestate.switch(menuFreeplay)
                            status.setLoading(false)
                        end
                    )
                end
            }, 
            {
                sprite = love.filesystem.load("sprites/menu/freeplay.lua")(),
                confirm = function()
                    status.setLoading(true)
                    graphics:fadeOutWipe(
                        0.7,
                        function()
                            Gamestate.switch(menuFreeplay)
                            status.setLoading(false)
                        end
                    )
                end
            },
            -- erm,,, whar the scallop
            --[[ love.system.getOS() == "NX" and {
                sprite = love.filesystem.load("sprites/menu/merch.lua")(),
                confirm = function()
                    love.system.openURL("https://needlejuicerecords.com/en-ca/pages/friday-night-funkin")
                end
            } or nil,   ]]
            {
                sprite = love.filesystem.load("sprites/menu/options.lua")(),
                confirm = function()
                    status.setLoading(true)
                    graphics:fadeOutWipe(
                        0.7,
                        function()
                            Gamestate.push(menuSettings)
                            status.setLoading(false)
                        end
                    )
                end
            },
            {
                sprite = love.filesystem.load("sprites/menu/credits.lua")(),
                confirm = function()
                    status.setLoading(true)
                    graphics:fadeOutWipe(
                        0.7,
                        function()
                            Gamestate.switch(menuCredits)
                            status.setLoading(false)
                        end
                    )
                end
            }
        }
        print(#buttons)

        --[[ options = love.filesystem.load("sprites/menu/menuButtons.lua")()
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
        credits.sizeX, credits.sizeY = 0.75, 0.75 ]]

        --[[ story.x, freeplay.x, options.x, credits.x = -500, -500, -500, -500
        Timer.tween(1, story, {x = -295}, "out-expo")
        Timer.tween(1, freeplay, {x = -320}, "out-expo")
        Timer.tween(1, options, {x = -345}, "out-expo")
        Timer.tween(1, credits, {x = -370}, "out-expo") ]]
        --Timer.tween(0.88, cam, {y = 35, sizeX = 1.1, sizeY = 1.1}, "out-quad")

        for _, button in ipairs(buttons) do
            button.sprite:animate("idle", true)
        end

        -- set all positions, more buttons there are, the y is closer to the center
        for i, button in ipairs(buttons) do
            button.sprite.x = -500
            button.sprite.sizeX = 0.75
            button.sprite.sizeY = 0.75

            button.sprite.y = -200 + (i - 1) * 100
            print(button.sprite.y)

            Timer.tween(1, button.sprite, {x = -295 - (i - 1) * 25}, "out-expo")
        end

        function changeSelect()
            for i, button in ipairs(buttons) do
                if i == menuButton then
                    button.sprite:animate("hover", true)
                else
                    button.sprite:animate("idle", true)
                end
            end
        end

        function confirmFunc()
            buttons[menuButton].confirm()
        end

		switchMenu(1)

		graphics:fadeInWipe(0.6)

	end,

	update = function(self, dt)
        for _, button in ipairs(buttons) do
            button.sprite:update(dt)
        end

        selectBG.y = 20 + math.sin(love.timer.getTime() * 1.5) * 2

		if not graphics.isFading() then
			if input:pressed("up") then
				audio.playSound(selectSound)

                menuButton = menuButton ~= 1 and menuButton - 1 or #buttons

                changeSelect()

			elseif input:pressed("down") then
				audio.playSound(selectSound)

                menuButton = menuButton ~= #buttons and menuButton + 1 or 1

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
                for _, button in ipairs(buttons) do
                    button.sprite:draw()
                end
            love.graphics.pop()
            love.graphics.setFont(font)
		love.graphics.pop()
        
	end,

	leave = function(self)
        titleBG = nil
        buttons = nil
		Timer.clear()
	end
}