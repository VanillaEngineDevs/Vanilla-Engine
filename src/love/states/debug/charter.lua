local Group = Object:extend()
function Group:new()
    self.members = {}
end
function Group:add(obj)
    table.insert(self.members, obj)
end
function Group:remove(obj)
    for i, v in ipairs(self.members) do
        if v == obj then
            table.remove(self.members, i)
            return
        end
    end
end
function Group:update(dt)
    for i, v in ipairs(self.members) do
        v:update(dt)
    end
end
function Group:draw()
    for i, v in ipairs(self.members) do
        v:draw()
    end
end
function Group:clear()
    self.members = {}
end
function Group:__tostring()
    return "Group"
end
-- Mini Note.hx remake
Note = Sprite:extend()
Note.strumTime = 0
Note.color = {"purple", "blue", "green", "red"}
function Note:new(strumTime, noteData)
    Note.super.new(self, 0, -2000)
    self:setFrames(getSparrow("images/png/notes"))

    self.x = self.x + 50
    self.y = self.y - 2000
    self.strumTime = strumTime
    self.noteData = noteData

    local color = Note.color[noteData+1]
    self:addAnimByPrefix(color, color .. " instance 10")

    self:play(color, true)
end

local function AABB(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and
           x2 < x1 + w1 and
           y1 < y2 + h2 and
           y2 < y1 + h1
end

local function remapToRange(value, oldMin, oldMax, newMin, newMax)
    return (((value - oldMin) * (newMax - newMin)) / (oldMax - oldMin)) + newMin
end

return {
    enter = function(self)
        mainDrawing = false
        mainDrawGroup = Group()
        curSection = 1
        lastSection = 1

        curSong = "Test"
        amountSteps = 0
        bullshitUI = Group()

        strumLine = Sprite()
        highlight = Sprite()
        dummyArrow = Sprite()

        GRID_SIZE = 40

        curRenderedNotes = Group()
        curRenderedSustains = Group()

        gridBG = Sprite()

        _song = {}

        curSelectedNote = {}

        tempBpm = 0

        vocals = nil
        inst = nil

        leftIcon = Sprite()
        rightIcon = Sprite()

        curSection = lastSection

        gridBG:gridOverlay(GRID_SIZE, GRID_SIZE, GRID_SIZE*8, GRID_SIZE*16)

        gridBlackLine = Sprite(gridBG.x + gridBG.width/2)
        gridBlackLine:makeGraphic(2, math.floor(gridBG.height), "#000000")
        gridBlackLine.x = gridBG.x + gridBG.width/1.37
        gridBlackLine.y = gridBG.y + 40

        mainDrawGroup:add(gridBG)
        mainDrawGroup:add(gridBlackLine)

        _song = {
            song = "Test",
            notes = {},
            bpm = 150,
            needsVoices = true,
            player1 = "bf",
            player2 = "dad",
            speed = 1,
            validScore = false
        }

        musicTime = 0

        tempBpm = _song.bpm

        self:addSection()
        self:updateGrid()
        self:loadSong(_song.song)
        beatHandler.setBPM(_song.bpm)

        bpmChangeMap = {}

        local curBPM = _song.bpm
        local totalSteps = 0
        local totalPos = 0
        for i = 1, #_song.notes do
            if _song.notes[i].changeBPM and _song.notes[i].bpm ~= curBPM then
                curBPM = _song.notes[i].bpm
                local event = {stepTime = totalSteps, songTime = totalPos, bpm = curBPM}
                table.insert(bpmChangeMap, event)
            end

            local deltaSteps = _song.notes[i].lengthInSteps
            totalSteps = totalSteps + deltaSteps
            totalPos = totalPos + ((60/curBPM) * 1000 / 4) * deltaSteps
        end
        
        strumLine:makeGraphic(gridBG.width, 4)
        strumLine.x = 75
        mainDrawGroup:add(strumLine)

        dummyArrow:makeGraphic(GRID_SIZE, GRID_SIZE)
        mainDrawGroup:add(dummyArrow)

        local tabs = {
            {name = "Song", label = "Song"},
            {name = "Section", label = "Section"},
            {name = "Note", label = "Note"}
        }

        mainDrawGroup:add(curRenderedNotes)
        mainDrawGroup:add(curRenderedSustains)

        self:changeSection()

        music:stop()
    end,

    update = function(self, dt)
        mainDrawGroup:update(dt)

        local curStep = self:recalculateSteps()
        local curBeat = curStep % 4

        musicTime = musicTime + ((inst and inst:isPlaying() or false) and (1000 * dt) or 0)
        _song.song = curSong

        strumLine.y = self:getYfromStrum((musicTime - self:sectionStartTime()) % (beatHandler.stepCrochet * _song.notes[curSection].lengthInSteps)) + (GRID_SIZE/2)
        print(strumLine.y)
        if curBeat % 4 == 0 and curStep >= 16 * curSection then
            if _song.notes[curSection+1] == nil then
                self:addSection()
            end

            self:changeSection(curSection+1, false)
        end

        local mx, my = love.mouse.getPosition()

        if mx > gridBG.x and mx < gridBG.x + gridBG.width and my > gridBG.y and my < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps) then
            dummyArrow.x = math.floor(mx/GRID_SIZE) * GRID_SIZE + (GRID_SIZE*1.87)
            if love.keyboard.isDown("lshift") then
                dummyArrow.y = my + (GRID_SIZE/2)
            else
                dummyArrow.y = math.floor(my/GRID_SIZE) * GRID_SIZE+ GRID_SIZE
            end
        end

        if musicTime/1000 > inst:getDuration() then
            musicTime = 0
            self:changeSection()
        end

        if not love.keyboard.isDown("lshift") then
            if love.keyboard.isDown("w") or love.keyboard.isDown("s") then
                inst:pause()
                local daTime = 1000 * dt
                if love.keyboard.isDown("w") then
                    musicTime = musicTime - daTime
                else
                    musicTime = musicTime + daTime
                end

                if musicTime < 0 then
                    musicTime = 0
                elseif musicTime > inst:getDuration() * 1000 then
                    musicTime = inst:getDuration() * 1000
                end

                inst:seek(musicTime/1000)

                print(inst:tell(), daTime)
            end
        end

        --print(dummyArrow.x, dummyArrow.y)
    end,

    recalculateSteps = function()
        local lastChange = {
            stepTime = 0,
            songTime = 0,
            bpm = 0
        }
        for i = 1, #bpmChangeMap do
            if musicTime > bpmChangeMap[i].songTime then
                lastChange = bpmChangeMap[i]
            end
        end

        curStep = lastChange.stepTime + math.floor((musicTime - lastChange.songTime) / beatHandler.stepCrochet)

        return curStep
    end,

    mousepressed = function(self, mx, my)
        if mx > gridBG.x and mx < gridBG.x + gridBG.width and my > gridBG.y and my < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps) then
            self:addNote()
        end
    end,

    loadSong = function(self, song)
        if inst ~= nil then
            inst:stop()
        end
        local instPath = "songs/" .. _song.song:lower() .. "/Inst.ogg"
        inst = love.audio.newSource(instPath, "stream")
    end,

    addNote = function(self)
        local noteStrum = self:getStrumTime(dummyArrow.y) + self:sectionStartTime()
        local noteData = math.floor(love.mouse.getX()/GRID_SIZE)
        local noteSus = 0
        local noteAlt = false

        table.insert(_song.notes[curSection].sectionNotes, {noteStrum, noteData, noteSus, noteAlt})

        curSelectedNote = _song.notes[curSection].sectionNotes[#_song.notes[curSection].sectionNotes]

        self:updateGrid()

        print("Added note at time, lane, sustain, alt: ", noteStrum, noteData, noteSus, noteAlt)
    end,

    getStrumTime = function(self, ypos)
        return remapToRange(ypos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * beatHandler.stepCrochet)
    end,

    sectionStartTime = function(self)
        local daBPM = _song.bpm
        local daPos = 0
        for i = 2, curSection do
            if _song.notes[i].changeBPM then 
                daBPM = _song.notes[i].bpm
            end
            daPos = daPos + 4 * (1000 * 60 / daBPM)
        end
        return daPos
    end,

    getYfromStrum = function(self, strumTime)
        return remapToRange(strumTime, 0, 16 * beatHandler.stepCrochet, gridBG.y, gridBG.y + gridBG.height)
    end,

    addSection = function(self, lengthInSteps)
        local lengthInSteps = lengthInSteps or 16

        local sec = {
            lengthInSteps = lengthInSteps,
            bpm = _song.bpm,
            changeBPM = false,
            mustHitSection = true,
            sectionNotes = {},
            typeOfSection = 0,
            altAnim = false
        }

        table.insert(_song.notes, sec)
    end,

    changeSection = function(self, sec, updateMusic)
        local sec = sec or 1
        local updateMusic = (updateMusic == nil and true) or updateMusic

        if _song.notes[sec] ~= nil then
            curSection = sec
            self:updateGrid()

            if updateMusic then
                --
                inst:stop()
                print("Seeking to: ", self:sectionStartTime()/1000)
                inst:seek(self:sectionStartTime()/1000)
            end

            self:updateGrid()

            strumLine.y = gridBG.y + gridBG.height
        end
    end,

    updateGrid = function(self)
        while (#curRenderedNotes.members > 0) do
            table.remove(curRenderedNotes.members, 1)
        end

        while (#curRenderedSustains.members > 0) do
            table.remove(curRenderedSustains.members, 1)
        end

        local sectionInfo = _song.notes[curSection].sectionNotes

        if (_song.notes[curSection].changeBPM and _song.notes[curSection].bpm > 0) then
            beatHandler.setBPM(_song.notes[curSection].bpm)
        else
            -- get last bpm
            local daBPM = _song.bpm
            for i = 1, curSection do
                if _song.notes[i].changeBPM then
                    daBPM = _song.notes[i].bpm
                end
            end
            beatHandler.setBPM(daBPM)
        end

        for i, v in ipairs(sectionInfo) do
            local daNoteInfo = v[2]
            local daStrumTime = v[1]
            local daSus = v[3]

            local note = Note(daStrumTime, daNoteInfo % 4)
            note.sustainlength = daSus
            note:setGraphicSize(GRID_SIZE, GRID_SIZE)
            note:updateHitbox()
            note.x = math.floor(daNoteInfo*GRID_SIZE) + (GRID_SIZE*0.38)
            note.y = math.floor(self:getYfromStrum((daStrumTime - self:sectionStartTime()) % (beatHandler.stepCrochet*_song.notes[curSection].lengthInSteps))) - (GRID_SIZE*0.62)

            curRenderedNotes:add(note)
        end
    end,

    keypressed = function(self, key)
        if key == "s" then
            -- save the song as a json file as songname.json
            local json2 = {
                song = _song,
                GeneratedIn = "Vanilla Engine"
            }
            local data = json.encode(json2)

            if data ~= nil and #data > 0 then
                local filename = _song.song .. ".json"
                -- check if GeneratedSongs folder exists
                if not love.filesystem.getInfo("GeneratedSongs") then
                    love.filesystem.createDirectory("GeneratedSongs")
                end
                love.filesystem.write("GeneratedSongs/"..filename, data)
            end
        elseif key == "space" then
            if inst then
                if inst:isPlaying() then
                    inst:pause()
                else
                    inst:play()
                end
            end
        elseif key == "right" then
            self:changeSection(curSection + 1)
        elseif key == "left" then
            self:changeSection(curSection - 1)
        end
    end,

    draw = function()
        mainDrawGroup:draw()
    end,

    leave = function()
        mainDrawing = true
    end
}