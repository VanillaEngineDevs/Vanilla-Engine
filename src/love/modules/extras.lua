function weeks.legacyGenerateNotes(self, chart)
    if importMods.inMod then
        importMods.setupScripts()
    end
    self.overrideHealthbarText = importMods.uiHealthbarTextMod or nil
	self.overrideDrawHealthbar = importMods.uiHealthbarMod or nil
    local chart = getFilePath(chart)
    chart = json.decode(love.filesystem.read(chart)).song

    for i = 1, #chart.notes do
        bpm = chart.notes[i].bpm

        if bpm then break end
    end

    if not bpm then
        bpm = 100
    end
    local totalSteps = 0
    local totalPos = 0
    beatHandler.setBPM(bpm)

    if settings.customScrollSpeed == 1 then
        speed = chart.speed or 1
    else
        speed = settings.customScrollSpeed
    end

    for _, section in ipairs(chart.notes) do
        local mustHitSection = section.mustHitSection or false
        for _, noteData in ipairs(section.sectionNotes) do
            local time = noteData[1] 
            local noteType = noteData[2]
            local noteVer = noteData[4] or "normal"
            local holdLength = noteData[3] or 0

            if noteVer == "Hurt Note" or noteType < 0 then goto continue end

            local id = noteType % 4 + 1
            
            local noteObject = noteSprites[id]()

            local dataStuff = {}
            if noteTypes[noteVer] then
                dataStuff = noteTypes[noteVer]
            else
                dataStuff = noteTypes["normal"]
            end

            noteObject.col = id
            noteObject.y = -400 + time * 0.6 * speed
            noteObject.ver = noteVer
            noteObject.time = time
            noteObject:animate("on")

            if settings.downscroll then noteObject.sizeY = -1 end

            local enemyNote = (mustHitSection and noteType >= 4) or (not mustHitSection and noteType < 4)
            local notesTable = enemyNote and enemyNotes or boyfriendNotes
            local arrowsTable = enemyNote and enemyArrows or boyfriendArrows

            noteObject.x = arrowsTable[id].x
            noteObject.shader = CONSTANTS.WEEKS.LANE_SHADERS[id]
            local r, g, b = CONSTANTS.ARROW_COLORS[id][1], CONSTANTS.ARROW_COLORS[id][2], CONSTANTS.ARROW_COLORS[id][3]

            if dataStuff.r or dataStuff.g or dataStuff.b then
                noteObject.shader = love.graphics.newShader("shaders/RGBPallette.glsl")
            end

			if dataStuff.r then r = {decToRGB(dataStuff.r)} end
			if dataStuff.g then g = {decToRGB(dataStuff.g)} end
			if dataStuff.b then b = {decToRGB(dataStuff.b)} end
			noteObject.hitNote = not dataStuff.ignoreNote

            noteObject.healthGainMult = dataStuff.healthMult or 1
			noteObject.healthLossMult = dataStuff.healthLossMult or 1

            noteObject.causesMiss = dataStuff.causesMiss or false

			noteObject.shader:send("r", r)
			noteObject.shader:send("g", g)
			noteObject.shader:send("b", b)

            table.insert(notesTable[id], noteObject)
            if holdLength > 0 then
                for k = 71 / speed, holdLength, 71 / speed do
                    local holdNote = noteSprites[id]()
                    holdNote.col = id
                    holdNote.y = -400 + (time + k) * 0.6 * speed
                    holdNote.ver = noteVer
                    holdNote.time = time + k
                    holdNote:animate("hold")

                    holdNote.x = arrowsTable[id].x
                    holdNote.shader = noteObject.shader
                    holdNote.healthGainMult = noteObject.healthGainMult
					holdNote.healthLossMult = noteObject.healthLossMult
                    holdNote.causesMiss = noteObject.causesMiss
                    holdNote.hitNote = noteObject.hitNote
                    table.insert(notesTable[id], holdNote)
                end

                notesTable[id][#notesTable[id]]:animate("end")
            end

            ::continue::
        end

        if chart.events then
            for i, event in ipairs(chart.events) do
                local time, eventData = event[1], event[2]

                table.insert(modEvents, {
                    time = time,
                    events = eventData
                })
            end
        end

        table.sort(modEvents, function(a, b) return a.time < b.time end)

        local deltaSteps = section.lengthInSteps or 16
        totalSteps = totalSteps + deltaSteps
        totalPos = totalPos + ((60/bpm) * 1000 / 4) * deltaSteps

        local eventName = "FocusCamera"
        local value = {
            char = mustHitSection and 0 or 1
        }

        table.insert(songEvents, {
            time = totalPos,
            name = eventName,
            value = value
        })

        if section.changeBPM then
            bpm = section.bpm or bpm
        end
    end

    for i = 1, 4 do
        table.sort(enemyNotes[i], function(a, b) return a.y < b.y end)
        table.sort(boyfriendNotes[i], function(a, b) return a.y < b.y end)
    end
end

function weeks.generatePsychEvents(self, eventsChart)
    modEvents = {}
    local eventsChart = getFilePath(eventsChart)
    eventsChart = json.decode(love.filesystem.read(eventsChart)).song

    for i, event in ipairs(eventsChart.events) do
        local time, eventData = event[1], event[2]

        table.insert(modEvents, {
            time = time,
            events = eventData
        })
    end


    table.sort(modEvents, function(a, b) return a.time < b.time end)
end

function weeks.cneGenerateNotes(self, chart, metadata)
    if importMods.inMod then
        importMods.setupScripts()
    end
    self.overrideHealthbarText = importMods.uiHealthbarTextMod or nil
	self.overrideDrawHealthbar = importMods.uiHealthbarMod or nil
    local chart = getFilePath(chart)
    chart = json.decode(love.filesystem.read(chart))
    local metadata = json.decode(love.filesystem.read(metadata))

    bpm = metadata.bpm or 100
    beatHandler.setBPM(bpm)

    if settings.customScrollSpeed == 1 then
        speed = chart.screenSpeed or 1
    else
        speed = settings.customScrollSpeed
    end
    
    for _, strumline in ipairs(chart.strumLines) do
        -- strumline.visible, if its nil, set to true
        if strumline.visible == nil then strumline.visible = true end
        if (strumline.type ~= 0 and strumline.type ~= 1) or not strumline.visible then goto continue end
        local enemyNote = strumline.type == 0
        local notesTable = enemyNote and enemyNotes or boyfriendNotes
        local arrowsTable = enemyNote and enemyArrows or boyfriendArrows

        for _, note in ipairs(strumline.notes) do
            local time = note.time
            local noteType = note.id
            local noteVer = note.type == 0 and "normal" or note.type or "normal"
            local holdLength = note.sLen or 0

            if noteVer == "Hurt Note" or noteType < 0 then goto continue end

            local id = noteType % 4 + 1
            
            local noteObject = noteSprites[id]()

            noteObject.col = id
            noteObject.y = -400 + time * 0.6 * speed
            noteObject.ver = noteVer
            noteObject.time = time
            noteObject:animate("on")

            if settings.downscroll then noteObject.sizeY = -1 end

            local dataStuff = {}
            if noteTypes[noteVer] then
                dataStuff = noteTypes[noteVer]
            else
                dataStuff = noteTypes["normal"]
            end

            noteObject.x = arrowsTable[id].x
            noteObject.shader = CONSTANTS.WEEKS.LANE_SHADERS[id]
            local r, g, b = CONSTANTS.ARROW_COLORS[id][1], CONSTANTS.ARROW_COLORS[id][2], CONSTANTS.ARROW_COLORS[id][3]

            if dataStuff.r or dataStuff.g or dataStuff.b then
                noteObject.shader = love.graphics.newShader("shaders/RGBPallette.glsl")
            end

            if dataStuff.r then r = {decToRGB(dataStuff.r)} end
			if dataStuff.g then g = {decToRGB(dataStuff.g)} end
			if dataStuff.b then b = {decToRGB(dataStuff.b)} end
			noteObject.hitNote = not dataStuff.ignoreNote

            noteObject.healthGainMult = dataStuff.healthMult or 1
			noteObject.healthLossMult = dataStuff.healthLossMult or 1

            noteObject.causesMiss = dataStuff.causesMiss or false
            
            noteObject.shader:send("r", r)
            noteObject.shader:send("g", g)
            noteObject.shader:send("b", b)

            table.insert(notesTable[id], noteObject)
            if holdLength > 0 then
                for k = 71 / speed, holdLength, 71 / speed do
                    local holdNote = noteSprites[id]()
                    holdNote.col = id
                    holdNote.y = -400 + (time + k) * 0.6 * speed
                    holdNote.ver = noteVer
                    holdNote.time = time + k
                    holdNote:animate("hold")

                    holdNote.x = arrowsTable[id].x
                    holdNote.shader = noteObject.shader
                    holdNote.healthGainMult = noteObject.healthGainMult
					holdNote.healthLossMult = noteObject.healthLossMult
                    holdNote.causesMiss = noteObject.causesMiss
                    holdNote.hitNote = noteObject.hitNote
                    table.insert(notesTable[id], holdNote)
                end

                notesTable[id][#notesTable[id]]:animate("end")
            end
        end

        ::continue::
    end
end
