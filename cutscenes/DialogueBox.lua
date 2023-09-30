local DialogueBox = Group:extend()

function DialogueBox:new(talkingRight, dialogueList)
    local talkingRight = (talkingRight == nil) and true or talkingRight

    self.box = nil
    self.curCharacter = ""
    self.dialogueList = {}
    self.swagDialogue = nil--Text(0, 0, 0, "", Paths.font("assets/fonts/pixel.otf", 24))
    self.dropText = nil
    self.finishThing = nil
    self.nextDialogueThing = nil
    self.skipDialogueThing = nil
    self.portraitLeft = nil
    self.portraitRight = nil
    self.handSelect = nil
    self.bgFade = nil
    self.hasDialogue = true
    self.dialogueOpened = false
    self.dialogueStarted = false
    self.dialogueEnded = false

    self.super.new(self)

    self.bgFade = Sprite(-200, -200)
    self.bgFade:makeGraphic(push:getWidth()*1.3, push:getHeight()*1.32, hexToColor(0xFFB3DFd8))
    self.bgFade.color = hexToColor(0xFFB3DFd8)
    self.bgFade.scrollFactor = {x = 0, y = 0}
    self.bgFade.alpha = 0
    self:add(self.bgFade)

    self.loops = 5
    function DialogueBox:doBGFade()
        Timer.after(0.83, function()
            self.bgFade.alpha = self.bgFade.alpha + (1 / 5) * 0.7
            if self.bgFade.alpha > 0.7 then
                self.bgFade.alpha = 0.7
            end

            if self.loops > 0 then
                self.loops = self.loops - 1
                self:doBGFade()
            end
        end)
    end
    self:doBGFade()

    self.box = Sprite(-20, 45)
    local songName = PlayState.SONG.song:lower()
    if songName == "senpai" then
        self.box:setFrames(Paths.getAtlas("pixel/pixelUI/dialogueBox-pixel", "assets/images/png/pixel/pixelUI/dialogueBox-pixel.xml"))
        self.box:addByPrefix("normalOpen", "Text Box Appear", 24, false)
    elseif songName == "roses" then
        self.box:setFrames(Paths.getAtlas("pixel/pixelUI/dialogueBox-senpaiMad", "assets/images/png/pixel/pixelUI/dialogueBox-senpaiMad.xml"))
        self.box:addByPrefix("normalOpen", "SENPAI ANGRY IMPACT SPEECH", 24, false)
    elseif songName == "thorns" then
        self.box:setFrames(Paths.getAtlas("pixel/pixelUI/dialogueBox-evil", "assets/images/png/pixel/pixelUI/dialogueBox-evil.xml"))
        self.box:addByPrefix("normalOpen", "Spirit Textbox spawn", 24, false)

        self.face = Sprite(225, -100)
        self.face:load("pixel/spiritFaceForward")
        self.face:setGraphicSize(math.floor(self.face.width * 6))
        self:add(self.face)
    else
        self.hasDialogue = false
    end

    self.dialogueList = dialogueList

    self.portraitLeft = Sprite(-20, 40)
    self.portraitLeft:setFrames(Paths.getAtlas("pixel/senpaiPortrait", "assets/images/png/pixel/senpaiPortrait.xml"))
    self.portraitLeft:addByPrefix("enter", "Senpai Portrait Enter", 24, false)
    self.portraitLeft:setGraphicSize(math.floor(self.portraitLeft.width * PlayState.daPixelZoom * 0.9))
    self.portraitLeft:updateHitbox()
    self.portraitLeft.scrollFactor = {x = 0, y = 0}
    self.portraitLeft.visible = false
    self.portraitLeft.antialiasing = true
    self:add(self.portraitLeft)

    self.portraitRight = Sprite(0, 40)
    self.portraitRight:setFrames(Paths.getAtlas("pixel/bfPortrait", "assets/images/png/pixel/bfPortrait.xml"))
    self.portraitRight:addByPrefix("enter", "Boyfriend portrait enter", 24, false)
    self.portraitRight:setGraphicSize(math.floor(self.portraitRight.width * PlayState.daPixelZoom * 0.9))
    self.portraitRight:updateHitbox()
    self.portraitRight.scrollFactor = {x = 0, y = 0}
    self.portraitRight.visible = false
    self.portraitRight.antialiasing = true
    self:add(self.portraitRight)

    self.box:play("normalOpen")
    self.box:setGraphicSize(math.floor(self.box.width * PlayState.daPixelZoom * 0.9))
    self.box:updateHitbox()
    self.box.antialiasing = true
    self:add(self.box)

    self.box:screenCenter("X")
    self.portraitLeft:screenCenter("X")

    self.handSelect = Sprite(1170, 670)
    self.handSelect:load("pixel/pixelUI/hand_textbox")
    self.handSelect:setGraphicSize(math.floor(self.handSelect.width * PlayState.daPixelZoom * 0.9))
    self.handSelect:updateHitbox()
    self.handSelect.visible = false
    self.handSelect.antialiasing = true
    self:add(self.handSelect)

    self.dropText = Text(240, 500, math.floor(push:getWidth() * 0.6), "", Paths.font("assets/fonts/pixel.otf", 32))
    self.dropText.color = hexToColor(0x00000000)
    self:add(self.dropText)
    self.dropText.alignment = "left"

    self.swagDialogue = Text(240, 500, math.floor(push:getWidth() * 0.6), "", Paths.font("assets/fonts/pixel.otf", 32))
    self.swagDialogue.color = hexToColor(0xFFFFFFFF)
    self.dropText.text = self.swagDialogue.text
    self:add(self.swagDialogue)
    self.swagDialogue.alignment = "left"

    self.originalDelay = 0.04
    self.delay = self.originalDelay
end

function DialogueBox:update(dt)
    self.super.update(self, dt)
    local songName = PlayState.SONG.song:lower()
    if songName == "roses" then
        self.portraitLeft.visible = false
    end
    if songName == "thorns" then
        self.portraitLeft.visible = false
    end

    if self.box.curAnim then
        if self.box.curAnim.name == "normalOpen" and self.box.animFinished then
            self.dialogueOpened = true
        end
    end

    if self.dialogueOpened and not self.dialogueStarted then
        self:startDialogue()
        self.dialogueStarted = true
    end

    if input:pressed("m_confirm") then
        if self.dialogueEnded then
            if not self.dialogueList[2] and self.dialogueList[1] then
                if not self.isEnding then
                    self.isEnding = true
                    Sound.play(Paths.sound("assets/sounds/clickText.ogg"))

                    self.loops = 7
                    function DialogueBox:doFade()
                        Timer.after(0.2, function()
                            self.box.alpha = self.box.alpha - 1/5 * 0.7
                            self.bgFade.alpha = self.bgFade.alpha - 1/5 * 0.7
                            self.portraitLeft.visible = false
                            self.portraitRight.visible = false
                            self.swagDialogue.alpha = self.swagDialogue.alpha - 1/5
                            self.handSelect.alpha = self.handSelect.alpha - 1/5
                            self.dropText.alpha = self.swagDialogue.alpha
                            if self.face then self.face.alpha = self.face.alpha - 1/5 end

                            if self.loops > 0 then
                                self.loops = self.loops - 1
                                self:doFade()
                            end
                        end)
                    end
                    self:doFade()

                    Timer.after(1.5, function()
                        self.finishThing(PlayState)
                    end)
                end
            else
                -- when i call table.remove, it fucking ADDED shit?? bro it went from 3 index's to 54??????? God I hate lua sometimes
                -- Remove the first element and reindex the table
                for i = 1, #self.dialogueList - 1 do
                    self.dialogueList[i] = self.dialogueList[i + 1]
                end
                self.dialogueList[#self.dialogueList] = nil -- Remove the last duplicate element

                self:startDialogue()
                Sound.play(Paths.sound("assets/sounds/clickText.ogg"))
            end
        elseif not self.dialogueEnded then
            Sound.play(Paths.sound("assets/sounds/clickText.ogg"))
            self.swagDialogue.text = self.swagDialogue.fullText

            if self.skipDialogueThing then
                self:skipDialogueThing()
            end
        end
    end

    if not self.dialogueEnded then
        -- the text delay for a new letter is 0.04
        self.delay = self.delay - dt
        if self.delay <= 0 then
            Sound.play(Paths.sound("assets/sounds/week6/pixelText.ogg"))
            self.delay = self.originalDelay
            self.swagDialogue.text = self.swagDialogue.text .. self.swagDialogue.fullText:sub(self.swagDialogue.text:len() + 1, self.swagDialogue.text:len() + 1)
        end

        if self.swagDialogue.text == self.swagDialogue.fullText then
            if not self.swagDialogue.calledCallback then
                self.swagDialogue.calledCallback = true
                if self.swagDialogue.callBack then
                    self.swagDialogue.callBack(self)
                end
            end
            self.dialogueEnded = true
        end
    end
end

function DialogueBox:startDialogue()
    self:cleanDialogue()

    self.swagDialogue.text = ""
    self.swagDialogue.fullText = self.dialogueList[1]
    self.swagDialogue.calledCallback = false
    self.swagDialogue.callBack = function(db)
        db.handSelect.visible = true
        db.dialogueEnded = true
    end
    self.delay = self.originalDelay

    self.dialogueEnded = false
    self.handSelect.visible = false

    
    if self.curCharacter == "dad" then
        self.portraitRight.visible = false
        if not self.portraitLeft.visible then
            if PlayState.SONG.song:lower() == "senpai" then self.portraitLeft.visible = true end
            self.portraitLeft:play("enter", true)
        end
    elseif self.curCharacter == "bf" then
        if not self.portraitRight.visible then
            self.portraitRight.visible = true
            self.portraitRight:play("enter", true)
        end
        self.portraitLeft.visible = false
    end
    
    if self.nextDialogueThing then
        self:nextDialogueThing()
    end
end

function DialogueBox:cleanDialogue()
    local splitName = self.dialogueList[1]:split(":")
    -- remove : from splitName[1] (at start)
    self.curCharacter = splitName[1]
    self.dialogueList[1] = splitName[2]
end
    
return DialogueBox