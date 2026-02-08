local popupScore = {}
popupScore.__members = {}
popupScore.__tweenObject = Timer.new()

local BATCH

function popupScore:init(sprite)
    self.__sprite = sprite()
    self.__ratingSprite = sprite()

    BATCH = love.graphics.newSpriteBatch(sprite():getSheet(), 512)

    self.combo = 0
    self.cooldown = 0.25
    self.ratingAnim = "sick"
    self.sep = pixel and 50 or 65

    self.alpha = 1
    self.placement = {x = 0, y = 375}

    self.__ratingSprite.x, self.__ratingSprite.y = 0, 400
    self.__ratingSprite.sizeX, self.__ratingSprite.sizeX = 0.85, 0.85

    self.comboSprs = {}
    for i = 1, 4 do
        local spr = sprite()
        spr.x = self.__ratingSprite.x + (i-1) * (pixel and 50 or 65) + 30
        spr.y = self.__ratingSprite.y + 35
        spr.sizeX, spr.sizeY = 0.725, 0.725
        table.insert(self.comboSprs, spr)
    end
    self.comboSprs[1].visible = false
end

function popupScore:setPlacement(x, y)
    self.placement.x = x
    self.placement.y = y

    self.__ratingSprite.x = x
    self.__ratingSprite.y = y
    for i, spr in ipairs(self.comboSprs) do
        spr.x = x + (i - 1) * self.sep + 30
        spr.y = y + 35
    end
end

function popupScore:create(anim, combo)
    local mode = settings.popupScoreMode

    if mode == "Stack" then
        self.__ratingSprite:animate(anim)
        self.__ratingSprite:update(0)
        local ratingObj = {
            x = self.placement.x,
            y = self.placement.y,
            velocityX = love.math.random(0, 25),
            velocityY = -love.math.random(50, 75),
            accelerationY = 750,
            alpha = 1,
            frame = self.__ratingSprite:getCurrentFrameQuad(),
            sizeX = 0.85,
            sizeY = 0.85,
            timer = 0,
            timerMax = weeks.conductor:getBeatLengthsMS()/1000
        }
        table.insert(self.__members, ratingObj)

        local digits = {}
        if combo >= 1000 then table.insert(digits, math.floor(combo / 1000) % 10) end
        table.insert(digits, math.floor(combo / 100) % 10)
        table.insert(digits, math.floor(combo / 10) % 10)
        table.insert(digits, math.floor(combo) % 10)

        for i, digit in ipairs(digits) do
            self.__sprite:animate(tostring(digit))
            local numObj = {
                x = ratingObj.x + (i - 1) * self.sep + 30,
                y = ratingObj.y + 35 + love.math.random(-5, 5),
                velocityX = love.math.random(0, 10),
                velocityY = -love.math.random(50, 75),
                accelerationY = 750,
                alpha = 1,
                frame = self.__sprite:getCurrentFrameQuad(),
                sizeX = 0.725,
                sizeY = 0.725,
                timer = 0,
                timerMax = weeks.conductor:getBeatLengthsMS()/1000
            }
            table.insert(self.__members, numObj)
        end
    elseif mode == "Simple" then
        self.combo = combo
        self.ratingAnim = anim
        self.alpha = 1
        self.cooldown = 0.25

        self.obj:animate(anim)

        if combo >= 1000 then
            self.comboSprs[1]:animate(tostring(math.floor(combo / 1000) % 10))
            self.comboSprs[1].visible = true
        else
            self.comboSprs[1].visible = false
        end
        self.comboSprs[2]:animate(tostring(math.floor(combo / 100) % 10))
        self.comboSprs[3]:animate(tostring(math.floor(combo / 10) % 10))
        self.comboSprs[4]:animate(tostring(math.floor(combo) % 10))
    end
end

function popupScore:update(dt)
    local mode = settings.popupScoreMode

    if mode == "Stack" then
        for i = #self.__members, 1, -1 do
            local obj = self.__members[i]
            obj.x = obj.x + obj.velocityX * dt
            obj.y = obj.y + obj.velocityY * dt
            obj.velocityY = obj.velocityY + obj.accelerationY * dt
            if obj.timer >= obj.timerMax then
                obj.alpha = obj.alpha - dt * 2
            else
                obj.timer = obj.timer + dt
            end

            if obj.alpha <= 0 then
                table.remove(self.__members, i)
            end
        end
    elseif mode == "Simple" then
        self.cooldown = self.cooldown - dt
        if self.cooldown <= 0 then
            if self.timer >= self.timerMax then
                self.alpha = self.alpha - dt * 2
            else
                self.timer = self.timer + dt
            end
            if self.alpha <= 0 then self.alpha = 0 end
        end
    end
end

function popupScore:drawStack()
    BATCH:clear()
    for _, obj in ipairs(self.__members) do
        graphics.setColor(1, 1, 1, obj.alpha)
        local _, _, w, h = obj.frame:getViewport()
        BATCH:setColor(1, 1, 1, obj.alpha)
        BATCH:add(obj.frame, obj.x - w/2, obj.y - h/2, 0, obj.sizeX, obj.sizeY)
    end
    graphics.setColor(1, 1, 1)
    love.graphics.draw(BATCH)
end

function popupScore:drawSimple()
    self.__ratingSprite:draw()
    for _, spr in ipairs(self.comboSprs) do
        if spr.visible then
            spr:draw()
        end
    end
end

function popupScore:draw()
    if settings.popupScoreMode == "Stack" then
        self:drawStack()
    else
        self:drawSimple()
    end
end

return popupScore
