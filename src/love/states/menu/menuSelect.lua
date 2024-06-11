local confirmFunc


local menuButton

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
                            Gamestate.switch(menuWeek)
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
            {
                sprite = love.filesystem.load("sprites/menu/mods.lua")(),
                confirm = function()
                    status.setLoading(true)
                    graphics:fadeOutWipe(
                        0.7,
                        function()
                            Gamestate.switch(menuMods)
                            status.setLoading(false)
                        end
                    )
                end
            },
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

        for _, button in ipairs(buttons) do
            button.sprite:animate("idle", true)
        end

        buttons[menuButton].sprite:animate("hover", true)

        for i, button in ipairs(buttons) do
            button.sprite.x = -500
            button.sprite.sizeX = 0.75
            button.sprite.sizeY = 0.75

            button.sprite.y = -200 + (i - 1) * 100

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