---@class TitleState : MusicBeatState
local TitleState = MusicBeatState:extend()
TitleState.initialized = false
TitleState.skippedIntro = true

function TitleState:create()
    self.blackScreen = nil
    self.credGroup = Group()
    self.textGroup = Group()
    self.ngSpr = nil

    self.curWacky = {}
    self.lastBeat = 0
    self.overlay = nil
    self.danceLeft = false

    self:startIntro()

    MusicBeatState.create(self)
end

---@param dt number
function TitleState:update(dt)
    MusicBeatState.update(self, dt)

    Conductor:update(Game.sound.music:tell() * 1000)
end

function TitleState:startIntro()
    if not TitleState.initialized or Game.sound.music == nil then 
        self:playMenuMusic() 
    end
    self.gfDance = Sprite(Game.width * 0.4, Game.height * 0.07)
	self.gfDance:setFrames(Paths.getSparrowAtlas("gfDanceTitle"))
	self.gfDance:addAnimByIndices("danceLeft", "gfDance", {
		30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14
	}, nil, 24, false)
	self.gfDance:addAnimByIndices("danceRight", "gfDance", {
		15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29
	}, nil, 24, false)
	self.gfDance:play("danceRight")

	self.logoBl = Sprite(-150, -100)
	self.logoBl:setFrames(Paths.getSparrowAtlas("logoBumpin"))
	self.logoBl:addAnimByPrefix("bump", "logo bumpin", 24, false)
	self.logoBl:play("bump")
	self.logoBl:updateHitbox()

    self:add(self.logoBl)
    self:add(self.gfDance)

    self.titleText = Sprite(100, Game.height * 0.8)
    self.titleText:setFrames(Paths.getSparrowAtlas("titleEnter"))
    self.titleText:addAnimByPrefix("idle", "Press Enter to Begin", 24)
    self.titleText:addAnimByPrefix("press", "ENTER PRESSED", 24)
    self.titleText:play("idle")
    self.titleText:updateHitbox()

    self:add(self.titleText)
end

function TitleState:playMenuMusic()
    FunkinSound:playMusic("freakyMenu", {
        startingVolume = 0,
        overrideExisting = true,
        restartTrack = true
    })
	Game.sound.music:fade(4, 0, 1)
end

function TitleState:beatHit()
    if not MusicBeatState.beatHit(self) then return false end

    if TitleState.skippedIntro  then
        self.logoBl:play("bump", true)

        self.danceLeft = not self.danceLeft

        if self.danceLeft then
            self.gfDance:play("danceRight")
        else
            self.gfDance:play("danceLeft")
        end
    end
end

return TitleState