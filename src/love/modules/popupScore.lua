local popupScore = {}
popupScore.__ratingMembers = {}
popupScore.__tweenObject = Timer.new()

function popupScore:init(numbersSprite, ratingSprite)
    self.__numbersSprite = numbersSprite
    self.__ratingSprite = ratingSprite

    self.combo = 0
    self.cooldown = 0.25
    self.ratingAnim = "sick"
    self.sep = pixel and 50 or 65

    self.alpha = 1
    self.obj = self.__ratingSprite()
    self.obj.x, self.obj.y = 0, 400
    self.obj.sizeX, self.obj.sizeY = 0.85, 0.85
    self.comboSprs = {}
    for i = 1, 4 do
        local spr = self.__numbersSprite()
        spr.x = self.obj.x + (i - 1) * self.sep + 30
        spr.y = self.obj.y + 35
        spr.sizeX, spr.sizeY = 0.725, 0.725
        table.insert(self.comboSprs, spr)
    end
    self.comboSprs[1].visible = false

    self.placement = {x = 0, y = 375}
end

function popupScore:setPlacement(x, y)
    self.placement.x = x
    self.placement.y = y

    self.obj.x = x
    self.obj.y = y
    for i, spr in ipairs(self.comboSprs) do
        spr.x = x + (i - 1) * self.sep + 30
        spr.y = y + 35
    end
end

function popupScore:create(anim, combo)
    local mode = settings.popupScoreMode
    if mode == "Stack" then
        local ratingObject = self.__ratingSprite() -- Creates a new instance
        ratingObject:animate(anim)

        local placement = self.placement.x

        ratingObject.x = placement
        ratingObject.y = self.placement.y
        ratingObject.accelerationY = 750
        ratingObject.velocityX, ratingObject.velocityY = love.math.random(0, 25), -love.math.random(50, 75)
        ratingObject.alpha = 1
        ratingObject.sizeX, ratingObject.sizeY = 0.85, 0.85
        ratingObject.timerReference = self.__tweenObject:after((crochet or 1) * 0.001, function()
            ratingObject.timerReference = self.__tweenObject:tween(
                0.2, ratingObject, {alpha = 0}, "linear", function()
                    self:removeRatingMember(ratingObject)
                end
            )
        end)

        table.insert(self.__ratingMembers, ratingObject)

        local seperatedScore = {}
        if combo >= 1000 then
            table.insert(seperatedScore, math.floor(combo / 1000) % 10)
        end
        table.insert(seperatedScore, math.floor(combo / 100) % 10)
        table.insert(seperatedScore, math.floor(combo / 10) % 10)
        table.insert(seperatedScore, math.floor(combo) % 10)

        for i, score in ipairs(seperatedScore) do
            local num = self.__numbersSprite()
            num.x = ratingObject.x + (i - 1) * self.sep + 30
            num.y = ratingObject.y + 35 + love.math.random(-5, 5)
            num.accelerationY = 750
            num.velocityX, num.velocityY = love.math.random(0, 10), -love.math.random(50, 75)
            num.alpha = 1
            num.sizeX, num.sizeY = 0.725, 0.725
            num.timerReference = self.__tweenObject:after((crochet or 1) * 0.001, function()
                num.timerReference = self.__tweenObject:tween(
                    0.2, num, {alpha = 0}, "linear", function()
                        self:removeRatingMember(num)
                    end
                )
            end)

            table.insert(self.__ratingMembers, num)
            
            num:animate(tostring(score))
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

function popupScore:removeRatingMember(ratingObject)
    for i, ratingObject in ipairs(self.__ratingMembers) do
        if ratingObject == ratingObject then
            table.remove(self.__ratingMembers, i)
            break
        end
    end
end

function popupScore:drawStack()
    for _, ratingObject in ipairs(self.__ratingMembers) do
        ratingObject:draw()
    end
end

function popupScore:drawSimple()
    self.obj:draw()
    for _, spr in ipairs(self.comboSprs) do
        if spr.visible then
            spr:draw()
        end
    end
end

function popupScore:udrawStack(sx, sy)
    for _, ratingObject in ipairs(self.__ratingMembers) do
        ratingObject:udraw(sx, sy)
    end
end

function popupScore:udrawSimple(sx, sy)
    self.obj:udraw(sx, sy)
    for _, spr in ipairs(self.comboSprs) do
        if spr.visible then
            spr:udraw(sx, sy)
        end
    end
end

function popupScore:draw()
    local mode = settings.popupScoreMode
    if mode == "Stack" then
        self:drawStack()
    elseif mode == "Simple" then
        self:drawSimple()
    end
end

function popupScore:udraw(sx, sy)
    local mode = settings.popupScoreMode
    if mode == "Stack" then
        self:udrawStack(sx, sy)
    elseif mode == "Simple" then
        self:udrawSimple(sx, sy)
    end
end

function popupScore:update(dt)
    local mode = settings.popupScoreMode
    if mode == "Stack" then
        self.__tweenObject:update(dt)

        for i, ratingObject in ipairs(self.__ratingMembers) do
            ratingObject.x = ratingObject.x + ratingObject.velocityX * dt
            ratingObject.y = ratingObject.y + ratingObject.velocityY * dt

            ratingObject.velocityY = ratingObject.velocityY + ratingObject.accelerationY * dt
        end
    elseif mode == "Simple" then
        self.cooldown = self.cooldown - dt
        if self.cooldown <= 0 then
            self.alpha = self.alpha - dt * 2
            if self.alpha <= 0 then
                self.alpha = 0
            end
        end

        self.obj.alpha = self.alpha
        for _, spr in ipairs(self.comboSprs) do
            spr.alpha = self.alpha
        end
    end
end

function popupScore:clear()
    for i = #self, 1, -1 do
        table.remove(self, i)
    end
end

return popupScore
