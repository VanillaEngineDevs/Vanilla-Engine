---@diagnostic disable: missing-fields
local rimShaderBF, rimShaderEnemy, rimShaderGF

return {
    enter = function(self, songExt)
        songExt = songExt or ""
        stageImages = {
            ["BG"] = graphics.newImage(graphics.imagePath("week7.erect/bg")),
        }

        if songExt == "-pico" then
			boyfriend = BaseCharacter("sprites/characters/pico-player.lua")
			girlfriend = NeneCharacter()
        else
            girlfriend = BaseCharacter("sprites/characters/gfTankmen.lua")
		end
        
		enemy = BaseCharacter("sprites/characters/tankmanCaptain.lua")

        boyfriend.shaderEnabled = false
        girlfriend.shaderEnabled = false
        enemy.shaderEnabled = false

        rimShaderBF = love.graphics.newShader("shaders/dropShadow.glsl")
        rimShaderEnemy = love.graphics.newShader("shaders/dropShadow.glsl")
        rimShaderGF = love.graphics.newShader("shaders/dropShadow.glsl")

        rimShaderBF:send("dropColor", {hexToRGB(0xFFDFEF3C)})
        rimShaderBF:send("brightness", -46)
        rimShaderBF:send("hue", -38)
        rimShaderBF:send("contrast", -25)
        rimShaderBF:send("saturation", -20)
        rimShaderBF:send("ang", math.rad(90))

        local w, h = boyfriend:getSheet():getDimensions()
        rimShaderBF:send("textureSize", {w, h})

        rimShaderGF:send("dropColor", {hexToRGB(0xFFDFEF3C)})
        rimShaderGF:send("brightness", -46)
        rimShaderGF:send("hue", -38)
        rimShaderGF:send("contrast", -25)
        rimShaderGF:send("saturation", -20)
        rimShaderGF:send("ang", math.rad(90))
        if songExt ~= "-pico" then
            sheet = girlfriend:getSheet()
            rimShaderGF:send("useMask", true)
            rimShaderGF:send("altMask", love.graphics.newImage(graphics.imagePath("week7.erect/masks/gfTankmen_mask")))
            w, h = sheet:getDimensions()
            rimShaderGF:send("textureSize", {w, h})
        end

        rimShaderEnemy:send("dropColor", {hexToRGB(0xFFDFEF3C)})
        rimShaderEnemy:send("brightness", -46)
        rimShaderEnemy:send("hue", -38)
        rimShaderEnemy:send("contrast", -25)
        rimShaderEnemy:send("saturation", -20)
        rimShaderEnemy:send("ang", math.rad(135))
        rimShaderEnemy:send("thr", 0.3)
        w, h = enemy:getSheet():getDimensions()
        rimShaderEnemy:send("textureSize", {w, h})

        enemy.flipX = true

        stageImages["BG"].sizeX, stageImages["BG"].sizeY = 1.15, 1.15

        boyfriend.x, boyfriend.y = 491, 355
        enemy.x, enemy.y = -586, 274
        girlfriend.x, girlfriend.y = -42, 134

        camera.defaultZoom = 0.7
        camera.zoom = 0.75

        if songExt == "-pico" then
            girlfriend.y = girlfriend.y - 60
            boyfriend.y = boyfriend.y + 10
        end
    end,

    load = function(self, dt)
        
    end,

    update = function(self, dt)
        
    end,

    draw = function(self)
        love.graphics.push()
            love.graphics.translate(camera.x, camera.y)

            stageImages["BG"]:draw()

            local lastShader = love.graphics.getShader()
            love.graphics.setShader(rimShaderGF)
            local gfFrame = {girlfriend:getFrame()}
            local gfSheet = girlfriend:getSheet()

            local uvX, uvY = gfFrame[1] / gfSheet:getWidth(), gfFrame[2] / gfSheet:getHeight()
            local uvW, uvH = gfFrame[1] + gfFrame[3], gfFrame[2] + gfFrame[4]
            uvW, uvH = uvW / gfSheet:getWidth(), uvH / gfSheet:getHeight()
            rimShaderGF:send("uFrameBounds", {uvX, uvY, uvW, uvH})
            --rimShaderGF:send("textureSize", {gfFrame[3], gfFrame[4]})
            girlfriend:draw()

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
            enemy:draw()

            love.graphics.setShader(rimShaderBF)
            boyfriend:draw()
            
            love.graphics.setShader(lastShader)
        love.graphics.pop()
    end,

    leave = function()
        for _, v in pairs(stageImages) do
            v = nil
		end

        graphics.clearCache()
    end
}