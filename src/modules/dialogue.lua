local dialogue = {}

dialogue.sounds = {
    text = love.audio.newSource("sounds/pixel/text.ogg", "static"),
    confirm = love.audio.newSource("sounds/pixel/continue-text.ogg", "static"),
    music = false
}

dialogue.speakers = {}
dialogue.speakerBoxes = {}

dialogue.list = {}
dialogue.cur = 1
dialogue.timer = 0
dialogue.progress = 1
dialogue.output = ""
dialogue.isDone = false

dialogue.charSpeaking = ""
dialogue.fullDialogue = ""

dialogue.callback = function() end

function dialogue.set(dia)
    -- dialogue can be given as a file or a table like 
    --[[
    {
        {"speaker", "text"},
        {"speaker", "text"}
    }
    ]]
    dialogue.isFile = type(dia) == "string" and true or false
    dialogue.list = dialogue.isFile and {} or dia
    dialogue.cur = 1
    dialogue.timer = 0
    dialogue.progress = 1
    dialogue.output = ""
    dialogue.isDone = false

    if dialogue.isFile then
        for line in love.filesystem.lines(dia) do
            -- remove the first :
            line = line:sub(2)
            local speaker, text = line:match("([^:]+):(.+)")
            table.insert(dialogue.list, {speaker, text})
        end
    end

    inCutscene = true
end

function dialogue.setMusic(music)
    dialogue.sounds.music = music
end

function dialogue.removeMusic()
    dialogue.sounds.music = false
end

function dialogue.addSpeaker(speaker, image, x, y, sizeX, sizeY, isSprite, repeatAnim)
    dialogue.speakers[speaker] = image
    dialogue.speakers[speaker].x = x
    dialogue.speakers[speaker].y = y
    dialogue.speakers[speaker].sizeX = sizeX
    dialogue.speakers[speaker].sizeY = sizeY
    dialogue.speakers[speaker].isSprite = isSprite
    dialogue.speakers[speaker].repeatAnim = repeatAnim

    if dialogue.speakers[speaker].isSprite then
        dialogue.speakers[speaker]:animate("anim")
    end
end

function dialogue.setSpeakerBox(speaker, boxImg, x, y, sizeX, sizeY, isSprite, repeatAnim)
    dialogue.speakerBoxes[speaker] = boxImg
    dialogue.speakerBoxes[speaker].x = x
    dialogue.speakerBoxes[speaker].y = y
    dialogue.speakerBoxes[speaker].sizeX = sizeX
    dialogue.speakerBoxes[speaker].sizeY = sizeY
    dialogue.speakerBoxes[speaker].isSprite = isSprite
    dialogue.speakerBoxes[speaker].repeatAnim = repeatAnim

    if dialogue.speakerBoxes[speaker].isSprite then
        dialogue.speakerBoxes[speaker]:animate("anim")
    end
end

function dialogue.setCallback(func)
    dialogue.callback = func
end

function dialogue.doDialogue(dt)
    dialogue.charSpeaking = dialogue.list[dialogue.cur][1]
    dialogue.fullDialogue = dialogue.list[dialogue.cur][2]

    if dialogue.speakers[dialogue.charSpeaking] then
        if dialogue.speakers[dialogue.charSpeaking].isSprite then
            dialogue.speakers[dialogue.charSpeaking]:update(dt)
        end
    end

    if dialogue.speakerBoxes[dialogue.charSpeaking] then
        if dialogue.speakerBoxes[dialogue.charSpeaking].isSprite then
            dialogue.speakerBoxes[dialogue.charSpeaking]:update(dt)
        end
    end

    if dialogue.sounds.music and not dialogue.sounds.music:isPlaying() then
        dialogue.sounds.music:play()
    end

    dialogue.timer = dialogue.timer + 0.75 * dt

    if dialogue.timer > 0.05 then
        if dialogue.progress < #dialogue.fullDialogue then
            dialogue.sounds.text:play()
            dialogue.progress = dialogue.progress + 1
            dialogue.output = dialogue.fullDialogue:sub(1, math.floor(dialogue.progress))

            dialogue.timer = 0
        else
            dialogue.timer = 0
        end
    end
end

function dialogue.removeSpeakerBox(speaker)
    dialogue.speakerBoxes[speaker] = nil
end

function dialogue.removeSpeaker(speaker)
    dialogue.speakers[speaker] = nil
end

function dialogue.next()
    dialogue.sounds.confirm:play()

    if dialogue.progress < #dialogue.fullDialogue then
        dialogue.progress = #dialogue.fullDialogue
        dialogue.output = dialogue.fullDialogue
    else
        if dialogue.cur < #dialogue.list then
            dialogue.cur = dialogue.cur + 1
            dialogue.timer = 0
            dialogue.progress = 1
            dialogue.output = ""

            if dialogue.speakers[dialogue.charSpeaking] then
                if dialogue.speakers[dialogue.charSpeaking].isSprite and dialogue.speakers[dialogue.charSpeaking].repeatAnim then
                    dialogue.speakers[dialogue.charSpeaking]:animate("anim")
                end
            end
        
            if dialogue.speakerBoxes[dialogue.charSpeaking] then
                if dialogue.speakerBoxes[dialogue.charSpeaking].isSprite and dialogue.speakerBoxes[dialogue.charSpeaking].repeatAnim then
                    dialogue.speakerBoxes[dialogue.charSpeaking]:animate("anim")
                end
            end
        else
            dialogue.isDone = true

            dialogue.callback()

            if dialogue.sounds.music then
                dialogue.sounds.music:stop()
            end

            inCutscene = false
        end
    end
end

function dialogue.draw()
    if pixel then love.graphics.setFont(pixelFont) else love.graphics.setFont(font) end
    if dialogue.speakers[dialogue.charSpeaking] then dialogue.speakers[dialogue.charSpeaking]:draw() end
    if dialogue.speakerBoxes[dialogue.charSpeaking] then dialogue.speakerBoxes[dialogue.charSpeaking]:draw() end

    love.graphics.printf(dialogue.output, 150, 435, 200, "left", 0, (pixel and 4.7 or 1), (pixel and 4.7 or 1))
    love.graphics.setFont(font)
end

return dialogue