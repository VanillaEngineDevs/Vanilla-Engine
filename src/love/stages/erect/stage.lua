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


local colorShaderBF, colorShaderDad, colorShaderGF

return {
    enter = function(self, songExt)
        songExt = songExt or ""
        stageImages = {
            back = graphics.newImage(graphics.imagePath("week1/backDark")),
            bg = graphics.newImage(graphics.imagePath("week1/bg")),
            brightLightSmall = graphics.newImage(graphics.imagePath("week1/brightLightSmall")),
            lightAbove = graphics.newImage(graphics.imagePath("week1/lightAbove")),
            lightGreen = graphics.newImage(graphics.imagePath("week1/lightgreen")),
            lightRed = graphics.newImage(graphics.imagePath("week1/lightred")),
            lights = graphics.newImage(graphics.imagePath("week1/lights")),
            orangeLight = graphics.newImage(graphics.imagePath("week1/orangeLight")),
            server = graphics.newImage(graphics.imagePath("week1/server")),
            crowd = love.filesystem.load("sprites/week1/crowd.lua")()
        }

        stageImages.back.x, stageImages.back.y = 640, -162
        stageImages.brightLightSmall.x, stageImages.brightLightSmall.y = 718, -211
        stageImages.lightAbove.x, stageImages.lightAbove.y = 121, 230
        stageImages.lightGreen.x, stageImages.lightGreen.y = -664, -74
        stageImages.lightRed.x, stageImages.lightRed.y = -614, 253
        stageImages.lights.x, stageImages.lights.y = 0, -340
        stageImages.orangeLight.x, stageImages.orangeLight.y = 8, 35
        stageImages.server.x, stageImages.server.y = -653, 98
        stageImages.crowd.x, stageImages.crowd.y = 678, 82

        enemy = BaseCharacter("sprites/characters/daddy-dearest.lua")
        if songExt == "-pico" then
            boyfriend = BaseCharacter("sprites/characters/pico-player.lua")
            girlfriend = NeneCharacter()
        end

        -- color shaders are fast enough to run on the switch
        colorShaderBF = love.graphics.newShader("shaders/adjustColor.glsl")
        colorShaderDad = love.graphics.newShader("shaders/adjustColor.glsl")
        colorShaderGF = love.graphics.newShader("shaders/adjustColor.glsl")

        colorShaderBF:send("brightness", -23)
        colorShaderBF:send("hue", 12)
        colorShaderBF:send("contrast", 7)

        colorShaderBF:send("brightness", -30)
        colorShaderBF:send("hue", -9)
        colorShaderBF:send("contrast", -4)

        colorShaderDad:send("brightness", -33)
        colorShaderDad:send("hue", -32)
        colorShaderDad:send("contrast", -23)

        girlfriend.x, girlfriend.y = 30, 23
        enemy.x, enemy.y = -554, 33
        boyfriend.x, boyfriend.y = 388, 231

        if songExt == "-pico" then
            girlfriend.y = girlfriend.y - 60
            boyfriend.y = boyfriend.y + 10
        end
    
        enemy.shader = colorShaderDad
        boyfriend.shader = colorShaderBF
        girlfriend.shader = colorShaderGF

        camera.defaultZoom = 0.85
        camera.zoom = 0.87
    end,

    load = function()
        camera:addPoint("enemy", 167, 11)
    end,

    update = function(self, dt)
        stageImages.crowd:update(dt)
    end,

    draw = function()
        love.graphics.push()
            love.graphics.push()
                love.graphics.translate(camera.x, camera.y)
                stageImages.back:draw()
                stageImages.crowd:draw()
                stageImages.bg:draw()
                stageImages.server:draw()
            love.graphics.pop()
            love.graphics.push()
                love.graphics.translate(camera.x * 1.2, camera.y * 1.2)
                stageImages.brightLightSmall:draw()
                stageImages.lights:draw()
            love.graphics.pop()
            love.graphics.push()
                love.graphics.translate(camera.x, camera.y)
                -- add blend mode
                local lastBlendMode, lastAlphaMode = love.graphics.getBlendMode()
                love.graphics.setBlendMode("add")
                stageImages.orangeLight:draw()
                stageImages.lightGreen:draw()
                stageImages.lightRed:draw()
                love.graphics.setBlendMode(lastBlendMode, lastAlphaMode)

                girlfriend:draw()

                boyfriend:draw()

                enemy:draw()

                love.graphics.setBlendMode("add")
                stageImages.lightAbove:draw()
                love.graphics.setBlendMode(lastBlendMode, lastAlphaMode)
            love.graphics.pop()
        love.graphics.pop()
    end,

    leave = function()
        for _, v in pairs(stageImages) do
            v = nil
		end

        graphics.clearCache()
    end
}