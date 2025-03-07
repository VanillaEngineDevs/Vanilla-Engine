local cutscene = {}

function cutscene.video(path)
    local video = {
        video = love.graphics.newVideo(path),
        finished = false,
        x = 0,
        y = 0,
        orientation = 0,
        scale = 1,
        offsetX = 0,
        offsetY = 0,
        shearX = 0,
        shearY = 0,

        play = function(self)
            self.video:play()
            self.finished = false
            inCutscene = true
        end,

        stop = function(self)
            self.video:stop()
            self.finished = true
        end,

        pause = function(self)
            self.video:pause()
        end,

        resume = function(self)
            self.video:resume()
        end,

        stopped = function(self, func)
            if not self.finished then
                if func then func() end
            end
        end,

        onConfirmPressed = function(self, func)
            -- force finish
            self.finished = true
            if func then func() end
            self.video:pause()
        end,

        isPlaying = function(self, func)
            return self.video:isPlaying()
        end,

        draw = function(self)
            love.graphics.draw(
                self.video,
                self.x,
                self.y,
                self.orientation,
                self.scale,
                self.scale,
                self.offsetX,
                self.offsetY,
                self.shearX,
                self.shearY
            )
        end,

        destroy = function(self)
            self.video:release()
            collectgarbage()
        end
    }

    return video
end

return cutscene