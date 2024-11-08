--[[----------------------------------------------------------------------------
This file is part of Friday Night Funkin' Vanilla Engine

Copyright (C) 2024 VanillaEngineDevs & HTV04

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
------------------------------------------------------------------------------]]

local function ARGBToRGBA(rgb) -- converts to r, g, b, a
    rgb = rgb or 0xFF000000
    local a = bit.band(bit.rshift(rgb, 24), 0xFF)
    local r = bit.band(bit.rshift(rgb, 16), 0xFF)
    local g = bit.band(bit.rshift(rgb, 8), 0xFF)
    local b = bit.band(rgb, 0xFF)
    return r / 255, g / 255, b / 255, a / 255
end

local addBlendShader = love.graphics.newShader [[
extern Image texture2;
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 src = Texel(texture, texture_coords);
    // dst is the pixel UNDER the texture
    vec4 dst = Texel(texture2, texture_coords);

    //src.rgb = src.rgb * color.rgb;
    vec4 res = dst;

    return res;
}

]]

local colorShader = love.graphics.newShader("shaders/adjustColor.glsl")

return {
    enter = function(self, songExt)
        stageImages = {
            ["foreground"] = graphics.newImage(graphics.imagePath("weekend1.erect/phillyForeground")),
            ["skybox"] = graphics.newImage(graphics.imagePath("weekend1.erect/phillySkybox")),
            ["foregroundCity"] = graphics.newImage(graphics.imagePath("weekend1.erect/phillyForegroundCity")),
            ["construction"] = graphics.newImage(graphics.imagePath("weekend1.erect/phillyConstruction")),
            ["smog"] = graphics.newImage(graphics.imagePath("weekend1.erect/phillySmog")),
            ["highway"] = graphics.newImage(graphics.imagePath("weekend1.erect/phillyHighway")),
            ["highwayLights"] = graphics.newImage(graphics.imagePath("weekend1.erect/phillyHighwayLights")),
            ["skyline"] = graphics.newImage(graphics.imagePath("weekend1.erect/phillySkyline")),
            ["spraycanPile"] = graphics.newImage(graphics.imagePath("weekend1/SpraycanPile")),
        }

        stageImages.mist0 = graphics.newImage(graphics.imagePath("weekend1.erect/mistMid"))
        stageImages.mist0.vx = 172
        stageImages.mist0.alpha = 0.6
        stageImages.mist0.color = {ARGBToRGBA(0xFF5c5c5c)}
        -- add blend mode
        stageImages.mist0.scrollX, stageImages.mist0.scrollY = 1.2, 1.2
        stageImages.mist1 = graphics.newImage(graphics.imagePath("weekend1.erect/mistMid"))
        stageImages.mist1.vx = 150
        stageImages.mist1.alpha = 0.6
        stageImages.mist1.color = {ARGBToRGBA(0xFF5c5c5c)}
        -- add blend mode
        stageImages.mist1.scrollX, stageImages.mist1.scrollY = 1.1, 1.1
        stageImages.mist2 = graphics.newImage(graphics.imagePath("weekend1.erect/mistBack"))
        stageImages.mist2.vx = -80
        stageImages.mist2.alpha = 0.8
        stageImages.mist2.color = {ARGBToRGBA(0xFF5c5c5c)}
        -- add blend mode
        stageImages.mist2.scrollX, stageImages.mist2.scrollY = 1.2, 1.2
        stageImages.mist3 = graphics.newImage(graphics.imagePath("weekend1.erect/mistMid"))
        stageImages.mist3.vx = -50
        stageImages.mist3.alpha = 0.5
        stageImages.mist3.color = {ARGBToRGBA(0xFF5c5c5c)}
        stageImages.mist3.sizeX, stageImages.mist3.sizeY = 0.8, 0.8
        -- add blend mode
        stageImages.mist3.scrollX, stageImages.mist3.scrollY = 0.9, 0.9
        stageImages.mist4 = graphics.newImage(graphics.imagePath("weekend1.erect/mistBack"))
        stageImages.mist4.vx = 40
        stageImages.mist4.alpha = 1
        stageImages.mist4.color = {ARGBToRGBA(0xFF5c5c5c)}
        stageImages.mist4.sizeX, stageImages.mist4.sizeY = 0.7, 0.7
        -- add blend mode
        stageImages.mist4.scrollX, stageImages.mist4.scrollY = 0.8, 0.8
        stageImages.mist5 = graphics.newImage(graphics.imagePath("weekend1.erect/mistMid"))
        stageImages.mist5.vx = 20
        stageImages.mist5.alpha = 1
        stageImages.mist5.color = {ARGBToRGBA(0xFF5c5c5c)}
        stageImages.mist5.sizeX, stageImages.mist5.sizeY = 1.1, 1.1
        -- add blend mode
        stageImages.mist5.scrollX, stageImages.mist5.scrollY = 1.1, 1.1

        stageImages["spraycanPile"].x, stageImages["spraycanPile"].y = -314, 248

        stageImages["skybox"].x, stageImages["skybox"].y = 351, -300
        stageImages["highwayLights"].x, stageImages["highwayLights"].y = -272, -459
        stageImages["highway"].x, stageImages["highway"].y = -413, -325
        stageImages["construction"].x, stageImages["construction"].y = 825, -145
        stageImages["smog"].x, stageImages["smog"].y = 0, -140
        stageImages["skyline"].x, stageImages["skyline"].y = 100, -227
        stageImages["foregroundCity"].x, stageImages["foregroundCity"].y = -386, 38

        enemy = love.filesystem.load("sprites/characters/darnell.lua")()
        boyfriend = love.filesystem.load("sprites/characters/pico-player.lua")()
        girlfriend = NeneCharacter()

        if songExt == "-bf" then
            boyfriend = BaseCharacter("sprites/characters/boyfriend.lua")
            girlfriend = BaseCharacter("sprites/characters/girlfriend.lua")
        end

        enemy.x, enemy.y = -449, 45
        boyfriend.x, boyfriend.y = 646, 106
        girlfriend.x, girlfriend.y = -12, -270

        if songExt == "-bf" then
            girlfriend.x = girlfriend.x + 70
            girlfriend.y = girlfriend.y + 108
        end

        colorShader:send("hue", -5)
        colorShader:send("saturation", -40)
        colorShader:send("contrast", -25)
        colorShader:send("brightness", -20)

        girlfriend.shader = colorShader
        boyfriend.shader = colorShader
        enemy.shader = colorShader

        camera:addPoint("boyfriend", -boyfriend.x + 400, -boyfriend.y + 75)
        camera:addPoint("enemy", -enemy.x - 450, -enemy.y + 75)

        camera.defaultZoom = 0.85
    end,

    load = function()

    end,

    update = function(self, dt)
        
    end,

    draw = function(self, inDebug)
        stageImages["skybox"]:draw()
        love.graphics.push()
			love.graphics.translate(camera.x * 0.2, camera.y * 0.2)

            stageImages["skyline"]:draw()
		love.graphics.pop()
        love.graphics.push()
			love.graphics.translate(camera.x * 0.35, camera.y * 0.35)

            stageImages["foregroundCity"]:draw()
		love.graphics.pop()
        love.graphics.push()
			love.graphics.translate(camera.x * 0.65, camera.y * 0.65)

            stageImages["construction"]:draw()
            stageImages["smog"]:draw()
		love.graphics.pop()
		love.graphics.push()
			love.graphics.translate(camera.x, camera.y)
			
            stageImages["highwayLights"]:draw()
            stageImages["highway"]:draw()
		love.graphics.pop()
		love.graphics.push()
			love.graphics.translate(camera.x * 1.1, camera.y * 1.1)

            stageImages["foreground"]:draw()
 
            girlfriend:draw(inDebug)

            enemy:draw()
            boyfriend:draw()

            stageImages["spraycanPile"]:draw()

            --[[ local lastBlendMode, lastAlphaMode = love.graphics.getBlendMode()
            for i = 0, 5 do
                -- need to be a looping scroll
                love.graphics.push()
                    -- 3 loops
                    for j = -1, 1 do
                        if not stageImages["mist" .. i].curX then
                            stageImages["mist" .. i].curX = 0
                        end
                        local realWidth = stageImages["mist" .. i]:getWidth()/2 -- image is centered origin
                        stageImages["mist" .. i].curX = stageImages["mist" .. i].curX + (stageImages["mist" .. i].vx * love.timer.getDelta())
                        if stageImages["mist" .. i].curX > realWidth or stageImages["mist" .. i].curX < -realWidth then
                            stageImages["mist" .. i].curX = 0
                        end
                        stageImages["mist" .. i].x = stageImages["mist" .. i].curX + (realWidth * j)

                        --graphics.setColor(stageImages["mist" .. i].color[1], stageImages["mist" .. i].color[2], stageImages["mist" .. i].color[3])
                        love.graphics.setBlendMode("add")
                        stageImages["mist" .. i]:draw()
                        love.graphics.setBlendMode(lastBlendMode, lastAlphaMode)
                    end
                love.graphics.pop()
            end ]] -- CURSE YOU LOVE2D
		love.graphics.pop()
    end,

    leave = function()
        for _, v in pairs(stageImages) do
            v = nil
		end
        if girlfriend.release then girlfriend:release() end

        graphics.clearCache()
    end
}