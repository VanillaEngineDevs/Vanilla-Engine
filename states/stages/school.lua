local Stage = BaseStage:extend()

local BackgroundGirls = require "states.stages.objects.BackgroundGirls"

Stage.bgGirls = nil

Stage.doof = nil

Stage.music = nil

function Stage:create()
    self.music = love.audio.newSource("assets/music/Lunchbox.ogg", "static")
    self.music:setLooping(true)
    local bgSky = BGSprite("stages/school/weebSky", 0, 0, 0.1, 0.1)
    self:add(bgSky)
    bgSky.antialiasing = false

    local repositionShit = -200

    local bgSchool = BGSprite("stages/school/weebSchool", repositionShit, 0, 0.6, 0.9)
    self:add(bgSchool)
    bgSchool.antialiasing = false

    local bgStreet = BGSprite("stages/school/weebStreet", repositionShit, 0, 0.95, 0.95)
    self:add(bgStreet)
    bgStreet.antialiasing = false

    local widShit = math.floor(bgSky.width * PlayState.daPixelZoom)

    local fgTrees = BGSprite("stages/school/weebTreesBack", repositionShit + 170, 130, 0.9, 0.9)
    fgTrees:setGraphicSize(widShit * 0.8)
    self:add(fgTrees)
    fgTrees.antialiasing = false

    local bgTrees = Sprite(repositionShit - 380, -800)
    bgTrees:setFrames(Paths.getAtlas("stages/school/weebTrees", "assets/images/png/stages/school/weebTrees.txt"))
    bgTrees:addByIndices("treeLoop", "trees", {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19}, 12)
    bgTrees:play("treeLoop")
    bgTrees.scrollFactor = {x = 0.85, y = 0.85}
    bgTrees.camera = PlayState.camGame
    self:add(bgTrees)
    bgTrees.antialiasing = false

    local treeLeaves = BGSprite("stages/school/petals", repositionShit, -40, 0.85, 0.85, {"PETALS ALL"}, true)
    treeLeaves:setGraphicSize(widShit)
    self:add(treeLeaves)
    treeLeaves.antialiasing = false

    bgSky:setGraphicSize(widShit)
    bgSchool:setGraphicSize(widShit)
    bgStreet:setGraphicSize(widShit)
    bgTrees:setGraphicSize(math.floor(widShit * 1.4))

    self.bgGirls = BackgroundGirls(-100, 190)
    self.bgGirls.scrolFactor = {x = 0.9, y = 0.9}
    self:add(self.bgGirls)

    self:setDefaultGF("gf-pixel")

    if PlayState.isStoryMode and not PlayState.seenCutscene then
        if PlayState.songName == "senpai" then
            self.music:play()
        elseif PlayState.songName == "roses" then 
            Sound.play(Paths.sound("assets/sounds/ANGRY.ogg"))
            Sound.play(Paths.sound("assets/sounds/ANGRY_TEXT_BOX.ogg"))
        end
        self:initDoof()
        PlayState.startCallback = self.schoolIntro
    end
end

function Stage:initDoof()
    local file = "assets/data/" .. PlayState.songName .. "/" .. PlayState.songName .. "Dialogue.txt"
    -- if file exists, then continie, else start PlayState.startCountdown() and return
    if not love.filesystem.getInfo(file) then
        print("No dialogue file found for " .. PlayState.songName .. " at " .. file)
        PlayState:startCountdown()
        return
    end

    self.doof = DialogueBox(false, CoolUtil.coolTextFile(file))
    self.doof.camera = PlayState.camHUD
    self.doof.scrollFactor = {x = 0, y = 0}
    self.doof.finishThing = PlayState.startCountdown
    self.doof.nextDialogueThing = PlayState.startNextDialogue
    self.doof.skipDialogueThing = PlayState.skipDialogue 
    self.doof.antialiasing = false
end

Stage.doStartTimer = nil

function Stage:schoolIntro()
    PlayState.inCutscene = true
    self.black = Sprite(-100, -100)
    self.black:makeGraphic(push:getWidth()*2, push:getHeight()*2, hexToColor(0x00000000))
    self.black.color = hexToColor(0x00000000)
    
    self.black.scrollFactor = {x = 0, y = 0}

    self:add(self.black)

    function self.doStartTimer()
        Timer.after(
            0.3, function()
                self.black.alpha = self.black.alpha - 0.15

                if self.black.alpha > 0 then
                    -- call startTimer 
                    self.doStartTimer()
                else
                    if self.doof then
                        self:add(self.doof)
                    else
                        PlayState:startCountdown()
                    end
                end
            end
        )
    end
    self.doStartTimer()
end

function Stage:beatHit()
    if self.bgGirls then self.bgGirls:dance() end
end

function Stage:eventCalled(eventName, v1, v2, fv1, fv2, strumTime)
    if eventName == "BG Freaks Expression" then
        if self.bgGirls then self.bgGirls:swapDanceType() end
    end
end

return Stage