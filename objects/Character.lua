--[[
-- reference

typedef CharacterFile = {
	var animations:Array<AnimArray>;
	var image:String;
	var scale:Float;
	var sing_duration:Float;
	var healthicon:String;

	var position:Array<Float>;
	var camera_position:Array<Float>;

	var flip_x:Bool;
	var no_antialiasing:Bool;
	var healthbar_colors:Array<Int>;
}

typedef AnimArray = {
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}
]]

local Character = Sprite:extend()

Character.DEFAULT_CHARACTER = "bf"

Character.animOffsets = {}
Character.debugMode = false

Character.isPlayer = false
Character.curCharacter = Character.DEFAULT_CHARACTER

Character.colorTween = nil
Character.holdTimer = 0
Character.heyTimer = 0
Character.specialAnim = false
Character.animationNotes = {}
Character.stunned = false
Character.singDuration = 4
Character.idleSuffix = ""
Character.danceIdle = false
Character.skipDance = false

Character.healthicon = "face"
Character.animationsArray = {}

Character.positionArray = {0, 0}
Character.cameraPosition = {0, 0}

Character.hasMissAnimations = false

Character.imageFile = "" 
Character.jsonScale = 1
Character.noAntialiasing = false
Character.originalFlipX = false
Character.healtHColorArray = {255, 0, 0}
Character.danced = fals

function Character:new(x, y, character, isPlayer)
    local character = character or Character.DEFAULT_CHARACTER
    local player = (player == nil) and false or player

    self.super.new(self, x, y)

    self.animOffsets = {}
    self.curCharacter = character
    self.isPlayer = isPlayer
    local library, rawJson = nil, nil
    
    local characterPath = character .. ".json"

    if love.filesystem.getInfo("assets/characters/" .. characterPath) then
        rawJson = json.decode(love.filesystem.read("assets/characters/" .. characterPath))
    else
        rawJson = json.decode(love.filesystem.read("assets/characters/bf.json"))
    end

    self.imageFile = rawJson.image
    self:setFrames(Paths.getAtlas(self.imageFile, "assets/images/png/" .. self.imageFile))
    if json.scale ~= 1 then
        self.jsonScale = rawJson.scale
        self:setGraphicSize(math.floor(self.width * self.jsonScale))
        self:updateHitbox()
    end

    self.x, self.y = self.x + rawJson.position[1], self.y + rawJson.position[2]
    self.cameraPosition = {rawJson.camera_position[1], rawJson.camera_position[2]}
    self.flipX = (rawJson.flip_x == true)

    self.noAntialiasing = (rawJson.no_antialiasing == true)
    self.antialiasing = not self.noAntialiasing

    self.animationsArray = rawJson.animations

    self.healthColorArray = rawJson.healthbar_colors

    if self.animationsArray ~= nil and #self.animationsArray > 0 then
        for i, anim in ipairs(self.animationsArray) do
            local animAnim = anim.anim
            local animName = anim.name
            local animFps = anim.fps
            local animLoop = anim.loop
            local animIndices = anim.indices
            if animIndices ~= nil and #animIndices > 0 then
                self:addByIndices(animAnim, animName, animIndices, animFps, animLoop)
            else
                self:addByPrefix(animAnim, animName, animFps, animLoop)
            end

            if anim.offsets ~= nil and #anim.offsets > 1 then
                self:addOffset(anim.anim, anim.offsets[1], anim.offsets[2])
            end
        end
    else
        self:quickAnimAdd("idle", "BF idle dance")
    end

    self.originalFlipX = self.flipX

    if self.animOffsets["singLEFTmiss"] or self.animOffsets["singRIGHTmiss"] or self.animOffsets["singUPmiss"] or self.animOffsets["singDOWNmiss"] then
        self.hasMissAnimations = true
    end
    self:recalculateDanceIdle()

    if self.isPlayer then
        self.flipX = not self.flipX
    end

    self:dance()

    if self.curCharacter == "pico-speaker" == true then
        self.skipDance = true
        self:loadMappedAnims()
        self:playAnim("shoot1")
    end

    return self
end

function Character:loadMappedAnims()
    local noteData = Song:loadFromJson("picospeaker", Paths.formatToSongPath(PlayState.SONG.song)).notes
    for _, section in ipairs(noteData) do
        for _, songNotes in ipairs(section.sectionNotes) do
            table.insert(self.animationNotes, songNotes)
        end
    end
    -- sort by time
    table.sort(self.animationNotes, function(a, b) return a[1] < b[1] end)
end

function Character:update(dt)
    if not self.debugMode and self.curAnim ~= nil then
        if self.heyTimer > 0 then
            self.heyTimer = self.heyTimer - dt * PlayState.playbackRate
            if self.heyTimer <= 0 then
                if self.specialAnim and self.curAnim.name == "hey" or self.curAnim.name == "cheer" then
                    self.specialAnim = false
                    self:dance()
                end
                self.heyTimer = 0
            end
        elseif self.specialAnim and self.animFinished then
            self.specialAnim = false
            self:dance()
        elseif self.curAnim.name:endsWith("miss") and self.animFinished then
            self:dance()
        end

        if self.curCharacter == "pico-speaker" then
            if #self.animationNotes > 0 and Conductor.songPosition > self.animationNotes[1][1] then
                local noteData = 1
                if self.animationNotes[1][2] > 2 then noteData = 3 end
                noteData = noteData + love.math.random(0, 1)
                self:playAnim("shoot" .. noteData, true)
                table.remove(self.animationNotes, 1)
            end
            if self.animFinished then self:playAnim(self.curAnim.name, false, false, #self.curAnim.frames-2) end
        end

        if self.curAnim.name:startsWith("sing") then
            self.holdTimer = self.holdTimer + dt
        elseif self.isPlayer then
            self.holdTimer = 0
        end

        if not self.isPlayer and self.holdTimer >= Conductor.stepCrochet * (0.0011 / PlayState.playbackRate) * self.singDuration then
            self.holdTimer = 0
            self:dance()
        end

        if self.animFinished and self.animations[self.curAnim.name .. "-loop"] then
            self:playAnim(self.curAnim.name .. "-loop")
        end
    end
    self.super.update(self, dt)
end

function Character:dance()
    if not self.debugMode and not self.skipDance and not self.specialAnim then
        if self.danceIdle then
            self.danced = not self.danced

            if self.danced then
                self:playAnim("danceRight" .. self.idleSuffix)
            else
                self:playAnim("danceLeft" .. self.idleSuffix)
            end
        elseif self.animations["idle" .. self.idleSuffix] then
            self:playAnim("idle" .. self.idleSuffix, true)
        end
    end
end 

function Character:playAnim(animName, force, frame)
    self.specialAnim = false
    self:play(animName, force, frame)

    local daOffset = self.animOffsets[animName]
    if daOffset then
        self.offset.x = daOffset[1]
        self.offset.y = daOffset[2]
    else
        self.offset.x = 0
        self.offset.y = 0
    end
    
    if self.curCharacter:startsWith("gf") then
        if animName == "singLEFT" then
            self.danced = true
        elseif animName == "singRIGHT" then
            self.danced = false
        end

        if animName == "singUP" or animName == "singDOWN" then
            self.danced = not self.danced
        end
    end
end

Character.danceEveryNumBeats = 2
Character.settingCharacterUp = true

function Character:recalculateDanceIdle()
    local lastDanceIdle = self.danceIdle
    self.danceIdle = (self.animations["danceLeft" .. self.idleSuffix] ~= nil) and (self.animations["danceRight" .. self.idleSuffix] ~= nil)

    if self.settingCharacterUp then
        self.danceEveryNumBeats = (self.danceIdle) and 1 or 2
    elseif lastDanceIdle ~= self.danceIdle then
        local calc = self.danceEveryNumBeats
        if self.danceIdle then
            self.calc = self.calc / 2
        else
            self.calc = self.calc * 2
        end

        self.danceEveryNumBeats = math.round(math.max(calc, 1))
    end

    self.settingCharacterUp = false
end

function Character:addOffset(name, x, y)
    self.animOffsets[name] = {x, y}
end

function Character:quickAnimAdd(name, anim)
    self:addByPrefix(name, anim, 24, false)
end

return Character