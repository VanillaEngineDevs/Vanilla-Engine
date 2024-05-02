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

return {
    enter = function()
        stageImages = {
            ["foreground"] = graphics.newImage(graphics.imagePath("weekend1/phillyForeground")),
            ["skybox"] = graphics.newImage(graphics.imagePath("weekend1/phillySkybox")),
            ["foregroundCity"] = graphics.newImage(graphics.imagePath("weekend1/phillyForegroundCity")),
            ["construction"] = graphics.newImage(graphics.imagePath("weekend1/phillyConstruction")),
            ["smog"] = graphics.newImage(graphics.imagePath("weekend1/phillySmog")),
            ["highway"] = graphics.newImage(graphics.imagePath("weekend1/phillyHighway")),
            ["highwayLights"] = graphics.newImage(graphics.imagePath("weekend1/phillyHighwayLights")),
            ["skyline"] = graphics.newImage(graphics.imagePath("weekend1/phillySkyline")),
            ["spraycanPile"] = graphics.newImage(graphics.imagePath("weekend1/SpraycanPile")),
            ["abot"] = graphics.newImage(graphics.imagePath("weekend1/abot")),
            ["abotBack"] = graphics.newImage(graphics.imagePath("weekend1/stereoBG")),
        }

        stageImages["skybox"].x, stageImages["skybox"].y = 351, -300
        stageImages["spraycanPile"].x, stageImages["spraycanPile"].y = -314, 248
        stageImages["highwayLights"].x, stageImages["highwayLights"].y = -272, -459
        stageImages["highway"].x, stageImages["highway"].y = -413, -325
        stageImages["construction"].x, stageImages["construction"].y = 825, -145
        stageImages["smog"].x, stageImages["smog"].y = 0, -140
        stageImages["abot"].x, stageImages["abot"].y = 62, -20
        stageImages["abotBack"].x, stageImages["abotBack"].y = 62, -20
        stageImages["skyline"].x, stageImages["skyline"].y = 100, -227
        stageImages["foregroundCity"].x, stageImages["foregroundCity"].y = -386, 38

        enemy = love.filesystem.load("sprites/weekend1/darnell.lua")()
        boyfriend = love.filesystem.load("sprites/pico-player.lua")()
        girlfriend = love.filesystem.load("sprites/weekend1/nene.lua")()

        girlfriend.STATE_DEFAULT = 0
        girlfriend.STATE_PRE_RAISE = 1
        girlfriend.STATE_RAISE = 2
        girlfriend.STATE_READY = 3
        girlfriend.STATE_LOWER = 4
        girlfriend.currentState = girlfriend.STATE_DEFAULT

        girlfriend.MIN_BLINK_DELAY = 3
        girlfriend.MAX_BLINK_DELAY = 7
        girlfriend.blinkCountdown = girlfriend.MIN_BLINK_DELAY

        girlfriend.animationFinished = false

        function girlfriend:transitionState()
            if self.currentState == self.STATE_DEFAULT then
                if health <= 0.5 then
                    self.currentState = self.STATE_PRE_RAISE
                else
                    self.currentState = self.STATE_DEFAULT
                end
            elseif self.currentState == self.STATE_PRE_RAISE then
                if health > 0.5 then
                    self.currentState = self.STATE_DEFAULT
                elseif self.animationFinished then
                    self.currentState = self.STATE_RAISE
                    self:animate("knifeRaise", false, function()
                        self:transitionState()
                        self.animationFinished = true
                    end)
                    self.animationFinished = false
                end
            elseif self.currentState == self.STATE_RAISE then
                if self.animationFinished then
                    self.currentState = self.STATE_READY
                    self.animationFinished = false
                end
            elseif self.currentState == self.STATE_READY then
                if health > 0.5 then
                    self.currentState = self.STATE_LOWER
                    self:animate("knifeLower", false, function()
                        self:transitionState()
                        self.animationFinished = true
                    end)
                end
            elseif self.currentState == self.STATE_LOWER then
                if self.animationFinished then
                    self.currentState = self.STATE_DEFAULT
                    self.animationFinished = false
                end
            else 
                self.currentState = self.STATE_DEFAULT
            end
        end

        function girlfriend:updateOverride(dt)
            self:transitionState()

            if self.currentState == self.STATE_PRE_RAISE then
                if self:getAnimName() == "danceLeft" and self:getFrameFromCurrentAnim() == self:getFrameCountFromCurrentAnim()-2 then
                    self.animationFinished = true
                    self:transitionState()
                end
            end
        end

        function girlfriend:beat(beat)
            local beat = math.floor(beat) or 0
            if self.isCharacter then
                if beatHandler.onBeat() then
                    if beat % self.danceSpeed == 0 then 
                        self.danced = not self.danced
                        
                        if self.currentState == self.STATE_DEFAULT then
                            if self.danced then
                                self:animate("danceLeft", false)
                            else
                                self:animate("danceRight", false)
                            end	
                        elseif self.currentState == self.STATE_PRE_RAISE then
                            self:animate("danceLeft")
                            self.danced = true
                        elseif self.currentState == self.STATE_READY then
                            if self.blinkCountdown == 0 then
                                self:animate("knifeIdle", false)
                                self.blinkCountdown = love.math.random(self.MIN_BLINK_DELAY, self.MAX_BLINK_DELAY)
                            else
                                self.blinkCountdown = self.blinkCountdown - 1
                            end
                        end
                    end
                end
            end
        end

        enemy.x, enemy.y = -449, 45
        boyfriend.x, boyfriend.y = 646, 106
        girlfriend.x, girlfriend.y = -12, -270

        camera:addPoint("boyfriend", -boyfriend.x + 400, -boyfriend.y + 75)
        camera:addPoint("enemy", -enemy.x - 450, -enemy.y + 75)

        camera.defaultZoom = 0.85
    end,

    load = function()

    end,

    update = function(self, dt)
    end,

    draw = function()
        stageImages["skybox"]:draw()
        love.graphics.push()
			love.graphics.translate(camera.x * 0.2, camera.y * 0.2)
            love.graphics.translate(camera.ex * 0.2, camera.ey * 0.2)

            stageImages["skyline"]:draw()
		love.graphics.pop()
        love.graphics.push()
			love.graphics.translate(camera.x * 0.35, camera.y * 0.35)
            love.graphics.translate(camera.ex * 0.35, camera.ey * 0.35)

            stageImages["foregroundCity"]:draw()
		love.graphics.pop()
        love.graphics.push()
			love.graphics.translate(camera.x * 0.65, camera.y * 0.65)
            love.graphics.translate(camera.ex * 0.65, camera.ey * 0.65)

            stageImages["construction"]:draw()
            stageImages["smog"]:draw()
		love.graphics.pop()
		love.graphics.push()
			love.graphics.translate(camera.x, camera.y)
            love.graphics.translate(camera.ex, camera.ey)
			
            stageImages["highwayLights"]:draw()
            stageImages["highway"]:draw()
		love.graphics.pop()
		love.graphics.push()
			love.graphics.translate(camera.x * 1.1, camera.y * 1.1)
            love.graphics.translate(camera.ex * 1.1, camera.ey * 1.1)

            stageImages["foreground"]:draw()
            stageImages["abotBack"]:draw()
            stageImages["abot"]:draw()
            girlfriend:draw()
            enemy:draw()
            boyfriend:draw()
            stageImages["spraycanPile"]:draw()
		love.graphics.pop()
    end,

    leave = function()
        for i, v in pairs(stageImages) do
            v = nil
		end

        graphics.clearCache()
    end
}