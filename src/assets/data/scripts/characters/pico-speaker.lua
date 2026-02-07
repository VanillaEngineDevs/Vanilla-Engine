local shootTimes = {}
local shootDirs = {}

function Character:postCreate()
    self.data.x = self.data.x + 230
    self.data.y = self.data.y + 60

    self:initTimemap()
end

function Character:initTimemap()
    shootTimes = {}
    shootDirs = {}

    local animNotes = weeks:getChart().notes["picospeaker"]
    if not animNotes then
        print("NO PICOSPEAKER CHART")
    end

    table.sort(animNotes, function (a, b)
        return a.t < b.t
    end)

    for _, note in ipairs(animNotes) do
        print("Added shoot note at time " .. note.t .. " with direction " .. note.d)
        table.insert(shootTimes, note.t)
        table.insert(shootDirs, note.d)
    end
end

function Character:onUpdate(dt)
    while #shootTimes > 0 and (shootTimes[1] or -1000) <= weeks.conductor.musicTime do
        table.remove(shootTimes, 1)
        local nextDir = table.remove(shootDirs, 1)

        self:playPicoAnimation(nextDir)
    end
end

function Character:playPicoAnimation(dir)
    if dir == 0 then
        self.data:play("shoot1", true, false)
    elseif dir == 1 then
        self.data:play("shoot2", true, false)
    elseif dir == 2 then
        self.data:play("shoot3", true, false)
    elseif dir == 3 then
        self.data:play("shoot4", true, false)
    end
end
