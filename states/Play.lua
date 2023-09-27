local PlayState = MusicBeatState:extend()

PlayState.STRUM_X = 42
PlayState.STRUM_X_MIDDLESCROLL = -278

PlayState.ratingStuff = {
    {"You Suck!", 0.2},
    {"Shit", 0.4},
    {"Bad", 0.5},
    {"Bruh", 0.6},
    {"Meh", 0.69},
    {"Nice", 0.7},
    {"Good", 0.8},
    {"Great", 0.9},
    {"Sicl!", 1},
    {"Perfect!!", 1} -- ermmm,,, not used (why does psych do this? ig i gotta view the code lmao)
}

PlayState.isCameraOnForcedPos = false 

-- wtf are maps 💀
PlayState.boyfriendMap = {}
PlayState.dadMap = {}
PlayState.gfMap = {}
PlayState.variables = {}

PlayState.BF_X = 770
PlayState.BF_Y = 100
PlayState.DAD_X = 100
PlayState.DAD_Y = 100
PlayState.GF_X = 400
PlayState.GF_Y = 130

PlayState.songSpeed = 1
PlayState.songSpeedTween = nil -- Timer.tween
PlayState.songSpeedType = "multiplicative"
PlayState.noteKillOffset = 350
PlayState.playbackRate = 1

PlayState.boyfriendGroup = Group()
PlayState.dadGroup = Group()
PlayState.gfGroup = Group()
PlayState.curStage = ""
PlayState.stageUI = "normal"
PlayState.isPixelStage = false

PlayState.SONG = nil
PlayState.isStoryMode = false
PlayState.storyWeek = 0
PlayState.storyPlaylist = {}
PlayState.storyDifficulty = 1

PlayState.spawnTime = 2000

PlayState.vocals = nil
PlayState.inst = nil

PlayState.dad = nil
PlayState.gf = nil
PlayState.boyfriend = nil

PlayState.notes = Group()
PlayState.unspawnNotes = {}
PlayState.eventNotes = {}

PlayState.camFollow = {x=0,y=0}
PlayState.prevCamFollow = {x=0,y=0}

PlayState.strumLineNotes = Group()
PlayState.opponentStrums = Group()
PlayState.playerStrums = Group()
PlayState.grpNoteSplashes = Group()

PlayState.camZooming = false
PlayState.camZoomingMult = 1
PlayState.camZoomingDecay = 1
PlayState.curSong = ""

PlayState.gfSpeed = 1
PlayState.health = 1
PlayState.combo = 0

PlayState.healthBar = nil
PlayState.timeBar = nil
PlayState.songPercent = 0

PlayState.ratingsData = nil
PlayState.fullComboFunction = nil

PlayState.generatedMusic = false
PlayState.endingSong = false
PlayState.startingFalse = false
PlayState.updateTime = true
PlayState.changedDifficulty = false
PlayState.chartingMode = false

PlayState.healthGain = 1
PlayState.healthloss = 1
PlayState.instaKillOnMiss = false
PlayState.cpuControlled = false
PlayState.practiceMode = false

PlayState.botplaySine = 0
PlayState.botplayTxt = ""

PlayState.iconP1 = nil
PlayState.iconP2 = nil
PlayState.camHUD = {x=0,y=0,zoom=1,defaultZoom=1}
PlayState.camGame = {x=0,y=0,zoom=1,defaultZoom=1}
PlayState.camOther = {x=0,y=0,zoom=1,defaultZoom=1}
PlayState.camSpeed = 1

PlayState.songScore = 0
PlayState.songHites = 0
PlayState.songMisses = 0
PlayState.scoreTxt = ""
PlayState.timeTxt = ""
PlayState.scoreTxtTween = nil

PlayState.campaignScore = 0
PlayState.campaignMisses = 0
PlayState.seenCutscene = false
PlayState.deathCounter = 0

PlayState.defaultCamZoom = 1.05

PlayState.daPixelZoom =  6
PlayState.singAnimations = {"singLEFT", "songDOWN", "singUP", "singRIGHT"}
PlayState.inputs = {"g_left", "g_down", "g_up", "g_right"}

PlayState.inCutscene = false
PlayState.skipCountdown = false
PlayState.songLength = 0

PlayState.boyfriendCameraOffset = {x=0,y=0}
PlayState.dadCameraOffset = {x=0,y=0}
PlayState.girlfriendCameraOffset = {x=0,y=0}

PlayState.precacheList = {}
PlayState.songName = ""

PlayState.startCallback = nil
PlayState.endCallback = nil

PlayState.keysArray = nil

PlayState.members = {}

function PlayState:add(member)
    table.insert(self.members, member)
end

function PlayState:remove(member)
    for i, member in ipairs(self.members) do
        if member == member then
            table.remove(self.members, i)
            return
        end
    end
end

function PlayState:clear()
    self.members = {}
end

function PlayState:enter()
    self.super.enter(self)

    self.startCallback = startCountdown
    self.endCallback = endSong

    self.keysArray = {
        "g_left",
        "g_down",
        "g_up",
        "g_right"
    }

    self.camGame = {x=0,y=0,zoom=1,defaultZoom=1}
    self.camHUD = {x=0,y=0,zoom=1,defaultZoom=1}
    self.camOther = {x=0,y=0,zoom=1,defaultZoom=1}

    if not self.SONG then
        self.SONG = Song:loadFromJson("test")
    end
    Conductor.mapBPMChanges(self.SONG)
    Conductor.changeBPM(self.SONG.bpm)
    self.songName = Paths.formatToSongPath(self.SONG.song)

    self.defaultCamZoom = 1.05

    self.stageUI = "normal"

    self.BF_X = 770
    self.BF_Y = 100
    self.DAD_X = 100
    self.DAD_Y = 100
    self.GF_X = 400
    self.GF_Y = 130

    Conductor.songPosition = -5000 / Conductor.songPosition

    strumLineNotes = Group()
    self:add(strumLineNotes)

    self.opponentStrums = Group()
    self.playerStrums = Group()

    self.notes = Group()
    self.sustainsNotes = Group()
    self:add(self.sustainsNotes)
    self:add(self.notes)

    Conductor.songPosition = 0

    self:generateSong(self.SONG.song)
end

function PlayState:update(dt)
    self.super.update(self, dt)
    Conductor.songPosition = Conductor.songPosition + 1000 * dt
    for i, member in ipairs(self.members) do
        if member.update then member:update(dt) end
    end

    if self.unspawnNotes[1] ~= nil then
        local time = self.spawnTime
        if self.songSpeed < 1 then time = time / self.songSpeed end
        if self.unspawnNotes[1].multSpeed < 1 then time = time / self.unspawnNotes[1].multSpeed end

        while (#self.unspawnNotes > 0 and self.unspawnNotes[1].strumTime - Conductor.songPosition < time) do
            local note = table.remove(self.unspawnNotes, 1)
            --self.notes:add(note)
            if not note.isSustainNote then
                self.notes:add(note)
            else
                self.sustainsNotes:add(note)
            end
            note.spawned = true
            --print(#self.notes.members)
        end
    end

    if #self.notes.members > 0 then
        if self.startedCountdown then
            local fakeCrochet = (60 / self.SONG.bpm) * 1000
            for i, note in ipairs(self.notes.members) do
                local strumGroup = self.playerStrums
                if not note.mustPress then strumGroup = self.opponentStrums end
                --print(#strumGroup.members, note.noteData)
                local strum = strumGroup.members[note.noteData+1]
                note:followStrumNote(strum, fakeCrochet, self.songSpeed)

                if note.mustPress then
                    if self.cpuControlled and not note.blockHit and note.canBeHit and (note.isSustainNote or note.strumTime <= Conductor.songPosition) then
                        self:goodNoteHit(note)
                    end
                elseif note.wasGoodHit and not note.hitByOpponent and not note.ignoreNote then
                    self:opponentNoteHit(note)
                end

                if note.isSustainNote and strum.sustainReduce then 
                    note:clipToStrumNote(strum) 
                end

                if Conductor.songPosition - note.strumTime > self.noteKillOffset then
                    if note.mustPress and not self.cpuControlled and not note.ignoreNote and not self.endingSong and (note.tooLate or not note.wasGoodHit) then
                        --self:noteMiss(note)
                    end

                    note.active = false
                    note.visible = false

                    self.notes:remove(note)
                end
            end
        end
    end

    if #self.sustainsNotes.members > 0 then
        if self.startedCountdown then
            local fakeCrochet = (60 / self.SONG.bpm) * 1000
            for i, note in ipairs(self.sustainsNotes.members) do
                local strumGroup = self.playerStrums
                if not note.mustPress then strumGroup = self.opponentStrums end
                --print(#strumGroup.members, note.noteData)
                local strum = strumGroup.members[note.noteData+1]
                note:followStrumNote(strum, fakeCrochet, self.songSpeed)

                if note.mustPress then
                    if self.cpuControlled and not note.blockHit and note.canBeHit and (note.isSustainNote or note.strumTime <= Conductor.songPosition) then
                        self:goodNoteHit(note)
                    end
                elseif note.wasGoodHit and not note.hitByOpponent and not note.ignoreNote then
                    self:opponentNoteHit(note)
                end

                if note.isSustainNote and strum.sustainReduce then 
                    note:clipToStrumNote(strum) 
                end

                if Conductor.songPosition - note.strumTime > self.noteKillOffset then
                    if note.mustPress and not self.cpuControlled and not note.ignoreNote and not self.endingSong and (note.tooLate or not note.wasGoodHit) then
                        --self:noteMiss(note)
                    end

                    note.active = false
                    note.visible = false

                    self.notes:remove(note)
                end
            end
        end
    end
end

function PlayState:draw(dt)
    for i, member in ipairs(self.members) do
        member:draw(dt)
    end
end

function PlayState:opponentNoteHit(note)
    if Paths.formatToSongPath(self.SONG.song) ~= "tutorial" then
        self.camZooming = true
    end

    if note.noteType == "Hey!" and self.dad.animations["hey"] then
        self.dad:playAnim("hey", true)
        self.dad.specialAnim = true
        self.dad.heyTimer = 0.6
    elseif not note.noAnimation then
        local altAnim = note.animSuffix

        if self.SONG.notes[self.curSection] then
            if self.SONG.notes[self.curSection].altAnim and not self.SONG.notes[self.curSection].gfSection then
                altAnim = "-alt"
            end
        end

        local char = self.dad
        local animToPlay = self.singAnimations[math.floor(math.abs(math.min(#self.singAnimations, note.noteData+1)))] .. altAnim
        if note.gfNote then
            char = self.gf
        end
        
        if char then
            char:playAnim(animToPlay, true)
            char.holdTimer = 0
        end
    end

    if self.SONG.needsVoices then
        self.vocals:setVolume(1)
    end

    self:strumPlayAnim(true, math.floor(math.abs(note.noteData+1)), Conductor.stepCrochet * 1.25 / 1000 / self.playbackRate)
    note.hitByOpponent = true

    if not note.isSustainNote then
        self.notes:remove(note)
    end
end

function PlayState:strumPlayAnim(isDad, id, time)
    local spr = nil
    if isDad then
        spr = self.opponentStrums.members[id]
    else
        spr = self.playerStrums.members[id]
    end

    if spr then
        spr:playAnim("confirm", true)
        spr.resetAnim = time
    end
end

function PlayState:generateSong(dataPath)
    self.songSpeed = self.SONG.speed
    
    local songData = self.SONG
    Conductor.changeBPM(songData.bpm)

    self.curSong = songData.song

    self.vocals = songData.needsVoices and love.audio.newSource("assets/songs/" .. dataPath .. "/" .. "Voices.ogg", "stream") or nil
    self.inst = love.audio.newSource("assets/songs/" .. dataPath .. "/" .. "Inst.ogg", "stream")

    notes = Group()
    self:add(notes)

    local noteData = {}

    noteData = songData.notes

    local file = "assets/data/" .. dataPath .. "/events"
    if love.filesystem.getInfo(file) then
        local eventsData = Song:loadFromJson("events", songName).events
        for i, event in ipairs(eventsData) do
            for i = 1, #event[1] do
                --self:makeEvent(event, i)
            end
        end
    end

    for i, section in ipairs(noteData) do
        for i2, songNotes in ipairs(section.sectionNotes) do
            local daStrumTime = songNotes[1]
            local daNoteData = math.floor(songNotes[2] % 4)
            local gottaHitNote = section.mustHitSection

            if songNotes[2] > 4 then
                gottaHitNote = not gottaHitNote
            end

            local oldNote = nil
            if #self.unspawnNotes > 0 then
                oldNote = self.unspawnNotes[1]
            end

            local swagNote = Note(daStrumTime, daNoteData, oldNote)
            swagNote.mustPress = gottaHitNote
            swagNote.sustainlength = songNotes[3]
            swagNote.gfNote = (section.gfSection and (songNotes[2]<4))
            swagNote.noteType = songNotes[4]

            local susLength = swagNote.sustainlength / Conductor.stepCrochet

            table.insert(self.unspawnNotes, swagNote)

            -- holdnote shits
            local floorSus = math.floor(susLength)
            if floorSus > 0 then
                for susNote = 0, floorSus+1 do
                    local oldNote = self.unspawnNotes[#self.unspawnNotes]
                    --print(daStrumTime + (Conductor.stepCrochet * susNote))

                    local sustainNote = Note(daStrumTime + (Conductor.stepCrochet * susNote), daNoteData, oldNote, true)
                    sustainNote.mustPress = gottaHitNote
                    sustainNote.gfNote = (section.gfSection and (songNotes[2]<4))
                    sustainNote.noteType = swagNote.noteType
                    table.insert(swagNote.tail, sustainNote)
                    table.insert(self.unspawnNotes, sustainNote) 
                    sustainNote.correctionOffset = swagNote.height / 2
                    if not PlayState.isPixelStage then
                        if oldNote.isSustainNote then
                            oldNote:updateHitbox()
                        end

                        -- downscroll correctionoffset = 0
                    elseif oldNote.isSustainNote then
                        oldNote:updateHitbox()
                    end

                    if sustainNote.mustPress then
                        sustainNote.x = sustainNote.x + push.getWidth() / 2
                    -- middle scroll
                    end
                end
            end

            if swagNote.mustPress then
                swagNote.x = swagNote.x + push.getWidth() / 2
            end
        end
    end

    -- sort unspawnNotes by strumTime
    table.sort(self.unspawnNotes, function(a, b) return a.strumTime < b.strumTime end)

    self:startCountdown()
end

function PlayState:startCountdown()
    self.seenCutscene = true
    self.inCutscene = false

    if skipCountdown then
        self.skipArrowTween = true
    end

    self:generateStaticArrows(0)
    self:generateStaticArrows(1)

    self.startedCountdown = true

    --Conductor.songPosition = -Conductor.crochet * 5

    local swagCounter = 0

    -- play inst, and voices if it exists
    if self.vocals then
        self.vocals:play()
    end
    self.inst:play()

    return true
end

function PlayState:StartAndEnd()
    if self.endingSong then
        if self.endSong then self:endSong() end
    else
        if self.startCountdown then self:startCountdown() end
    end
end

function PlayState:generateStaticArrows(player)
    local strumLineX = self.STRUM_X
    strumLineY = 50

    for i = 1, 4 do
        local targetAlpha = 1
        if player < 1 then
            --
        end

        local babyArrow = StrumNote(strumLineX, strumLineY, i-1, player)
        babyArrow.downscroll = false

        if player == 1 then
            self.playerStrums:add(babyArrow)
        else
            self.opponentStrums:add(babyArrow)
        end

        strumLineNotes:add(babyArrow)
        babyArrow:postAddedToGroup()
    end
end

return PlayState