local PlayState = MusicBeatState:extend("PlayState")
PlayState.instance = nil

function PlayState:new(params)
    self.instance = self
    self.currentSong = nil
    self.currentDifficulty = Constants.DEFAULT_DIFFICULTY
    self.currentVariation = Constants.DEFAULT_VARIATION
    self.currentInstrumental = ""
    self.currentStage = nil
    self.needsReset = false
    self.deathCounter = 0
    self.health = Constants.HEALTH_STARTING
    self.songScore = 0
    self.startTimestamp = 0
    self.playbackRate = 1
    self.cameraFollowPoint = Object()
    self.cameraZoomTween = nil
    self.scrollSpeedTweens = {}
    self.previousCameraFollowPoint = nil
    self.currentCameraZoom = Camera.defaultZoom
    self.cameraBopMultiplier = 1

    self.defaultHUDCameraZoom = Camera.defaultZoom * 1.0
    self.cameraBopIntensity = Constants.DEFAULT_BOP_INTENSITY
    self.hudCameraZoomIntensity = 0.015 * 2
    self.cameraZoomRate = Constants.DEFAULT_ZOOM_RATE
    self.isInCountdown = false
    self.isPracticeMode = false
    self.isBotPlayMode = false
    self.isPlayerDying = false
    self.isMinimalMode = false
    self.isInCutscene = false
    self.disableKeys = false

    self.inputPressQueue = {}
    self.inputReleaseQueue = {}

    self.justUnpaused = false

    self.songEvents = {}
    self.mayPauseGame = true

    self.healthLerp = Constants.HEALTH_STARTING

    self.skipHeldTimer = 0
    self.overrideMusic = false
    self.criticalFailure = false

    self.startingSong = false
    self.musicPausedBySubState = false

    self.cameraTweensPausedBySubState = {}
    self.initialized = false

    self.vocals = VoicesGroup()

    self.isGamePaused = false
    self.isExitingViaPauseMenu = false

    self.generatedMusic = false
    self.perfectMode = false

    self.BACKGROUND_COLOR = {0, 0, 0, 1}

    self.currentSong = params.targetSong

    if params.targetDifficulty then
        self.currentDifficulty = params.targetDifficulty
    end
    if params.targetVariation then
        self.currentVariation = params.targetVariation
    end
    if not self.currentVariation then 
        self.currentVariation = Constants.DEFAULT_VARIATION
    end
    if params.targetInstrumental then
        self.currentInstrumental = params.targetInstrumental
    end
    self.isPracticeMode = params.isPracticeMode or false
    self.isBotPlayMode = params.isBotPlayMode or false
    self.isMinimalMode = params.isMinimalMode or false
    self.startTimestamp = params.startTimestamp or 0
    self.playbackRate = params.playbackRate or 1
    self.overrideMusic = params.overrideMusic or false
    self.previousCameraFollowPoint = params.cameraFollowPoint or Object(0, 0)

    self.curChart = nil

    MusicBeatState.new(self)
end

function PlayState:create()
    PlayState.instance = self

    self.cameraFollowPoint = Object(0, 0)

    self.persistentUpdate = true
    self.persistentDraw = true

    if not self.overrideMusic and Game.sound.music then
        Game.sound.music:stop()
    end

    local chart = self:get_currentChart()
    if not self.overrideMusic and chart then
        chart:cacheInst()
        chart:cacheVocals()
    end

    Conductor:forceBPM(nil)

    if chart.offsets ~= nil then
        Conductor.instrumentalOffset = chart.offsets--[[ :getInstrumentalOffset() ]]
    end

    Conductor:mapTimeChanges(chart)
    Conductor:update((Conductor.get_beatLengthMs() * -5) + self.startTimestamp)

    self:initCameras()
    self:initHealthbar()

    self:initStage()
    self:initCharacters()

    self:initStrumlines()

    self:initPreciseInputs()

    self:generateSong()

    self:resetCamera()

    self.startingSong = true
    self.isInCountdown = true

    if ((self.currentSong and self.currentSong.id or ""):lower() == "winter-horrorland") then

    else
        self:startCountdown()
    end

    MusicBeatState.create(self)

    self.initialized = true

    self:refresh()
end

function PlayState:get_stageZoom()
    if self.currentStage then
        return self.currentStage:get_camZoom()
    else
        return Camera.defaultZoom * 1.05
    end
end

function PlayState:get_currentChart()
    if not self.currentSong or not self.currentDifficulty then
        print("NO SONG OR DIFFICULTY SELECTED")
        return {}
    end

    --[[ local curChart = self.currentSong:getDifficulty(self.currentDifficulty, self.currentVariation) ]]
    if not self.curChart then
        self.curChart = self.currentSong:getDifficulty(self.currentDifficulty, self.currentVariation, nil, true)
    end
    return self.curChart
end

function PlayState:get_currentStageId()
    local curChart = self:get_currentChart()
    if not self.currentSong or not curChart.stage or curChart.stage == "" then
        print("NO STAGE SELECTED")
        return Constants.DEFAULT_STAGE
    end

    return curChart.stage
end

function PlayState:get_currentSongLengthMs()
    if Game.sound.music then
        return Game.sound.music.length
    end
end

function PlayState:initCameras()
    self.camGame = FunkinCamera("playStateCamGame")
    self.camHUD = Camera()
    self.camCutscene = Camera()

    Game.cameras:reset()
    Game.cameras:add(self.camHUD)
    Game.cameras:add(self.camCutscene)

    if self.previousCameraFollowPoint ~= nil then
        self.cameraFollowPoint:setPosition(self.previousCameraFollowPoint.x, self.previousCameraFollowPoint.y)
        self.previousCameraFollowPoint = nil
    end
    -- self:add(self.cameraFollowPoint)
end

function PlayState:initHealthbar()

end

function PlayState:initStage()
    self:loadStage(self:get_currentStageId())
end

function PlayState:initCharacters()
    if self.currentStage ~= nil then
        if dad ~= nil then
            --self.currentStage:addCharacter(dad, "DAD")
            self.cameraFollowPoint:setPosition(dad.cameraFocusPoint.x, dad.cameraFocusPoint.y)
        end
    end
end

function PlayState:initStrumlines()
    local currentChart = self:get_currentChart()
    local noteStyleID = currentChart.noteStyle or "default"
    local noteStyle = noteStyleID
    noteStyle = NoteStyle(noteStyleID)

    self.playerStrumline = Strumline(noteStyle, not self.isBotPlayMode)
    self.playerStrumline.onNoteIncoming:add(self.onStrumlineNoteIncoming)
    self.opponentStrumline = Strumline(noteStyle, self.isBotPlayMode)
    self.opponentStrumline.onNoteIncoming:add(self.onStrumlineNoteIncoming)

    self:add(self.playerStrumline)
    self:add(self.opponentStrumline)

    self.playerStrumline:setPosition(Game.width / 2 + Constants.STRUMLINE_X_OFFSET, Constants.STRUMLINE_Y_OFFSET)
    self.playerStrumline.zIndex = 1001
    self.playerStrumline.cameras = {self.camHUD}

    self.opponentStrumline:setPosition(Constants.STRUMLINE_X_OFFSET, Constants.STRUMLINE_Y_OFFSET)
    self.opponentStrumline.zIndex = 1000
    self.opponentStrumline.cameras = {self.camHUD}
end

function PlayState:initPreciseInputs()

end

function PlayState:loadStage(id)
    self.currentStage = Stage(StageRegistry:fetchEntry(id))
    self.currentStage:onCreate()

    if self.currentStage ~= nil then
        self:resetCameraZoom()

        local event = ScriptEvent("CREATE", false)
        ScriptEventDispatcher.callEvent(self.currentStage, event)

        self:add(self.currentStage)
    else
        print("Failed to load stage " .. id)
    end
end

function PlayState:resetCameraZoom()
    self.currentCameraZoom = self:get_stageZoom()
    --Game._cameras[1].zoom = self.currentCameraZoom

    self.cameraBopMultiplier = 1
end

function PlayState:resetCamera(resetZoom, cancelTweens, snap)
    local resetZoom = resetZoom == nil and true or resetZoom
    local cancelTweens = cancelTweens == nil and true or cancelTweens
    local snap = snap == nil and true or snap

    if cancelTweens then
        --
    end

    Game.camera.follow(self.cameraFollowPoint, 1, 1, 0, 0)
    Game.camera.targetOffset:set()

    if resetZoom then
        self:resetCameraZoom()
    end

    if snap then Game.camera:focusOn(self.cameraFollowPoint) end
end

function PlayState:tweenCameraToPosition(x, y, duration, ease)
    self.cameraFollowPoint:setPosition(x, y)
    self:tweenCameraToFollowPoint(duration, ease)
end

--[[
 public function tweenCameraToFollowPoint(?duration:Float, ?ease:Null<Float->Float>):Void
  {
    // Cancel the current tween if it's active.
    cancelCameraFollowTween();

    if (duration == 0)
    {
      // Instant movement. Just reset the camera to force it to the follow point.
      resetCamera(false, false);
    }
    else
    {
      // Disable camera following for the duration of the tween.
      FlxG.camera.target = null;

      // Follow tween! Caching it so we can cancel/pause it later if needed.
      var followPos:FlxPoint = cameraFollowPoint.getPosition() - FlxPoint.weak(FlxG.camera.width * 0.5, FlxG.camera.height * 0.5);
      cameraFollowTween = FlxTween.tween(FlxG.camera.scroll, {x: followPos.x, y: followPos.y}, duration,
        {
          ease: ease,
          onComplete: function(_) {
            resetCamera(false, false); // Re-enable camera following when the tween is complete.
          }
        });
    }
  }]]
  
function PlayState:tweenCameraToFollowPoint(duration, ease)
    self:cancelCameraFollowTween()

    if duration == 0 then
        self:resetCamera(false, false)
    else
        Game.camera.target = nil

        local followPos = self.cameraFollowPoint:getPosition() - Point(Game.width * 0.5, Game.height * 0.5)
        -- self.cameraFollowTween = 
    end
end

function PlayState:startCountdown()
    self.isInCutscene = false
    self.camHUD.visible = true
end

function PlayState:update(dt)
    local pressArray = {
        "NOTE_LEFT", "NOTE_DOWN", "NOTE_UP", "NOTE_RIGHT"
    }
    local releaseArray = {
        "NOTE_LEFT", "NOTE_DOWN", "NOTE_UP", "NOTE_RIGHT"
    }
    for i = 1, #pressArray do
        local fn = Controls[pressArray[i] .. "_P"]
        if fn and fn(Controls) then
            table.insert(self.inputPressQueue, i - 1)
        end
    end
    for i = 1, #releaseArray do
        if Controls[releaseArray[i] .. "_R"](Controls) then
            table.insert(self.inputReleaseQueue, i - 1)
        end
    end
    MusicBeatState.update(self, dt)

    local list = Game.sound.list
    --self:updateHealthbar()
    --self:updateScoreText()

    if self.needsReset then
        self.prevScrollTargets = {}
        self.previousDifficulty = self.currentDifficulty
        self:resetCamera()

        local fromDeathState = self.isPlayerDying
        self.persistentUpdate = true
        self.persistentDraw = true
        
        self.startingSong = true
        self.isPlayerDying = false

        if Game.sound.music ~= nil then
            Game.sound.music.time = self.startTimestamp - (Conductor.combinedOffset or 0)
            Game.sound.music.pitch = self.playbackRate
            Game.sound.music:pause()
        end

        if not self.overrideMusic then
            if self.vocals ~= nil then
                self.vocals:stop()
            end

            self.vocals = self:get_currentChart():buildVocals()

            if #self.vocals.members == 0 then
                print("WARN: No vocals found for song")
            end
        end

        vocals:pause()
        vocals.time = 0 - (Conductor.combinedOffset or 0)
        vocals.volume = 1
        vocals.playerVolume = 1
        vocals.opponentVolume = 1

        if self.currentStage then
            self.currentStage:resetStage()
        end

        if not self.fromDeathState then
            self.playerStrumline:vwooshNotes()
            self.opponentStrumline:vwooshNotes()
        end

        self.playerStrumline:clean()
        self.opponentStrumline:clean()

        self:regenNoteData()

        Conductor:update(-5000, false)

        self.cameraBopIntensity = Constants.DEFAULT_BOP_INTENSITY
        self.hudCameraZoomIntensity = (self.cameraBopIntensity - 1) * 2
        self.cameraZoomRate = Constants.DEFAULT_ZOOM_RATE

        self.health = Constants.HEALTH_STARTING
        self.songScore = 0

        -- vwoosh stuff

        --

        if self.currentStage then
            if self.currentStage:getBoyfriend() then
                self.currentStage:getBoyfriend():initHealthIcon(false)
            end
            if self.currentStage:getDad() then
                self.currentStage:getDad():initHealthIcon(false)
            end
        end

        self.needsReset = false
    end

    if self.startingSong then
        if self.isInCountdown then
            Conductor:update(Conductor.songPosition + dt * 1000, false)
            if Conductor.songPosition >= self.startTimestamp then
                self:startSong()
            end
        end
    else
        Conductor:update(Conductor.songPosition + dt * 1000, false)

        --[[
        if Conductor.songPosition >= (Game.sound.music.endTime or Game.sound.music.length) then
            if self.mayPauseGame then self:endSong() end
        end
        ]]
    end

    -- pause

    --

    if self.health > Constants.HEALTH_MAX then self.health = Constants.HEALTH_MAX end
    if self.health < Constants.HEALTH_MIN then self.health = Constants.HEALTH_MIN end

    if self.subState == nil and self.cameraZoomRate > 0 then
        local originalFrameLerpFactor = 0.15
        local targetFPS = 60
        local lerpSpeed = -math.log(1 - originalFrameLerpFactor) * targetFPS
        local fact = 1 - math.exp(-lerpSpeed * dt)
        self.cameraBopMultiplier = math.lerp(self.cameraBopMultiplier, 1, fact)
        local zoomPlusBop = self.currentCameraZoom * self.cameraBopMultiplier
        Game.camera.zoom = zoomPlusBop
        self.camHUD.zoom = math.lerp(self.camHUD.zoom, self.defaultHUDCameraZoom, fact)
    end

    if self.currentStage~= nil and self.currentStage:getBoyfriend() ~= nil then
    end

    if self.health <= Constants.HEALTH_MIN and not self.isPracticeMode and not self.isPlayerDying then
    end

    if (not self.isInCutscene and not self.disableKeys) then
        if Controls:RESET() then
            print("FUCK!")
        end
    end

    self:processSongEvents()

    self:processInputQueue()

    if not self.isInCutscene then
        self:processNotes(dt)
    end

    self.justUnpaused = false

    --[[ if Game.sound.music then
        if Game.sound.music.source then
            print(Game.sound.music.source:tell())
        end
    end ]]
end

function PlayState:stepHit()
    if not self.initialized then
        return false
    end

    if not MusicBeatState.stepHit(self) then
        return false
    end

    if self.isGamePaused then
        return false
    end

    if self.iconP1 ~= nil then self.iconP1:onStepHit(math.floor(Conductor.currentStep)) end
    if self.iconP2 ~= nil then self.iconP2:onStepHit(math.floor(Conductor.currentStep)) end

    return true
end

function PlayState:beatHit()
    if not self.initialized then
        return false
    end

    if not MusicBeatState.beatHit(self) then
        return false
    end

    if self.isGamePaused then
        return false
    end

    if self.generatedMusic then
    end

    if Game.sound.music ~= nil then
        local correctSync = math.min(Game.sound.music.source:getDuration() * 1000, math.max(0, Conductor.songPosition - (Conductor.combinedOffset or 0)))
        local playerVoicesError = 0
        local opponentVoicesError = 0

        if self.vocals ~= nil and self.vocals.playing then
            self.vocals.playerVoices:forEachAlive(function(voice)
                local currentRawVoiceTime = voice.source:tell() * 1000 + self.vocals.playerVoicesOffset
                if math.abs(currentRawVoiceTime - correctSync) > math.abs(playerVoicesError) then
                    playerVoicesError = currentRawVoiceTime - correctSync
                end
            end)

            self.vocals.opponentVoices:forEachAlive(function(voice)
                local currentRawVoiceTime = voice.source:tell() * 1000 + self.vocals.opponentVoicesOffset
                if math.abs(currentRawVoiceTime - correctSync) > math.abs(opponentVoicesError) then
                    opponentVoicesError = currentRawVoiceTime - correctSync
                end
            end)

            if not self.startingSong and (math.abs(Game.sound.music.source:tell() * 1000 - correctSync) > 100 or
                math.abs(playerVoicesError) > 100 or
                math.abs(opponentVoicesError) > 100) then
                print("VOCALS NEED RESYNC!")
                if vocals ~= nil then
                    self:resyncVocals()
                end
            end
        end
    end

    if Game.camera.zoom < (1.35 * Camera.defaultZoom) and self.cameraZoomRate > 0 and Conductor.currentBeat % self.cameraZoomRate == 0 then
        self.cameraBopMultiplier = self.cameraBopIntensity
        self.camHUD.zoom = self.camHUD.zoom + self.hudCameraZoomIntensity * self.defaultHUDCameraZoom
    end
end

function PlayState:startSong()
    self.startingSong = false

    local chart = self:get_currentChart()
    if not self.overrideMusic and not self.isGamePaused and chart ~= nil then
        print("Starting song " .. self.currentSong.id .. " on difficulty " .. self.currentDifficulty)
        chart:playInst(1.0, self.currentInstrumental, false)
        Conductor.songPosition = 0
    end

    if Game.sound.music == nil then
        print("Failed to start song")
        return
    end

    print("Starting song " .. self.currentSong.id .. " on difficulty " .. self.currentDifficulty)

    Game.sound.music.onComplete = function()
        print("Song ended")
    end

    Game.sound.music:play(true, (self.startTimestamp) / 1000)
    Game.sound.music.pitch = self.playbackRate

    Game.sound.music.volume = 1
    if Game.sound.music.fadeTween then Game.sound.music.fadeTween:cancel() end

    self:add(self.vocals)
    self.vocals:play()
    self.vocals.volume = 1
    self.vocals.pitch = self.playbackRate

    self:resyncVocals()
end

function PlayState:resyncVocals()
    if self.vocals ~= nil then return end

    if not Game.sound.music.playing then return end

    local timeToPlayAt = math.min(Game.sound.music.source:getDuration() * 1000, math.max(0, Conductor.songPosition - (Conductor.combinedOffset or 0)))
    Game.sound.music:pause()
    self.vocals:pause()

    Game.sound.music.source:setPosition(timeToPlayAt / 1000)
    Game.sound.music:playAtTime(false, timeToPlayAt)

    self.vocals:play(false, timeToPlayAt)
end

function PlayState:generateSong()
    if self.currentCameraZoom == nil then
        print("Song difficulty not loaded")
    end

    if not self.overrideMusic then
        if self.vocals ~= nil then
            self.vocals:stop()
        end

        self.vocals = self:get_currentChart():buildVocals()
        if #self.vocals.members == 0 then
            print("WARN: No vocals found for song")
        end
    end

    self:regenNoteData()

    self.generatedMusic = true
end

function PlayState:dispatchEvent(event)
    MusicBeatState.dispatchEvent(self, event)

    ScriptEventDispatcher:callEvent(self.currentStage, event)
    if self.currentStage then
        self.currentStage:dispatchToCharacters(event)
        self.currentStage:dispatchToBoppers(event)
    end
end

function PlayState:regenNoteData(startTime)
    startTime = startTime or 0

    local currentChart = self:get_currentChart()
    if #currentChart.notes == 0 then
        printf("FALLING BACK TO BOPEEBO [%s] CHART", self.currentDifficulty)
        currentChart.notes = Json.decode(love.filesystem.read(Paths.json("songs/bopeebo/bopeebo-chart"))).notes[self.currentDifficulty]
    end
    local event = SongLoadScriptEvent(currentChart.song.id, currentChart.difficulty, table.copy(currentChart.notes)--[[ , table.copy(currentChart:getEvents() ]])

    self:dispatchEvent(event)

    local builtNoteData = event.notes
    local builtEventData = event.events

    print("Regenerating note data", #builtNoteData)

    self.songEvents = builtEventData
    --SongEventRegistry:resetEvents(self.songEvents)

    local playerNoteData = {}
    local opponentNoteData = {}

    for i, songNote in ipairs(builtNoteData) do
        local strumTime = songNote.t
        if strumTime < startTime then goto continue end

        local noteData = songNote.d % 4

        -- theres 4 lanes, 0-3 player, 4-7 opponent
        local strumIndex = songNote.d >= 4 and 1 or 0
        if strumIndex == 0 then
            table.insert(playerNoteData, songNote)
        elseif strumIndex == 1 then
            table.insert(opponentNoteData, songNote)
        end
        ::continue::
    end

    self.playerStrumline:applyNoteData(playerNoteData)
    self.opponentStrumline:applyNoteData(opponentNoteData)
end

function PlayState:processSongEvents()
    if self.songEvents ~= nil and #self.songEvents > 0 then
        --local songEventsToActivate = SongEventRegistry.queryEvents(self.songEvents, Conductor.songPosition)


    end
end

function PlayState:processInputQueue()
    if #self.inputPressQueue + #self.inputReleaseQueue == 0 then
        return
    end

    if self.isInCutscene or self.disableKeys then
        self.inputPressQueue = {}
        self.inputReleaseQueue = {}
        return
    end

    local notesInRange = self.playerStrumline:getNotesMayHit()

    local notesByDirection = {{}, {}, {}, {}}

    for i, note in ipairs(notesInRange) do
        table.insert(notesByDirection[note.direction+1], note)
    end

    while #self.inputPressQueue > 0 do
        local input = table.shift(self.inputPressQueue)

        self.playerStrumline:pressKey(input)

        if self.isBotPlayMode then
            goto continue
        end

        local notesInDirection = notesByDirection[input+1]

        if #notesInDirection == 0 then
            self:ghostNoteMiss(input, #notesInRange > 0)

            self.playerStrumline:playPress(input)
        else
            local targetNote = nil
            for i, note in ipairs(notesInDirection) do
                if not note.lowPriority then
                    targetNote = note
                    break
                end
            end

            self:goodNoteHit(targetNote, input)
            table.remove(notesInDirection, table.indexOf(notesInDirection, targetNote))
            self.playerStrumline:playConfirm(input)
        end

        ::continue::
    end

    while #self.inputReleaseQueue > 0 do
        local input = table.shift(self.inputReleaseQueue)

        self.playerStrumline:playStatic(input)

        self.playerStrumline:releaseKey(input)
    end
end

function PlayState:onKeyPress(event)
end

function PlayState:onKeyRelease(event)
end

function PlayState:processNotes(dt)
    if not self.playerStrumline then return end
    if not self.opponentStrumline then return end

    for i, note in ipairs(self.opponentStrumline.notes:getObjects()) do
        if note == nil then
            goto continue
        end

        local hitWindowStart = note.strumTime + Conductor.inputOffset - Constants.HIT_WINDOW_MS
        local hitWindowCenter = note.strumTime + Conductor.inputOffset
        local hitWindowEnd = note.strumTime + Conductor.inputOffset + Constants.HIT_WINDOW_MS

        if Conductor.songPosition > hitWindowEnd then
            if note.hasMissed or note.hasBeenHit then goto continue end

            note.tooEarly = false
            note.mayHit = false
            note.hasMissed = true

            if note.holdNoteSprite ~= nil then
                note.holdNoteSprite.missedNote = false
            end

            ::continue::
        elseif Conductor.songPosition > hitWindowCenter then
            if note.hasBeenHit then goto continue end

            local event = HitNoteScriptEvent(note, 0, 0, 'perfect', false, 0)

            if event.eventCanceled then goto continue end

            self.opponentStrumline:hitNote(note)

            if note.holdNoteSprite then
                self.opponentStrumline:playNoteHoldCover(note.holdNoteSprite)
            end
            
            ::continue::
        elseif Conductor.songPosition > hitWindowStart then
            if note.hasBeenHit or note.hasMissed then goto continue end

            note.tooEarly = false
            note.mayHit = true
            note.hasMissed = false
            if note.holdNoteSprite then
                note.holdNoteSprite.missedNote = false
            end

            ::continue::
        else
            note.tooEarly = true
            note.mayHit = false
            note.hasMissed = false
            if note.holdNoteSprite then
                note.holdNoteSprite.missedNote = false
            end
        end

        ::continue::
    end

    for i, note in ipairs(self.playerStrumline.notes:getObjects()) do
        if note == nil then
            goto continue
        end

        local hitWindowStart = note.strumTime + Conductor.inputOffset - Constants.HIT_WINDOW_MS
        local hitWindowCenter = note.strumTime + Conductor.inputOffset
        local hitWindowEnd = note.strumTime + Conductor.inputOffset + Constants.HIT_WINDOW_MS

        if Conductor.songPosition > hitWindowEnd then
            if note.hasMissed or note.hasBeenHit then goto continue end

            note.tooEarly = false
            note.mayHit = false
            note.hasMissed = true

            if note.holdNoteSprite ~= nil then
                note.holdNoteSprite.missedNote = false
            end

            ::continue::
        elseif Conductor.songPosition > hitWindowCenter then
            if self.isBotPlayMode then
                if note.hasBeenHit then goto continue end

                local event = HitNoteScriptEvent(note, 0, 0, 'perfect', false, 0)

                if event.eventCanceled then goto continue end

                self.playerStrumline:hitNote(note)

                if note.holdNoteSprite then
                    self.playerStrumline:playNoteHoldCover(note.holdNoteSprite)
                end
                ::continue::
            end
        elseif Conductor.songPosition > hitWindowStart then
            if note.hasBeenHit or note.hasMissed then goto continue end

            note.tooEarly = false
            note.mayHit = true
            note.hasMissed = false
            if note.holdNoteSprite then
                note.holdNoteSprite.missedNote = false
            end

            ::continue::
        else
            note.tooEarly = true
            note.mayHit = false
            note.hasMissed = false
            if note.holdNoteSprite then
                note.holdNoteSprite.missedNote = false
            end
        end

        ::continue::
    end

    for i, holdNote in ipairs(self.opponentStrumline.holdNotes:getObjects()) do
        if holdNote == nil or not holdNote.alive then goto continue end

        if holdNote.hitNote and not holdNote.missedNote and holdNote.sustainLength > 0 then
            if self.currentStage ~= nil and self.currentStage:getDad() ~= nil and self.currentStage:getDad():isSinging() then
                self.currentStage:getDad().holdTimer = 0
            end
        end

        if holdNote.missedNote and not holdNote.handledMiss then
            holdNote.handledMiss = true
            self.currentStage:getOpponent():playSingAnimation(holdNote.noteData:getDirection(), true)
        end

        ::continue::
    end
end

function PlayState:ghostNoteMiss(direction, hasPossibleNotes)
    hasPossibleNotes = hasPossibleNotes == nil and true or hasPossibleNotes

    local event = GhostMissNoteScriptEvent(direction, hasPossibleNotes, Constants.HEALTH_GHOST_MISS_PENALTY, -10)
    self:dispatchEvent(event)

    if event.eventCanceled then return end

    self.health = self.health + event.healthChange
    self.songScore = self.songScore + event.scoreChange

    if not self.isPracticeMode then
        local pressArray = {
            Controls:NOTE_LEFT_P(),
            Controls:NOTE_DOWN_P(),
            Controls:NOTE_UP_P(),
            Controls:NOTE_RIGHT_P()
        }

        local indices = {}
        for i, pressed in ipairs(pressArray) do
            if pressed then table.insert(indices, i-1) end
        end
        if event.playSound then
            if self.vocals ~= nil then
                self.vocals.playerVolume = 0
            end
            FunkinSound:playOnce(Paths.soundRandom('missnote', 1, 3), love.math.random() * 0.1 + 0.1)
        end
    end
end

function PlayState:goodNoteHit(note, direction)
    local inputLatencyNs = 0
    local inputLatencyMs = inputLatencyNs / Constants.NS_PER_MS
    if tostring(inputLatencyMs) == "nan" then
        inputLatencyMs = 0
    end

    local diff = Conductor.songPosition - note.noteData.t

    local totalDiff = diff
    if diff < 0 then
        totalDiff = diff + inputLatencyMs
    else
        totalDiff = diff - inputLatencyMs
    end

    local noteDiff = math.floor(totalDiff)

    local score = Scoring:scoreNote(noteDiff, "PBOT1")
    local daRating = Scoring:judgeNote(noteDiff, "PBOT1")

    local healthChange = 0
    local isComboBreak = false

    if daRating == 'sick' then
        healthChange = Constants.HEALTH_SICK_BONUS;
        isComboBreak = Constants.JUDGEMENT_SICK_COMBO_BREAK;
    elseif daRating == 'good' then
        healthChange = Constants.HEALTH_GOOD_BONUS;
        isComboBreak = Constants.JUDGEMENT_GOOD_COMBO_BREAK;
    elseif daRating == 'bad' then
        healthChange = Constants.HEALTH_BAD_BONUS;
        isComboBreak = Constants.JUDGEMENT_BAD_COMBO_BREAK;
    elseif daRating == 'shit' then
        healthChange = Constants.HEALTH_SHIT_BONUS;
        isComboBreak = Constants.JUDGEMENT_SHIT_COMBO_BREAK;
    end

    local event = HitNoteScriptEvent(note, healthChange, score, daRating, 
        isComboBreak, note.scoreable and 1 or 0,
            daRating == 'sick'
    )

    self:dispatchEvent(event)

    if event.eventCanceled then return end
    self.playerStrumline:hitNote(note, not event.isComboBreak)
    if event.doesNotesplash then  end
    if note.isHoldNote and note.holdNoteSprite ~= nil then self.playerStrumline:playNoteHoldCover(note.holdNoteSprite) end
    if self.vocals ~= nil then self.vocals.playerVolume = 1 end

    if note.scoreable then
        --Highscore.tallies.totalNotesHit = Highscore.tallies.totalNotesHit + 1
        self:applyScore(event.score, event.judgement, event.healthChange, event.isComboBreak)
        self:popUpScore(event.judgement)
    end
end

function PlayState:applyScore(score, judgement, healthChange, isComboBreak)
    if judgement == 'sick' then
        --Highscore.tallies.sicks = Highscore.tallies.sicks + 1
    elseif judgement == 'good' then
        --Highscore.tallies.goods = Highscore.tallies.goods + 1
    elseif judgement == 'bad' then
        --Highscore.tallies.bads = Highscore.tallies.bads + 1
    elseif judgement == 'shit' then
        --Highscore.tallies.shits = Highscore.tallies.shits + 1
    end

    self.health = self.health + healthChange
    if isComboBreak then
        -- if Highscore.tallies.combo >= 10 then self.comboPopUps:displayCombo(0) end
        -- Highscore.tallies.combo = 0
    else
        -- Highscore.tallies.combo = Highscore.tallies.combo + 1
        -- if Highscore.tallies.combo > Highscore.tallies.maxCombo then Highscore.tallies.maxCombo = Highscore.tallies.combo end
    end

    self.songScore = self.songScore + score
end

function PlayState:popUpScore(judgement, combo)
    if judgement == "miss" then
        return
    end

    if combo == nil then combo = --[[Highscore.tallies.combo]] 0 end

    if not self.isPracticeMode then
        -- self.comboPopUps:displayRating(judgement)
        -- if combo >= 10 then self.comboPopUps:displayCombo(combo) end
        if self.vocals ~= nil then self.vocals.playerVolume = 1 end
    end
end

return PlayState