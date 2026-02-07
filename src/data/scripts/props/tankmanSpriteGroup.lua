local tankmanSpriteGroup = Group:extend()
local tankmanSprite = require("data.scripts.props.tankmanSprite")

local MAX_SIZE = 4
local tankmanTimes = {}
local tankmanDirs = {}
local isErect = false
local isEasterEgg = false
local reference

local function randomBool(chance)
    return love.math.random() < (chance / 100)
end

function tankmanSpriteGroup:new(erect)
    Group.new(self)
    self:initTimemap()
    self.zIndex = 30
    self.isErect = erect
end

function tankmanSpriteGroup:initTimemap()
    local animNotes = weeks:getChart().notes["picospeaker"]
    if not animNotes then
        print("NO PICOSPEAKER CHART")
    end

    table.sort(animNotes, function (a, b)
        return a.t < b.t
    end)

    for _, note in ipairs(animNotes) do
        if randomBool(1/16*100) then
            table.insert(tankmanTimes, note.t)
            local goijngRight = note.d > 1
            table.insert(tankmanDirs, goijngRight)
        end
    end

    reference = tankmanSprite()

    print(#tankmanTimes .. " tankmen will be spawned")
end

local function randomFloat(min, max)
    return min + love.math.random() * (max - min)
end

function tankmanSpriteGroup:createTankman(x, y, st, gr, scale)
    local tankman = reference:clone()

    tankman.sprite:addAnimByPrefix("run", "Running", 24, true)
    tankman.sprite:addAnimByPrefix("shot", "Shot " .. love.math.random(1, 2), 24, false)
    tankman.x = x
    tankman.y = y
    tankman.scale.x = scale
    tankman.scale.y = scale
    tankman.flipX = not gr
    tankman.strumTime = st
    tankman.endingOffset = randomFloat(50, 200)
    tankman.runSpeed = randomFloat(0.6, 1)
    tankman.goingRight = gr

    if isErect then
    end

    self:add(tankman)
end

function tankmanSpriteGroup:reset()
    self.members = {}
end

function tankmanSpriteGroup:update(dt)
    Group.update(self, dt)
end

return tankmanSpriteGroup