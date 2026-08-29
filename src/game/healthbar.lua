local healthbar = Object:extend()

local scoreDisplays = {}

local function loadScoreDisplay(id)
    if scoreDisplays[id] then
        return scoreDisplays[id]
    end

    local path = "assets/scripts/scoredisplays/" .. id .. ".lua"

    if not love.filesystem.getInfo(path) then
        print("WTF?", path)
        return nil
    end

    local Display = Object:extend()

    local env = setmetatable({
        Display = Display,
        add = function(obj)
            weeks:add(obj)
        end,
        remove = function(obj)
            weeks:remove(obj)
        end,
        getBoyfriend = function()
            return weeks.boyfriend
        end,
        getEnemy = function()
            return weeks.enemy
        end,
        getCamera = function()
            return uiCam
        end,
        weeks = weeks
    }, {
        __index = _G
    })

    local chunk = love.filesystem.load(path)
    setfenv(chunk, env)
    chunk()

    local display = Display()

    scoreDisplays[id] = display

    return display
end

function healthbar:new(p1, p2)
    loadScoreDisplay(settings.scoringType or "VSlice")

    self.p1Colors = {0, 1, 0}
    self.p2Colors = {1, 0, 0}

    self.p1Icon = weeks:preloadIcon(
        p1 or (weeks.enemy and weeks.enemy.healthIcon) and weeks.enemy.healthIcon or "dad",
        "enemy",
        (weeks.enemy and weeks.enemy.healthIconScale) or 1
    )

    self.p2Icon = weeks:preloadIcon(
        p2 or (weeks.boyfriend and weeks.boyfriend.healthIcon) and weeks.boyfriend.healthIcon or "boyfriend",
        "boyfriend",
        (weeks.boyfriend and weeks.boyfriend.healthIconScale) or 1
    )

    if settings.colouredHealthbar then
        self.p1Colors = self.p1Icon.useMostCommonColor
        self.p2Colors = self.p2Icon.useMostCommonColor
    end

    self.p1Icon.sizeX, self.p1Icon.sizeY = 1.5, 1.5
    self.p2Icon.sizeX, self.p2Icon.sizeY = -1.5, 1.5

    self.width = 1000
    self.height = 25

    self.x = -(self.width / 2)
    self.y = not settings.downscroll and 350 or -400

    self.p1Icon.y = self.y
    self.p2Icon.y = self.y

    self.scoringDisplay = loadScoreDisplay(settings.scoringType or "VSlice")
end

function healthbar:update(dt)
    self.p1Icon.x = self.x + self.width - 75 - weeks.healthLerp * (self.width / 2)
    self.p2Icon.x = self.x + self.width + 75 - weeks.healthLerp * (self.width / 2)

    if weeks.conductor.onBeat then
        self.p1Icon.sizeX, self.p1Icon.sizeY = 1.75, 1.75
        self.p2Icon.sizeX, self.p2Icon.sizeY = -1.75, 1.75
    end

    self.p1Icon.sizeX, self.p1Icon.sizeY = util.coolLerp(self.p1Icon.sizeX, 1.5, 0.1), self.p1Icon.sizeX
    self.p2Icon.sizeX, self.p2Icon.sizeY = util.coolLerp(self.p2Icon.sizeX, -1.5, 0.1), -self.p2Icon.sizeX

    if self.scoringDisplay and self.scoringDisplay.update then
        self.scoringDisplay:update(dt)
    end
end

function healthbar:draw(hudfade)
    love.graphics.push()
        love.graphics.translate(1280 / 2, 720 / 2)
        love.graphics.scale(0.7, 0.7)
        love.graphics.scale(uiCam.zoom, uiCam.zoom)
        love.graphics.translate(uiCam.x, uiCam.y)

        graphics.setColor(1, 1, 1, hudfade)

        graphics.setColor(self.p2Colors[1], self.p2Colors[2], self.p2Colors[3], hudfade)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

        graphics.setColor(self.p1Colors[1], self.p1Colors[2], self.p1Colors[3], hudfade)
        love.graphics.rectangle("fill", -self.x, self.y, -weeks.healthLerp * (self.width / 2), self.height)

        graphics.setColor(0, 0, 0, hudfade)
        love.graphics.setLineWidth(8)
        love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
        love.graphics.setLineWidth(1)

        graphics.setColor(1, 1, 1, hudfade)

        self.p1Icon:draw()
        self.p2Icon:draw()

        if self.scoringDisplay and self.scoringDisplay.draw then
            self.scoringDisplay:draw(hudfade)
        end
    love.graphics.pop()
end

return healthbar