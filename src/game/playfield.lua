local playfield = Object:extend()

function playfield:callObjects(eventName, event)
    for _, obj in ipairs(weeks.objects) do
        if obj.call then
            obj:call(eventName, event)
        end
    end
end

function playfield:callEvent(eventName, event)
    weeks.stage:call(eventName, event)
    weeks.song:call(eventName, event)
    self:callObjects(eventName, event)
end

function playfield:playMissAnimation(characterType, animation)
    for _, obj in ipairs(self.objects) do
        if obj.characterType == characterType then
            obj:play(animation, true, false)
        end

        if obj.call then
            obj:call("onNoteMiss", animation)
        end
    end
end

function playfield:new(playable, receptorSprite, targetType)
    self.playable = playable

    self.offsetX = 0
    self.receptors = {}
    self.notes = {}
    self.noteStart = {}
    self.receptorY = {}

    self.laneCount = 4
    self.targetType = targetType or CHARACTER_TYPE.BF

    for i = 1, self.laneCount do
        self.notes[i] = {}
        self.noteStart[i] = 1

        self.receptors[i] = receptorSprite()
        self.receptors[i]:animate(CONSTANTS.WEEKS.NOTE_LIST[i])
        self.receptors[i].x = 165 * (i - 1) + CONSTANTS.WEEKS.STRUM_X_OFFSET
        self.receptors[i].y = CONSTANTS.WEEKS.STRUM_Y * (settings.downscroll and -1 or 1)
        self.receptors[i].finishedAlpha = 1

        self.receptorY[i] = self.receptors[i].y
    end
end

function playfield:addNote(d, sprite)
    local lane = d.d % 4 + 1
    local time = d.t
    local holdTime = d.l or 0
    local type = d.k or "normal"

    local o = sprite()

    o.x = self.receptors[lane].x
    o.y = self.receptors[lane].y + time * 0.6 * weeks.speed
    o.col = lane
    o.time = time
    o.ver = type
    o:animate("on")
    o.hitNote = true
    o.healthGainMult = 1
    o.healthLossMult = 1
    o.causesMiss = false
    o.emitted = false

    table.insert(self.notes[lane], o)

    if holdTime > 0.1 then
        for k = 71 / weeks.speed, holdTime, 71 / weeks.speed do
            local hn = sprite()

            hn.col = lane
            hn.y = self.receptors[lane].y + (time + k) * 0.6 * weeks.speed
            hn.ver = type
            hn.time = time + k
            hn:animate("hold")

            hn.x = self.receptors[lane].x
            hn.healthGainMult = o.healthGainMult
            hn.healthLossMult = o.healthLossMult
            hn.causesMiss = o.causesMiss
            hn.hitNote = o.hitNote
            hn.emitted = false

            table.insert(self.notes[lane], hn)
        end

        local endNote = self.notes[lane][#self.notes[lane]]
        endNote:animate("end")
        endNote.flipY = settings.downscroll
    end
end

function playfield:sortNotes()
    for lane = 1, self.laneCount do
        table.sort(self.notes[lane], function(a, b)
            return a.time < b.time
        end)

        self.noteStart[lane] = 1
    end
end

function playfield:getNoteY(time)
    return CONSTANTS.WEEKS.PIXELS_PER_MS * (musicTime - time) * weeks.speed * (settings.downscroll and -1 or 1)
end

function playfield:onNoteHit(lane, note, receptor, ratingAnim, character)
    local noteAnim = note:getAnimName()

    receptor:animate(CONSTANTS.WEEKS.NOTE_LIST[lane] .. " confirm", false)

    if noteAnim ~= "hold" and noteAnim ~= "end" then
        weeks.health = weeks.health + (CONSTANTS.WEEKS.HEALTH.BONUS[string.upper(ratingAnim)] or 0) * weeks.healthGainMult * note.healthGainMult
    else
        weeks.health = weeks.health + 0.0125 * weeks.healthGainMult * note.healthGainMult
    end

    if character then
        character.lastHit = musicTime
    end

    local continue = Gamestate.onNoteHit(character, note.ver, ratingAnim, lane) == nil and true or false

    if continue then
        local healthChange = (CONSTANTS.WEEKS.HEALTH.BONUS[string.upper(ratingAnim)] or 0) * weeks.healthGainMult * note.healthGainMult
        if note:getAnimName() == "hold" or note:getAnimName() == "end" then
            healthChange = 0.0125 * weeks.healthGainMult * note.healthGainMult
        end
        local event = eventCreator:noteHit(note.ver, lane, ratingAnim, healthChange)

        for _, obj in ipairs(weeks.objects) do
            if obj.characterType == self.targetType then
                obj:play(CONSTANTS.WEEKS.ANIM_LIST[lane], true, false)

                if obj.call then
                    obj:call("onNoteHit", event)
                end
            end
        end

        weeks.stage:call("onNoteHit", event)
        weeks.song:call("onNoteHit", event)
    end

    -- self:calculateRating()
end

function playfield:onEnemyNoteHit(lane, note, receptor)
    local didEvent = false

    for _, obj in ipairs(weeks.objects) do
        if obj.CHARACTER_TYPE == self.targetType then
            local whohit = obj

            local continue

            if not didEvent then
                continue = (Gamestate.onNoteHit(enemy, note.ver, "EnemyHit", lane) == nil or false) and true or false

                local event = eventCreator:noteHit(note.ver, lane, "EnemyHit", 0)
                event.mustHit = false

                self:callEvent("onNoteHit", event)

                didEvent = true
            else
                continue = true
            end

            if continue then
                local noteAnim = note:getAnimName()

                if noteAnim == "hold" or noteAnim == "end" then
                    if whohit then
                        whohit:play(CONSTANTS.WEEKS.ANIM_LIST[lane], false, false)
                    end

                    if whohit then
                        whohit.holdTimer = 0
                    end
                else
                    -- NoteSplash:new(
                    --     {
                    --         anim = CONSTANTS.WEEKS.NOTE_LIST[i] .. tostring(love.math.random(1, 2)),
                    --         posX = receptor.x,
                    --         posY = receptor.y,
                    --         alpha = receptor.alpha,
                    --         visible = receptor.visible,
                    --     },
                    --     i
                    -- )

                    if whohit then
                        whohit:play(CONSTANTS.WEEKS.ANIM_LIST[lane], true, false)

                        if whohit.call then
                            whohit:call("onNoteHit", {noteType = note.ver, direction = lane, anim = CONSTANTS.WEEKS.ANIM_LIST[lane]})
                        end

                        weeks.stage:call("onNoteHit", whohit, note.ver, "EnemyHit", lane, CONSTANTS.WEEKS.ANIM_LIST[lane])
                        weeks.song:call("onNoteHit", whohit, note.ver, "EnemyHit", lane, CONSTANTS.WEEKS.ANIM_LIST[lane])
                    end

                    if whohit then
                        whohit.holdTimer = 0
                    end
                end
            end

            if whohit then
                whohit.lastHit = musicTime
            end
        end
    end
end

function playfield:missNote(lane, note)
    if weeks.voicesBF then
        weeks.voicesBF:setVolume(0)
    end

    local healthChange = -CONSTANTS.WEEKS.HEALTH.MISS_PENALTY * weeks.healthLossMult * note.healthLossMult
    local event = eventCreator:noteMiss(note.ver, lane, nil, healthChange)

    for _, obj in ipairs(weeks.objects) do
        if obj.characterType == CHARACTER_TYPE.BF then
            obj:play(CONSTANTS.WEEKS.ANIM_LIST[lane] .. "miss", true, false)
        end

        if obj.call then
            obj:call("onNoteMiss", event)
        end
    end

    weeks.stage:call("onNoteMiss", event)
    weeks.song:call("onNoteMiss", event)

    local noteAnim = note:getAnimName()

    weeks.health = weeks.health - event.healthChange

    if noteAnim ~= "hold" and noteAnim ~= "end" then
        --misses = misses + 1
    else
        Gamestate.onNoteMiss(weeks.boyfriend, note.ver, "BoyfriendMiss", lane)
    end

    -- if combo >= 70 then
    --     for _, obj in ipairs(self.objects) do
    --         if obj.characterType == CHARACTER_TYPE.GF then
    --             obj:play("drop70", true, false)
    --             obj.holdTimer = 0
    --         end
    --     end
    -- end
    -- combo = 0
end

function playfield:processInput(lane, notes, receptor)
    local inputKey = CONSTANTS.WEEKS.INPUT_LIST[lane]
    local noteName = CONSTANTS.WEEKS.NOTE_LIST[lane]

    if input:pressed(inputKey) then
        local success = false
        local didHitNote = false

        if settings.ghostTapping then
            success = true
            didHitNote = false
        end

        receptor:animate(noteName .. " press", false)

        for j = 1, #notes do
            local note = notes[j]

            if note and note:getAnimName() == "on" then
                local noteOffset = note.time - musicTime

                if noteOffset <= CONSTANTS.WEEKS.JUDGE_THRES[settings.judgePreset].MISS_THRES and ((note.causesMiss and noteOffset > 0) or true) and not note.didHit then
                    local notePos = math.abs(noteOffset)

                    if weeks.voicesBF then
                        weeks.voicesBF:setVolume(1)
                    end

                    if weeks.boyfriend then
                        weeks.boyfriend.lastHit = musicTime
                    end

                    local ratingAnim = "sick"--self:judgeNote(notePos)

                    -- table.insert(nps, love.timer.getTime())
                    -- maxNPS = math.max(maxNPS, #nps)
                    weeks.score = weeks.score + 500--self:scoreNote(notePos)

                    -- if settings.scoringType == "Psych" then
                    --     ratingTextScale = 1.075
                    -- end

                    if ratingAnim == "sick" then
                        -- NoteSplash:new(
                        --     {
                        --         anim = CONSTANTS.WEEKS.NOTE_LIST[i] .. tostring(love.math.random(1, 2)),
                        --         posX = boyfriendArrow.x,
                        --         posY = boyfriendArrow.y,
                        --         alpha = boyfriendArrow.alpha,
                        --         visible = boyfriendArrow.visible,
                        --     },
                        --     i
                        -- )
                    end

                    -- combo = combo + 1
                    -- if combo == 50 then
                    --     for _, obj in ipairs(self.objects) do
                    --         if obj.characterType == CHARACTER_TYPE.GF then
                    --             obj:play("combo50", true, false)
                    --             obj.holdTimer = 0
                    --         end
                    --     end
                    -- elseif combo == 200 then
                    --     for _, obj in ipairs(self.objects) do
                    --         if obj.characterType == CHARACTER_TYPE.GF then
                    --             obj:play("combo200", true, false)
                    --             obj.holdTimer = 0
                    --         end
                    --     end
                    -- end
                    -- if combo > maxCombo then maxCombo = combo end
                    -- noteCounter = noteCounter + 1

                    if not settings.ghostTapping or success then
                        self:onNoteHit(lane, note, receptor, ratingAnim, weeks.boyfriend)
                        success = true
                        didHitNote = true
                    end

                    table.remove(notes, j)

                    break
                end
            end
        end

        if not success then
            audio.playSound(sounds.miss[love.math.random(3)])

            self:playMissAnimation(self.targetType, CONSTANTS.WEEKS.ANIM_LIST[lane] .. "miss")

            if didHitNote then
                weeks.score = math.max(0, weeks.score - 100) -- if note was "missed" but hit, remove 100 points
            else
                weeks.score = math.max(0, weeks.score - 10) -- If ghost tapped, remove 10 points
            end

            if #notes > 0 then
                weeks.health = weeks.health - (CONSTANTS.WEEKS.HEALTH.MISS_PENALTY or 0.2) * (weeks.healthLossMult or 1) * (notes[1].healthLossMult or 1)
            end

            --misses = misses + 1
        end
    end

    if input:down(inputKey) and #notes > 0 and notes[1].time - musicTime <= 0 and (notes[1]:getAnimName() == "hold" or notes[1]:getAnimName() == "end") then
        local note = notes[1]

        if note:getAnimName() == "hold" then
            -- HoldCover:show(i, 1, notes[1].x, notes[1].y)
            -- inHolds[i] = true
        else
            -- HoldCover:hide(i, 1)
            -- inHolds[i] = false
        end

        if weeks.voicesBF then
            weeks.voicesBF:setVolume(1)
        end

        receptor:animate(noteName .. " confirm", false)
        health = health + 0.0125 * weeks.healthGainMult * note.healthGainMult

        if weeks.boyfriend then
            weeks.boyfriend.lastHit = musicTime
        end

        table.remove(notes, 1)
    end

    if not input:down(inputKey) --[[and not HoldCover:getVisibility(i, 1)]] then
        -- HoldCover:hide(i, 1)
        -- inHolds[i] = false
    end

    if input:released(inputKey) then
        receptor:animate(noteName, false)
    end
end

function playfield:processAutomatic(lane, notes, receptor)
    local noteName = CONSTANTS.WEEKS.NOTE_LIST[lane]

    if #notes == 0 then
        if not receptor:isAnimated() then
            receptor:animate(noteName, false)
        end

        return
    end

    local note = notes[1]

    if note.time > musicTime then
        if not receptor:isAnimated() then
            receptor:animate(noteName, false)
        end

        return
    end

    receptor:animate(noteName .. " confirm", false)

    self:onEnemyNoteHit(lane, note, receptor)

    table.remove(notes, 1)
end

function playfield:processNoteMisses(lane, notes)
    while #notes > 0 and notes[1].time - musicTime <= -200 do
        local note = notes[1]

        self:missNote(lane, note)
        table.remove(notes, 1)
    end
end

function playfield:update(dt)
    local currentTime = musicTime
    local minTime = currentTime - 2500
    local maxTime = currentTime + 2500

    local pixelsPerMs = CONSTANTS.WEEKS.PIXELS_PER_MS
    local speed = weeks.speed
    local direction = settings.downscroll and -1 or 1

    for lane = 1, self.laneCount do
        local receptor = self.receptors[lane]
        local notes = self.notes[lane]
        local start = self.noteStart[lane]
        local count = #notes
        local receptorY = self.receptorY[lane]

        receptor:update(dt)

        while start <= count and notes[start].time < minTime do
            start = start + 1
        end

        self.noteStart[lane] = start

        for i = start, count do
            local note = notes[i]
            local noteTime = note.time

            if noteTime > maxTime then
                break
            end

            note.y = receptorY - pixelsPerMs * (currentTime - noteTime) * speed * direction

            if not note.emitted then
                note.emitted = true

                local event = eventCreator:onNoteOncoming(note.ver, note.col, note)
                self:callEvent("onNoteOncoming", event)
            end
        end

        if self.playable then
            self:processNoteMisses(lane, notes)
            self:processInput(lane, notes, receptor)
        else
            self:processAutomatic(lane, notes, receptor)
        end
    end
end

function playfield:draw()
    love.graphics.push()
        love.graphics.translate(self.offsetX, 0)

        for _, receptor in ipairs(self.receptors) do
            receptor:draw()
        end

        local visibleNotes = {}

        local minTime = musicTime - 5000
        local maxTime = musicTime + 5000

        for lane = 1, self.laneCount do
            local notes = self.notes[lane]
            local start = self.noteStart[lane]
            local count = #notes

            for i = start, count do
                local note = notes[i]
                local time = note.time

                if time > maxTime then
                    break
                end

                if time >= minTime then
                    visibleNotes[#visibleNotes + 1] = note
                end
            end
        end

        table.sort(visibleNotes, function(a, b)
            return a.time < b.time
        end)

        for i = #visibleNotes, 1, -1 do
            visibleNotes[i]:draw()
        end
    love.graphics.pop()
end

return playfield