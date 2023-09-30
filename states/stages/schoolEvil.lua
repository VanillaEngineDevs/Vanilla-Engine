local Stage = BaseStage:extend()

Stage.bgGhouls = nil
Stage.doof = nil
Stage.music = nil
Stage.senpaiEvil = nil

function Stage:create()
    self.music = love.audio.newSource("assets/music/LunchboxScary.ogg", "static")
    self.music:setLooping(true)
    local posX, posY = 875, 1050
    bg = BGSprite("stages/school/animatedEvilSchool", -posX, -posY, 0.8, 0.9, {"background 2"}, true)
    bg.scale = {x = PlayState.daPixelZoom, y = PlayState.daPixelZoom}
    self:add(bg)
    bg.antialiasing = false

    self:setDefaultGF("gf-pixel")

    if PlayState.isStoryMode and not PlayState.seenCutscene then
        self.music:play()
        self:initDoof()
        PlayState.startCallback = self.schoolIntro
    end
end

function Stage:beatHit()
    if self.bgGirls then self.bgGirls:dance() end
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

function Stage:eventPushed(event)
    if event.event == "Trigger BG Ghouls" then
        self.bgGhouls = BGSprite("stages/school/bgGhouls", -100, 190, 0.9, 0.9, {"BG freaks glitch instance"}, false)
        self.bgGhouls:setGraphicSize(math.floor(self.bgGhouls.width * PlayState.daPixelZoom))
        self.bgGhouls.visible = false
        self.bgGhouls.antialiasing = false
        self.bgGhouls.callback = function(self, name)
            if name == "BG freaks glitch instance" then
                self.visible = false
            end
        end
        self:addBehindGF(self.bgGhouls)
    end
end

function Stage:eventCalled(eventName, v1, v2, fv1, fv2, strumTime)
    if eventName == "Trigger BG Ghouls" then
        self.bgGhouls:dance(true)
        self.bgGhouls.visible = true
    end
end

function Stage:schoolIntro()
    PlayState.inCutscene = true
    local red = Sprite(-100, -100)
    red:makeGraphic(push:getWidth()*2, push:getHeight()*2, hexToColor(0xFFff1b31))
    red.color = hexToColor(0xFFff1b31)
    self:add(red)

    self.senpaiEvil = Sprite()
    self.senpaiEvil:setFrames(Paths.getAtlas("pixel/senpaiCrazy", "assets/images/png/pixel/senpaiCrazy.xml"))
    self.senpaiEvil:addByPrefix("idle", "Senpai Pre Explosion", 24, false)
    self.senpaiEvil:setGraphicSize(math.floor(self.senpaiEvil.width * 6))
    self.senpaiEvil:updateHitbox()
    self.senpaiEvil:screenCenter()
    self.senpaiEvil.x = self.senpaiEvil.x + 300
    self.senpaiEvil:play("idle")
    self.senpaiEvil.animPaused = true
    self.senpaiEvil.antialiasing = false
    self:add(PlayState.camGame)
    PlayState.camHUD.visible = false

    self.fade = Sprite(-100, -100)
    self.fade:makeGraphic(push:getWidth()*2, push:getHeight()*2, hexToColor(0xFFFFFFFF))
    self.fade.color = hexToColor(0xFFFFFFFF)
    self.fade.alpha = 0

    Timer.after(2.1, function()
        if self.doof then
            self:add(self.senpaiEvil)
            self:add(self.fade)
            self.senpaiEvil.alpha = 0
            
            function self.doStartTimer()
                Timer.after(
                    0.3, function()
                        self.senpaiEvil.alpha = self.senpaiEvil.alpha + 0.15
        
                        if self.senpaiEvil.alpha < 1 then
                            -- call startTimer 
                            self.doStartTimer()
                        else
                            --[[ if self.doof then
                                self:add(self.doof)
                            else
                                PlayState:startCountdown()
                            end ]]
                            self.senpaiEvil.animPaused = false
                            self.senpaiEvil:play("idle")
                            Sound.play(Paths.sound("assets/sounds/week6/Senpai_Dies.ogg"))
                            Timer.after(7.5, function()
                                --[[ PlayState.camGame:fade(hexToColor(0xFFff1b31), 0.01, true, function()
                                    self.senpaiEvil.alpha = 0
                                    red.alpha = 0
                                    self:add(self.doof)
                                    PlayState.camHUD.visible = true
                                end) ]]
                                Timer.tween(0.01, self.fade, {alpha = 0}, "linear", function()
                                    self.senpaiEvil.alpha = 0
                                    red.alpha = 0
                                    self:add(self.doof)
                                    PlayState.camHUD.visible = true
                                end)
                            end)
                            Timer.after(3.2, function()
                                Timer.tween(1.6, self.fade, {alpha = 1}, "linear")
                            end)
                            
                        end
                    end
                )
            end
            self.doStartTimer()
        end
    end)
end

return Stage