-- REQUIRE THIS FILE AFTER ALL THE STATES. THIS FILE ADDS BACK DEPRECATED FUNCTIONS FROM THEM.

function weeks.legacyGenerateNotes(self, chart)
    local chart = json.decode(love.filesystem.read(chart)).song

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

    local sprites = {
        sprites.leftArrow,
        sprites.downArrow,
        sprites.upArrow,
        sprites.rightArrow
    }

    for _, section in ipairs(chart.notes) do
        local mustHitSection = section.mustHitSection or false
        for _, noteData in ipairs(section.sectionNotes) do
            local time = noteData[1] 
            local noteType = noteData[2]
            local noteVer = noteData[4] or "normal"
            local holdLength = noteData[3] or 0

            if noteVer == "Hurt Note" or noteType < 0 then goto continue end

            local id = noteType % 4 + 1
            
            local noteObject = sprites[id]()

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

            table.insert(notesTable[id], noteObject)
            if holdLength > 0 then
                for k = 71 / speed, holdLength, 71 / speed do
                    local holdNote = sprites[id]()
                    holdNote.col = id
                    holdNote.y = -400 + (time + k) * 0.6 * speed
                    holdNote.ver = noteVer
                    holdNote.time = time + k
                    holdNote:animate("hold")

                    holdNote.x = arrowsTable[id].x
                    table.insert(notesTable[id], holdNote)
                end

                notesTable[id][#notesTable[id]]:animate("end")
            end

            ::continue::
        end

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

-- I gotta rename this file..,..,.
-- This file will just have spare functions,.,.
function weeks.cneGenerateNotes(self, chart, metadata)
    local chart = json.decode(love.filesystem.read(chart))
    local metadata = json.decode(love.filesystem.read(metadata))

    bpm = metadata.bpm or 100
    beatHandler.setBPM(bpm)

    if settings.customScrollSpeed == 1 then
        speed = chart.screenSpeed or 1
    else
        speed = settings.customScrollSpeed
    end

    local sprites = {
        sprites.leftArrow,
        sprites.downArrow,
        sprites.upArrow,
        sprites.rightArrow
    }
    
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
            
            local noteObject = sprites[id]()
            noteObject.col = id
            noteObject.y = -400 + time * 0.6 * speed
            noteObject.ver = noteVer
            noteObject.time = time
            noteObject:animate("on")

            if settings.downscroll then noteObject.sizeY = -1 end

            noteObject.x = arrowsTable[id].x

            table.insert(notesTable[id], noteObject)
            if holdLength > 0 then
                for k = 71 / speed, holdLength, 71 / speed do
                    local holdNote = sprites[id]()
                    holdNote.col = id
                    holdNote.y = -400 + (time + k) * 0.6 * speed
                    holdNote.ver = noteVer
                    holdNote.time = time + k
                    holdNote:animate("hold")

                    holdNote.x = arrowsTable[id].x
                    table.insert(notesTable[id], holdNote)
                end

                notesTable[id][#notesTable[id]]:animate("end")
            end
        end

        ::continue::
    end
end