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

        curSong = "test"
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

        images = {
            icons = love.graphics.newImage(graphics.imagePath("icons")),
        }
        sprites = {
            icons = love.filesystem.load("sprites/icons.lua")
        }

        leftIcon = sprites.icons()
        rightIcon = sprites.icons()

        leftIcon:animate(_song.player1)
        rightIcon:animate(_song.player2)

        curSection = lastSection

        gridBG:gridOverlay(GRID_SIZE, GRID_SIZE, GRID_SIZE*8, GRID_SIZE*16)

        gridBlackLine = Sprite(gridBG.x + gridBG.width/2)
        gridBlackLine:makeGraphic(2, math.floor(gridBG.height), "#000000")
        gridBlackLine.x = gridBG.x + gridBG.width/1.37
        gridBlackLine.y = gridBG.y + 40

        mainDrawGroup:add(gridBG)
        mainDrawGroup:add(gridBlackLine)

        mainDrawGroup:add(leftIcon)
        mainDrawGroup:add(rightIcon)

        leftIcon.sizeX, leftIcon.sizeY = 0.75, 0.75
        rightIcon.sizeX, rightIcon.sizeY = 0.75, 0.75

        leftIcon.x, leftIcon.y = 75, 680
        rightIcon.x, rightIcon.y = 250, 680

        if love.filesystem.getInfo("data/" .. curSong) then
            -- check if curSong.json exists
            if love.filesystem.getInfo("data/" .. curSong .. "/" .. curSong .. ".json") then
                -- load curSong.json
                _song = json.decode(love.filesystem.read("data/" .. curSong .. "/" .. curSong .. ".json")).song
            else
                -- create curSong.json
                _song = {
                    song = "guns",
                    notes = {},
                    bpm = 150,
                    needsVoices = true,
                    player1 = "bf",
                    player2 = "dad",
                    speed = 1,
                    validScore = false
                }
            end
        else
            -- create curSong.json
            _song = {
                song = "guns",
                notes = {},
                bpm = 150,
                needsVoices = true,
                player1 = "bf",
                player2 = "dad",
                speed = 1,
                validScore = false
            }
        end


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

        tabs = {
            {name = "Song", label = "Song", selected=true},
            {name = "Section", label = "Section", selected=false},
            {name = "Note", label = "Note", selected=false},
            {name = "Charting", label = "Charting", selected=false},
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
                if voices then voices:pause() end
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
                if voices then voices:seek(musicTime/1000) end

                --print(inst:tell(), daTime)
            end
        end

        --print(dummyArrow.x, dummyArrow.y)
    end,

    updateSectionUI = function(self)
        local sec = _song.notes[curSection]

        check_mustHitSection = sec.mustHitSection
        --print(check_mustHitSection)

        self:updateHeads()
    end,

    drawSongUI = function()

    end,

    drawSectionUI = function()

    end,

    drawNoteUI = function()

    end,

    updateHeads = function(self)
        if check_mustHitSection then
            leftIcon:animate(_song.player1)
            rightIcon:animate(_song.player2)
            --print(leftIcon:isAnimName(_song.player1), leftIcon:isAnimName(_song.player2), rightIcon:isAnimName(_song.player1), rightIcon:isAnimName(_song.player2), _song.player1, _song.player2)
        else
            leftIcon:animate(_song.player2)
            rightIcon:animate(_song.player1)
        end
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
            --self:addNote()

            -- if the mouse overlaps with any notes in curRenderedNotes.members, delete the first note, if none, add a note
            local noteFound = false
            for i = 1, #curRenderedNotes.members do
                local mx, my = love.mouse.getPosition()
                if AABB(mx, my+(GRID_SIZE/2), 1, 1, curRenderedNotes.members[i].x, curRenderedNotes.members[i].y, curRenderedNotes.members[i].width, curRenderedNotes.members[i].height) then
                    noteFound = true
                    self:deleteNote(curRenderedNotes.members[i])
                    break
                end
            end

            if not noteFound then
                self:addNote()
            end
        end

        --[[ tabs[1].selected = mx > 650 and mx < 650 + (500/4) and my > 30 and my < 30 + 40
        tabs[2].selected = mx > 650 + (500/4) and mx < 650 + (500/4)*2 and my > 30 and my < 30 + 40
        tabs[3].selected = mx > 650 + (500/4)*2 and mx < 650 + (500/4)*3 and my > 30 and my < 30 + 40
        tabs[4].selected = mx > 650 + (500/4)*3 and mx < 650 + (500/4)*4 and my > 30 and my < 30 + 40 ]]

        if mx > 650 and mx < 650 + (500/4) and my > 30 and my < 30 + 40 then
            tabs[1].selected = true
            tabs[2].selected = false
            tabs[3].selected = false
            tabs[4].selected = false
        elseif mx > 650 + (500/4) and mx < 650 + (500/4)*2 and my > 30 and my < 30 + 40 then
            tabs[1].selected = false
            tabs[2].selected = true
            tabs[3].selected = false
            tabs[4].selected = false
        elseif mx > 650 + (500/4)*2 and mx < 650 + (500/4)*3 and my > 30 and my < 30 + 40 then
            tabs[1].selected = false
            tabs[2].selected = false
            tabs[3].selected = true
            tabs[4].selected = false
        elseif mx > 650 + (500/4)*3 and mx < 650 + (500/4)*4 and my > 30 and my < 30 + 40 then
            tabs[1].selected = false
            tabs[2].selected = false
            tabs[3].selected = false
            tabs[4].selected = true
        end

        if tabs[1].selected then
            if mx > 675 and mx < 675 + 20 and my > 110 and my < 110 + 20 then
                _song.needsVoices = not _song.needsVoices
            end

            --love.graphics.rectangle("line", 725, 200, 20, 20)
            --love.graphics.rectangle("line", 745, 200, 20, 20)
            -- if the first one is pressed, change _song.curSpeed by +0.1
            -- else -0.1
            if mx > 725 and mx < 725 + 20 and my > 200 and my < 200 + 20 then
                _song.speed = _song.speed + 0.1
            elseif mx > 745 and mx < 745 + 20 and my > 200 and my < 200 + 20 then
                _song.speed = _song.speed - 0.1
            end

            if mx > 725 and mx < 725 + 20 and my > 150 and my < 150 + 20 then
                _song.bpm = _song.bpm + 1
            elseif mx > 745 and mx < 745 + 20 and my > 150 and my < 150 + 20 then
                _song.bpm = _song.bpm - 1
            end

            -- love.graphics.rectangle("line", 800, 80, 100, 20)
            -- save button!
            if mx > 800 and mx < 800 + 100 and my > 80 and my < 80 + 20 then
                local json2 = {
                    song = _song,
                    GeneratedBy = "Vanilla Engine"
                }
                local data = json.encode(json2)
    
                if data ~= nil and #data > 0 then
                    local filename = (_song.song .. ".json"):lower()
                    -- check if GeneratedSongs folder exists
                    if not love.filesystem.getInfo("GeneratedSongs") then
                        love.filesystem.createDirectory("GeneratedSongs")
                    end
                    love.filesystem.write("GeneratedSongs/"..filename, data)
                    -- open the folder
                    love.system.openURL("file://"..love.filesystem.getSaveDirectory().."/GeneratedSongs")
                end
            end
        elseif tabs[2].selected then
        elseif tabs[3].selected then
        elseif tabs[4].selected then
        end
    end,

    loadSong = function(self, song)
        if inst ~= nil then
            inst:stop()
        end
        if voices ~= nil then
            voices:stop()
        end
        local instPath = "songs/" .. _song.song:lower() .. "/Inst.ogg"
        inst = love.audio.newSource(instPath, "stream")

        local voicesPath = "songs/" .. _song.song:lower() .. "/Voices.ogg"
        -- check if file exists
        if love.filesystem.getInfo(voicesPath) then
            voices = love.audio.newSource(voicesPath, "stream")
        else
            voices = nil
        end
    end,

    addNote = function(self)
        local noteStrum = self:getStrumTime(dummyArrow.y) + self:sectionStartTime()
        local noteData = math.floor(love.mouse.getX()/GRID_SIZE)
        local noteSus = 0
        local noteAlt = false

        table.insert(_song.notes[curSection].sectionNotes, {noteStrum, noteData, noteSus, noteAlt})

        curSelectedNote = _song.notes[curSection].sectionNotes[#_song.notes[curSection].sectionNotes]

        self:updateGrid()

        --print("Added note at time, lane, sustain, alt: ", noteStrum, noteData, noteSus, noteAlt)
    end,

    deleteNote = function(self, note)
        for i, v in ipairs(_song.notes[curSection].sectionNotes) do
            if v[1] == note.strumTime and v[2] % 4 == note.noteData then
                table.remove(_song.notes[curSection].sectionNotes, i)
                break
            end
        end

        self:updateGrid()
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
                inst:stop()
                inst:seek(self:sectionStartTime()/1000)
                if voices then
                    voices:stop()
                    voices:seek(self:sectionStartTime()/1000)
                end
                musicTime = self:sectionStartTime()
            end

            self:updateGrid()

            strumLine.y = gridBG.y + gridBG.height

            self:updateSectionUI()
        else
            if sec < curSection then
                curSection = 1
                self:updateGrid()
            else
                self:addSection()
                self:changeSection(sec)
            end
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

            if daSus > 0 then
                local sustainVis = Sprite(note.x + (GRID_SIZE*1.90), note.y + (GRID_SIZE*1.45))
                sustainVis:makeGraphic(8, math.floor(remapToRange(daSus, 0, beatHandler.stepCrochet * 16, 0, gridBG.height)))
                curRenderedSustains:add(sustainVis)
            end
        end
    end,

    changeNoteSustain = function(self, v)
        if curSelectedNote ~= nil then
            if curSelectedNote[3] ~= nil then
                curSelectedNote[3] = curSelectedNote[3] + v
                curSelectedNote[3] = math.max(curSelectedNote[3], 0)
            end
        end

        self:updateNoteUI()
        self:updateGrid()
    end,

    updateNoteUI = function()
    end,

    keypressed = function(self, key)
        if key == "space" then
            if inst then
                if inst:isPlaying() then
                    inst:pause()
                else
                    inst:play()
                end
            end
            if voices then
                if voices:isPlaying() then
                    voices:pause()
                else
                    voices:play()
                end
            end
        elseif key == "e" then
            self:changeNoteSustain(beatHandler.stepCrochet)
        elseif key == "q" then
            self:changeNoteSustain(-beatHandler.stepCrochet)
        elseif key == "right" then
            self:changeSection(curSection + 1)
        elseif key == "left" then
            self:changeSection(curSection - 1)
        end
    end,

    draw = function()
        love.graphics.push()
        mainDrawGroup:draw()
        love.graphics.pop()

        -- draw tabs "Note", "Section", "Song", "Charting"
        -- if its selected
        -- draw a slightly rounded rectangle on the right
        -- draw the text in the middle
        
        if not tabs[1].selected then
            love.graphics.setColor(0.4, 0.4, 0.4, 1)
        else
            love.graphics.setColor(0.5, 0.5, 0.5, 1)
        end
        love.graphics.rectangle("fill", 650, 30, 500/4, 40, 10, 10)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("Song", 650 + (500/4)/2 - (font:getWidth("Song")/2), 30 + (40/2) - (font:getHeight("Song")/2))

        if not tabs[2].selected then
            love.graphics.setColor(0.4, 0.4, 0.4, 1)
        else
            love.graphics.setColor(0.5, 0.5, 0.5, 1)
        end
        love.graphics.rectangle("fill", 650 + (500/4), 30, 500/4, 40, 10, 10)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("Section", 650 + (500/4) + (500/4)/2 - (font:getWidth("Section")/2), 30 + (40/2) - (font:getHeight("Section")/2))

        if not tabs[3].selected then
            love.graphics.setColor(0.4, 0.4, 0.4, 1)
        else
            love.graphics.setColor(0.5, 0.5, 0.5, 1)
        end
        love.graphics.rectangle("fill", 650 + (500/4)*2, 30, 500/4, 40, 10, 10)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("Note", 650 + (500/4)*2 + (500/4)/2 - (font:getWidth("Note")/2), 30 + (40/2) - (font:getHeight("Note")/2))

        if not tabs[4].selected then
            love.graphics.setColor(0.4, 0.4, 0.4, 1)
        else
            love.graphics.setColor(0.5, 0.5, 0.5, 1)
        end
        love.graphics.rectangle("fill", 650 + (500/4)*3, 30, 500/4, 40, 10, 10)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("Charting", 650 + (500/4)*3 + (500/4)/2 - (font:getWidth("Charting")/2), 30 + (40/2) - (font:getHeight("Charting")/2))

        love.graphics.setColor(0.5, 0.5, 0.5, 1)
        love.graphics.rectangle("fill", 650, 70, 500, 540, 10, 10)

        if tabs[1].selected then
            -- song
            --song text box
            love.graphics.setColor(1,1,1)
            love.graphics.rectangle("fill", 675, 80, 100, 20)
            love.graphics.setColor(0,0,0)
            love.graphics.rectangle("line", 675, 80, 100, 20)
            love.graphics.setColor(0,0,0)
            love.graphics.print(curSong, 680, 85, 0, 0.5, 0.5)
            love.graphics.setColor(1,1,1)

            -- checkmark box
            love.graphics.rectangle("fill", 675, 110, 20, 20)
            -- if _song.needsVoices, then print a checkmark
            if _song.needsVoices then
                love.graphics.setColor(0,0,0)
                love.graphics.print("✓", 675, 110, 0, 1.45, 1)
                love.graphics.setColor(1,1,1)
            end
            love.graphics.print("Has voice track", 700, 120, 0, 0.5, 0.5)

            -- song BPM +/-
            love.graphics.rectangle("fill", 675, 150, 50, 20)
            love.graphics.setColor(0,0,0)
            love.graphics.rectangle("line", 675, 150, 50, 20)
            -- gray buttons
            love.graphics.setColor(0.65, 0.65, 0.65, 1)
            love.graphics.rectangle("fill", 725, 150, 20, 20)
            love.graphics.rectangle("fill", 745, 150, 20, 20)
            love.graphics.setColor(0,0,0)
            love.graphics.rectangle("line", 725, 150, 20, 20)
            love.graphics.rectangle("line", 745, 150, 20, 20)
            love.graphics.print("+", 728, 150, 0, 0.8, 0.8)
            love.graphics.print("-", 748, 150, 0, 0.8, 0.8)
            love.graphics.print(_song.bpm, 680, 155, 0, 0.5, 0.5)
            love.graphics.setColor(1,1,1)
            love.graphics.print("BPM: ", 675, 135, 0, 0.5, 0.5)

            -- +/- buttons
            love.graphics.rectangle("fill", 675, 200, 50, 20)
            love.graphics.setColor(0,0,0)
            love.graphics.rectangle("line", 675, 200, 50, 20)
            -- gray buttons
            love.graphics.setColor(0.65, 0.65, 0.65, 1)
            love.graphics.rectangle("fill", 725, 200, 20, 20)
            love.graphics.rectangle("fill", 745, 200, 20, 20)
            love.graphics.setColor(0,0,0)
            love.graphics.rectangle("line", 725, 200, 20, 20)
            love.graphics.rectangle("line", 745, 200, 20, 20)
            love.graphics.print("+", 728, 200, 0, 0.8, 0.8)
            love.graphics.print("-", 748, 200, 0, 0.8, 0.8)
            love.graphics.print(_song.speed, 680, 205, 0, 0.5, 0.5)
            love.graphics.setColor(1,1,1)
            love.graphics.print("Song Speed:", 675, 185, 0, 0.5, 0.5)

            -- save button
            -- slightly gray like the other buttons
            love.graphics.setColor(0.75, 0.75, 0.75, 1)
            love.graphics.rectangle("fill", 800, 80, 100, 20)
            love.graphics.setColor(0,0,0)
            love.graphics.rectangle("line", 800, 80, 100, 20)
            love.graphics.setColor(0.2, 0.2, 0.2, 1)
            -- save goes in the middle of the button
            love.graphics.print("Save", 805 + (100/2) - (font:getWidth("Save")/2), 82 + (20/2) - (font:getHeight("Save")/2), 0, 0.8, 0.8)
            love.graphics.setColor(1,1,1)

            -- reload audio button
            love.graphics.setColor(0.75, 0.75, 0.75, 1)
            love.graphics.rectangle("fill", 925, 80, 100, 20)
            love.graphics.setColor(0,0,0)
            love.graphics.rectangle("line", 925, 80, 100, 20)
            love.graphics.setColor(0.2, 0.2, 0.2, 1)
            -- text goes in the middle of the button
            love.graphics.print("Reload Audio", 963 + (100/2) - (font:getWidth("Reload Audio")/2), 85 + (20/2) - (font:getHeight("Reload Audio")/2), 0, 0.55, 0.55)
            love.graphics.setColor(1,1,1)

            -- reload JSON button (under reload audio)
            love.graphics.setColor(0.75, 0.75, 0.75, 1)
            love.graphics.rectangle("fill", 925, 110, 100, 20)
            love.graphics.setColor(0,0,0)
            love.graphics.rectangle("line", 925, 110, 100, 20)
            love.graphics.setColor(0.2, 0.2, 0.2, 1)
            -- text goes in the middle of the button
            love.graphics.print("Reload JSON", 960 + (100/2) - (font:getWidth("Reload JSON")/2), 115 + (20/2) - (font:getHeight("Reload JSON")/2), 0, 0.55, 0.55)
            love.graphics.setColor(1,1,1)

            
        elseif tabs[2].selected then
            -- section
        elseif tabs[3].selected then
            -- note
        end
    end,

    leave = function()
        mainDrawing = true
    end
}