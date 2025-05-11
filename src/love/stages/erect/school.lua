---@diagnostic disable: missing-fields
local rimShaderBF, rimShaderEnemy, rimShaderGF
local abotSpeakerShader
local hideDancers = false

return {
    enter = function(self, songExt)
		songExt = songExt or ""
		pixel = true
		love.graphics.setDefaultFilter("nearest")
        stageImages = {
            ["Sky"] = graphics.newImage(graphics.imagePath("week6.erect/sky")), -- sky
			["School"] = graphics.newImage(graphics.imagePath("week6.erect/school")), -- school
			["Street"] = graphics.newImage(graphics.imagePath("week6.erect/street")), -- street
			["Trees Back"] = graphics.newImage(graphics.imagePath("week6.erect/trees-back")), -- trees-back
			["Trees"] = love.filesystem.load("sprites/week6.erect/trees.lua")(), -- trees
			["Petals"] = love.filesystem.load("sprites/week6.erect/petals.lua")(), -- petals
        }
		girlfriend = BaseCharacter("sprites/characters/girlfriend-pixel.lua")
		boyfriend = BaseCharacter("sprites/characters/boyfriend-pixel.lua")
		enemy = BaseCharacter("sprites/characters/senpai.lua")
		enemy.colours = {255,170,111}
		fakeBoyfriend = BaseCharacter("sprites/characters/boyfriend-pixel-dead.lua") -- Used for game over
		if settings.pixelPerfect then
			girlfriend.x, girlfriend.y = 0, 0
			boyfriend.x, boyfriend.y = 50, 30
			fakeBoyfriend.x, fakeBoyfriend.y = 50, 30
			enemy.x, enemy.y = -100, 0
		else
			girlfriend.x, girlfriend.y = 30, -50
			boyfriend.x, boyfriend.y = 300, 190
			fakeBoyfriend.x, fakeBoyfriend.y = 300, 190
			enemy.x, enemy.y = -540, -20
		end

		rimShaderBF = love.graphics.newShader("shaders/dropShadow.glsl")

		rimShaderBF:send("ang", math.rad(90))
		rimShaderBF:send("altMask", love.graphics.newImage(graphics.imagePath("week6.erect/masks/bfPixel_mask")))
		rimShaderBF:send("useMask", true)
		rimShaderBF:send("thr2", 1)
		rimShaderBF:send("dropColor", {hexToRGB(0xFF52351D)})
		rimShaderBF:send("dist", 3)
		rimShaderBF:send("brightness", -66)
		rimShaderBF:send("hue", -10)
		rimShaderBF:send("contrast", 24)
		rimShaderBF:send("saturation", -23)
		local sheet = boyfriend:getSheet()
		local w, h = sheet:getDimensions()
		rimShaderBF:send("textureSize", {w, h})

		rimShaderEnemy = love.graphics.newShader("shaders/dropShadow.glsl")
		rimShaderEnemy:send("ang", math.rad(90))
		rimShaderEnemy:send("altMask", love.graphics.newImage(graphics.imagePath("week6.erect/masks/senpai_mask")))
		rimShaderEnemy:send("useMask", true)
		rimShaderEnemy:send("thr2", 1)
		rimShaderEnemy:send("dropColor", {hexToRGB(0xFF52351D)})
		rimShaderEnemy:send("dist", 3)
		rimShaderEnemy:send("brightness", -66)
		rimShaderEnemy:send("hue", -10)
		rimShaderEnemy:send("contrast", 24)
		rimShaderEnemy:send("saturation", -23)
		sheet = enemy:getSheet()
		w, h = sheet:getDimensions()
		rimShaderEnemy:send("textureSize", {w, h})

		rimShaderGF = love.graphics.newShader("shaders/dropShadow.glsl")
		rimShaderGF:send("ang", math.rad(90))
		if songExt == "-pico" then
			hideDancers = true
			-- use nene mask
			rimShaderGF:send("altMask", love.graphics.newImage(graphics.imagePath("week6.erect/masks/nenePixel_mask")))
		else
			rimShaderGF:send("altMask", love.graphics.newImage(graphics.imagePath("week6.erect/masks/gfPixel_mask")))
		end
		rimShaderGF:send("useMask", false)
		rimShaderGF:send("thr2", 1)
		rimShaderGF:send("dropColor", {hexToRGB(0xFF52351D)})
		rimShaderGF:send("dist", 3)
		rimShaderGF:send("brightness", -66)
		rimShaderGF:send("hue", -10)
		rimShaderGF:send("contrast", 24)
		rimShaderGF:send("saturation", -23)
		sheet = girlfriend:getSheet()
		w, h = sheet:getDimensions()
		rimShaderGF:send("textureSize", {w, h})

		abotSpeakerShader = love.graphics.newShader("shaders/dropShadow.glsl")
		abotSpeakerShader:send("dropColor", {hexToRGB(0xFF52351D)})
		abotSpeakerShader:send("brightness", -66)
		abotSpeakerShader:send("hue", -10)
		abotSpeakerShader:send("contrast", 24)
		abotSpeakerShader:send("saturation", -23)

		if songExt == "-pico" then
			girlfriend = PixelNeneCharacter()
			girlfriend.y = -125
			girlfriend:setY()

			boyfriend = BaseCharacter("sprites/characters/pico-pixel.lua")
			rimShaderBF:send("altMask", love.graphics.newImage(graphics.imagePath("week6.erect/masks/picoPixel_mask")))
			boyfriend.x, boyfriend.y = 500, 190
		end

		camera:addPoint("enemy", 250, 50)
		camera:addPoint("boyfriend", -200, -65)
    end,

    load = function(self)
        if song == 3 then
            enemy = BaseCharacter("sprites/characters/spirit.lua")
            stageImages["School"] = love.filesystem.load("sprites/week6/evil-school.lua")()
			enemy.x, enemy.y = -50, 0
        elseif song == 2 then
            enemy = BaseCharacter("sprites/characters/senpai-angry.lua")
			enemy.colours = {255,170,111}
			enemy.x, enemy.y = -50, 0
        end
    end,

    update = function(self, dt)
        if song ~= 3 then
			stageImages["Trees"]:update(dt)
			stageImages["Petals"]:update(dt)
		else
			stageImages["School"]:update(dt)
		end
    end,

    draw = function()
		if not settings.pixelPerfect then
			love.graphics.push()
				love.graphics.translate(camera.x * 0.9, camera.y * 0.9)

				if song ~= 3 then
					stageImages["Sky"]:udraw()
				end

				stageImages["School"]:udraw()
				if song ~= 3 then
					stageImages["Street"]:udraw()
					stageImages["Trees Back"]:udraw()

					stageImages["Trees"]:udraw()
					stageImages["Petals"]:udraw()
				end

				local lastShader = love.graphics.getShader()

				if hideDancers then -- its nene, just don't wanna make another variable -- wait im stupid, theres a girlfriend.name parameter
					local gfFrame = {girlfriend:getFrame()}
					local gfSheet = girlfriend:getSheet()

					local uvX, uvY = gfFrame[1] / gfSheet:getWidth(), gfFrame[2] / gfSheet:getHeight()
					local uvW, uvH = gfFrame[1] + gfFrame[3], gfFrame[2] + gfFrame[4]
					uvW, uvH = uvW / gfSheet:getWidth(), uvH / gfSheet:getHeight()
					rimShaderGF:send("uFrameBounds", {uvX, uvY, uvW, uvH})
				else
					love.graphics.setShader(rimShaderGF)
				end
				girlfriend:udraw(nil, nil, rimShaderGF, abotSpeakerShader)
				love.graphics.setShader(lastShader)
			love.graphics.pop()
			love.graphics.push()
				love.graphics.translate(camera.x, camera.y)
				local lastShader = love.graphics.getShader()

				local bfFrame = {boyfriend:getFrame()}
				local enemyFrame = {enemy:getFrame()}
				local bfSheet = boyfriend:getSheet()
				local enemySheet = enemy:getSheet()

				local uvX, uvY = bfFrame[1] / bfSheet:getWidth(), bfFrame[2] / bfSheet:getHeight()
				local uvW, uvH = bfFrame[1] + bfFrame[3], bfFrame[2] + bfFrame[4]
				uvW, uvH = uvW / bfSheet:getWidth(), uvH / bfSheet:getHeight()

				rimShaderBF:send("uFrameBounds", {uvX, uvY, uvW, uvH})

				uvX, uvY = enemyFrame[1] / enemySheet:getWidth(), enemyFrame[2] / enemySheet:getHeight()
				uvW, uvH = enemyFrame[1] + enemyFrame[3], enemyFrame[2] + enemyFrame[4]
				uvW, uvH = uvW / enemySheet:getWidth(), uvH / enemySheet:getHeight()
				rimShaderEnemy:send("uFrameBounds", {uvX, uvY, uvW, uvH})

				love.graphics.setShader(rimShaderEnemy)
				enemy:udraw()
				love.graphics.setShader(rimShaderBF)
				boyfriend:udraw()

				love.graphics.setShader(lastShader)
			love.graphics.pop()
		else
			love.graphics.push()
				love.graphics.translate(camera.x * 0.9, camera.y * 0.9)

				if song ~= 3 then
					stageImages["Sky"]:draw()
				end

				stageImages["School"]:draw()
				if song ~= 3 then
					stageImages["Street"]:draw()
					stageImages["Trees Back"]:draw()

					stageImages["Trees"]:draw()
					stageImages["Petals"]:draw()
				end
				girlfriend:draw()
			love.graphics.pop()
			love.graphics.push()
				love.graphics.translate(camera.x, camera.y)
				local lastShader = love.graphics.getShader()

				love.graphics.setShader(rimShaderEnemy)
				enemy:draw()
				love.graphics.setShader(rimShaderBF)
				boyfriend:draw()
				
				love.graphics.setShader(lastShader)
			love.graphics.pop()
		end
    end,

    leave = function()
        for _, v in pairs(stageImages) do
			v = nil
		end

		graphics.clearCache()
    end
}