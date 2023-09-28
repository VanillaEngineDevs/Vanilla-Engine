local StoryMenuState = MusicBeatState:extend()

local MenuItem = require "objects.MenuItem"
local MenuCharacter = require "objects.MenuCharacter"

StoryMenuState.scoreText = ""
StoryMenuState.lastDifficultyName = ""
StoryMenuState.curDifficulty = 2
StoryMenuState.txtWeekTitle = ""
StoryMenuState.bgSprite = nil
StoryMenuState.curWeek = 1
StoryMenuState.txtTracklist = ""
StoryMenuState.grpWeekText = nil
StoryMenuState.grpWeekCharacters = nil

StoryMenuState.grpLocks = nil

StoryMenuState.difficultySelectors = nil
StoryMenuState.sprDifficulty = nil
StoryMenuState.leftArrow = nil
StoryMenuState.rightArrow = nil

StoryMenuState.loadedWeeks = {}

StoryMenuState.selectedWeek = false
StoryMenuState.stopspamming = false

StoryMenuState.movedBack = false
StoryMenuState.selectedWeek = false

StoryMenuState.tweenDifficulty = nil

StoryMenuState.intendedScore = 0
StoryMenuState.lerpScore = 0

-- Simplicity
StoryMenuState.members = {}
function StoryMenuState:add(member)
    table.insert(self.members, member)
end

function StoryMenuState:remove(member)
    for i, member in ipairs(self.members) do
        if member == member then
            table.remove(self.members, i)
            return
        end
    end
end

function StoryMenuState:insert(position, member)
    table.insert(self.members, position, member)
end

function StoryMenuState:clear()
    self.members = {}
end
--

function StoryMenuState:enter()
    Paths.preloadDirectoryImages("menu/menucharacters")
    Paths.preloadDirectoryImages("menu/storymenu")
    Paths.preloadDirectoryImages("menu/menubackgrounds")
    Paths.preloadDirectoryImages("menu/menudifficulties")

    self.loadedWeeks = {}
    WeekData:reloadWeekFiles()

    PlayState.isStoryMode = true

    if self.curWeek > #self.loadedWeeks then
        self.curWeek = 1
    end

    self.scoreText = Text(10, 10, 0, "SCORE: 49324858", Paths.font("assets/fonts/vcr.ttf", 36))
    self.scoreText.alignment = "left"
    self.txtWeekTitle = Text(push:getWidth() * 0.7, 10, 0, "", Paths.font("assets/fonts/vcr.ttf", 32))
    self.txtWeekTitle.alignment = "left"
    self.txtWeekTitle.alpha = 0.7

    local ui_tex = Paths.getSparrowAtlas("menu/campaign_menu_ui_assets", love.filesystem.read("assets/images/png/menu/campaign_menu_ui_assets.xml"))
    local bgYellow = Sprite(0, 56)
    bgYellow:makeGraphic(push:getWidth(), 386, 0xFFF9CF51)
    self.bgSprite = Sprite(0, 56)

    self.grpWeekText = Group()
    self:add(self.grpWeekText)

    local blackBarThingie = Sprite()
    blackBarThingie:makeGraphic(push:getWidth(), 56, 0x00000000)

    self.grpWeekCharacters = Group()

    self.grpLocks = Group()
    self:add(self.grpLocks)

    local num = 0
    for i = 1, #WeekData.weeksList do
        local weekFile = WeekData.weeksLoaded[WeekData.weeksList[i]]
        local isLocked = self:weekIsLocked(WeekData.weeksList[i])

        if not isLocked or not weekFile.hiddenUntilUnlocked then
            table.insert(self.loadedWeeks, weekFile)
            local weekThing = MenuItem(0, self.bgSprite.y + 396, WeekData.weeksList[i])
            weekThing.y = weekThing.y + ((weekThing.height + 20) * num)
            weekThing.targetY = num
            self.grpWeekText:add(weekThing)
            weekThing:screenCenter("X")

            if isLocked then
                local lock = Sprite(weekThing.width + 10 + weekThing.x, 0)
                lock:setFrames(ui_tex)
                lock:addByPrefix("lock", "lock")
                lock:play("lock")
                lock.ID = i-1
                self.grpLocks:add(lock)
            end
            num = num + 1
        end
    end

    local charArray = self.loadedWeeks[1].weekCharacters
    for char = 1, 3 do
        local weekCharacterThing = MenuCharacter((push:getWidth() * 0.25) * (char) - 150, charArray[char])
        weekCharacterThing.y = weekCharacterThing.y + 70
        self.grpWeekCharacters:add(weekCharacterThing) 
    end

    self.difficultySelectors = Group()
    self:add(self.difficultySelectors)
    
    self.leftArrow = Sprite(self.grpWeekText.members[1].x + self.grpWeekText.members[1].width + 10, self.grpWeekText.members[1].y + 10)
    self.leftArrow:setFrames(ui_tex)
    self.leftArrow:addByPrefix("idle", "arrow left")
    self.leftArrow:addByPrefix("press", "arrow push left")
    self.leftArrow:play("idle")
    self.difficultySelectors:add(self.leftArrow)

    Difficulty:resetList()
    if self.lastDifficultyName == "" then
        self.lastDifficultyName = Difficulty:getDefault()
    end
    self.curDifficulty = math.round(math.max(0, table.indexOf(Difficulty.defaultList, self.lastDifficultyName) or 0))
    self.sprDifficulty = Sprite(0, self.leftArrow.y)
    self.difficultySelectors:add(self.sprDifficulty)

    self.rightArrow = Sprite(self.leftArrow.x + 376, self.leftArrow.y)
    self.rightArrow:setFrames(ui_tex)
    self.rightArrow:addByPrefix("idle", "arrow right")
    self.rightArrow:addByPrefix("press", "arrow push right")
    self.rightArrow:play("idle")
    self.difficultySelectors:add(self.rightArrow)

    self:add(bgYellow)
    self:add(self.bgSprite)
    self:add(blackBarThingie)
    self:add(self.grpWeekCharacters)

    local tracksSprite = Sprite(push:getWidth() * 0.07, self.bgSprite.y + 425)
    tracksSprite:load("menu/Menu_Tracks")
    self:add(tracksSprite)

    self.txtTracklist = Text(push:getWidth() * 0.05, tracksSprite.y + 60, 0, "", Paths.font("assets/fonts/vcr.ttf", 32))
    self.txtTracklist.color = hexToColor(0xFFe55777)

    self:changeWeek()
    self:changeDifficulty()

    self.super.enter(self)

    self:add(self.txtTracklist)
    self:add(self.scoreText)
    self:add(self.txtWeekTitle)
end

function StoryMenuState:changeWeek(change)
    local change = change or 0

    self.curWeek = self.curWeek + change

    if self.curWeek > #self.loadedWeeks then
        self.curWeek = 1
    elseif self.curWeek < 1 then
        self.curWeek = #self.loadedWeeks
    end

    local leWeek = self.loadedWeeks[self.curWeek]
    
    local leName = leWeek.storyName

    self.txtWeekTitle.text = leName
    self.txtWeekTitle.x = push:getWidth() - (self.txtWeekTitle.font:getWidth(self.txtWeekTitle.text) + 10)

    local bullshit = 0
    local unlocked = not self:weekIsLocked(leWeek.fileName)
    for i, item in ipairs(self.grpWeekText.members) do
        item.targetY = bullshit - self.curWeek
        if item.targetY+1 == 0 and unlocked then
            item.alpha = 1
        else
            item.alpha = 0.6
        end
        bullshit = bullshit + 1
    end
    local assetName = leWeek.weekBackground
    if not assetName or #assetName < 1 then
        self.bgSprite.visible = false
    else
        self.bgSprite:load("menu/menubackgrounds/menu_" .. assetName)
    end
    PlayState.storyWeek = self.curWeek

    Difficulty:loadFromWeek()
    self.difficultySelectors.visible = unlocked

    if Difficulty.list[Difficulty:getDefault()] then
        self.curDifficulty = math.round(math.max(0, table.indexOf(Difficulty.list, Difficulty:getDefault()) or 0))
    else
        self.curDifficulty = 1
    end

    local newPos = table.indexOf(Difficulty.list, self.lastDifficultyName)
    if newPos > -1 then
        self.curDifficulty = newPos
    end
    self:updateText()
end

function StoryMenuState:selectWeek()
    if not self:weekIsLocked(self.loadedWeeks[self.curWeek].fileName) then
        local songArray = {}
        local leWeek = self.loadedWeeks[self.curWeek].songs
        for i = 1, #leWeek do
            table.insert(songArray, leWeek[i][1])
        end

        TryExcept(
            function()
                PlayState.storyPlaylist = songArray
                PlayState.isStoryMode = true
                self.selectedWeek = true

                local diffic = Difficulty:getFilePath(self.curDifficulty)
                if not diffic then diffic = "" end
                PlayState.storyDifficulty = self.curDifficulty
                print(diffic, PlayState.storyPlaylist[1]:lower() .. diffic)

                -- i am... NOT sorry!
                PlayState.SONG = Song:loadFromJson(PlayState.storyPlaylist[1]:lower() .. diffic, PlayState.storyPlaylist[1]:lower())
                PlayState.campaignScore = 0
                PlayState.campaignMisses = 0
            end,
            function(err)
                print("Error! " .. err)
                return
            end
        )

        if not self.stopspamming then
            self.grpWeekText.members[self.curWeek]:startFlashing()

            for i, char in ipairs(self.grpWeekCharacters.members) do
                if char.character ~= "" and char.hasConfirmAnimation then
                    char:play("confirm")
                end
            end
            self.stopspamming = true
        end

        Timer.after(1, function() 
            MusicBeatState:fadeOut(0.3, function()
                MusicBeatState:switchState(PlayState)
            end)
        end)
    else
        -- bleh
    end
end

function StoryMenuState:changeDifficulty(change)
    local change = change or 0

    self.curDifficulty = self.curDifficulty + change

    if self.curDifficulty > #Difficulty.list then
        self.curDifficulty = 1
    elseif self.curDifficulty < 1 then
        self.curDifficulty = #Difficulty.list
    end

    local diff = Difficulty:getString(self.curDifficulty)
    local newImage = Paths.image("menu/menudifficulties/" .. Paths.formatToSongPath(diff))

    if self.sprDifficulty.graphic ~= newImage then
        self.sprDifficulty:load("menu/menudifficulties/" .. Paths.formatToSongPath(diff))
        self.sprDifficulty.x = self.leftArrow.x + 60
        self.sprDifficulty.x = self.sprDifficulty.x + (308 - self.sprDifficulty.width) / 3
        self.sprDifficulty.alpha = 0
        self.sprDifficulty.y = self.leftArrow.y - 15

        if self.tweenDifficulty then
            Timer.cancel(self.tweenDifficulty)
        end

        self.tweenDifficulty = Timer.tween(0.07, self.sprDifficulty, {y = self.leftArrow.y + 15, alpha = 1}, "linear", function() self.tweenDifficulty = nil end)
    end

    self.lastDifficultyName = diff
end

function StoryMenuState:weekIsLocked(name)
    local leWeek = WeekData.weeksLoaded[name]
    return (not leWeek.startUnlocked and #leWeek.weekbefore > 0 and (not self.weekComplated[leWeek.weekBefore] or not self.weekCompleted[leWeek.weekBefore])) 
end

function StoryMenuState:update(dt)
    self.lerpScore = math.floor(math.lerp(self.lerpScore, self.intendedScore, math.bound(dt * 30, 0, 1)))
    if math.abs(self.intendedScore - self.lerpScore) < 10 then
        self.lerpScore = self.intendedScore
    end
    self.scoreText.text = "WEEK SCORE: " .. self.lerpScore
    Conductor.songPosition = Conductor.songPosition + 1000 * dt

    self.super.update(self, dt)

    if not self.movedBack and not self.selectedWeek then
        local upP = input:pressed("m_up")
        local downP = input:pressed("m_down")
        local leftP = input:pressed("m_left")
        local rightP = input:pressed("m_right")

        if upP then
            self:changeWeek(-1)
        elseif downP then
            self:changeWeek(1)
        end

        if leftP then
            self:changeDifficulty(-1)
        elseif rightP then
            self:changeDifficulty(1)
        elseif upP or downP then
            self:changeWeek()
        end
        
        if input:pressed("m_confirm") then
            self:selectWeek()
        end
    end

    for i, member in ipairs(self.members) do
        if member.update then 
            member:update(dt) 
        end
    end

    for i, locks in ipairs(self.grpLocks.members) do
        lock.y = self.grpWeekText.members[locks.ID].y
        lock.visible = (lock.y > push:getWidth()/2)
    end
end

function StoryMenuState:updateText()
    local weekArray = self.loadedWeeks[self.curWeek].weekCharacters
    for i = 1, #weekArray do
        self.grpWeekCharacters.members[i]:changeCharacter(weekArray[i])
    end

    local leWeek = self.loadedWeeks[self.curWeek]
    local stringThing = {}
    for i = 1, #leWeek.songs do
        table.insert(stringThing, leWeek.songs[i][1])
    end

    self.txtTracklist.text = ""
    for i = 1, #stringThing do
        self.txtTracklist.text = self.txtTracklist.text .. stringThing[i] .. "\n"
    end
    self.txtTracklist.text = self.txtTracklist.text:upper()
    

    self.txtTracklist:screenCenter("X")
    self.txtTracklist.x = self.txtTracklist.x - push:getWidth() * 0.35
end

function StoryMenuState:draw()
    for i, member in ipairs(self.members) do
        if member.draw then 
            member:draw() 
        end
    end
end

return StoryMenuState