local diffToFile = {
    ["easy"] = "difEasy",
    ["normal"] = "difNormal",
    ["hard"] = "difHard",
    ["erect"] = "difErect",
    ["nightmare"] = "difNightmare"
}
local variationToFile = {
    ["NORMAL"] = "GOOD"
}
local diffName, songName, scores, scoreData, artist
_resultsCache = {
    --[[ ratingsPopin = love.graphics.newImage(graphics.imagePath("resultsScreen/ratingsPopin")), ]]
}
local resultsVariation = "NORMAL"
local resultsGF, resultsPLAYER, soundSystem
local letterOrder = "AaBbCcDdEeFfGgHhiIJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789:1234567890"
local resultsFont = {quads={}, img=nil}

local topBarBlack, resultsAnim, ratingsPopin, scorePopin
local textTween

local curDiff

local thePosEverX = 0
local thePosEverY = {0}

local resultsMusicSecondary

local function printResultsFont(x, y, text, scale)
    local text = text or "UNDEFINED"
    -- remove anything that isn't in letterOrder. BUT KEEP SPACES
    text = text:gsub("[^" .. letterOrder .. " ]", "")
    for i = 1, #text do
        local char = text:sub(i, i)
        local index = letterOrder:find(char)
        if index then
            love.graphics.draw(resultsFont.img, resultsFont.quads[index], x + (i - 1) * 37 * scale, y, 0, scale, scale)
        end
    end
end

local scoreNumbers = {
    sprites =  {},
    score = 0,
    visible = false,
    animateNumbers = function(self)
        local paddedStr = string.format("%010d", self.score)
        -- all 0's before the first non-zero number are replaced with underscores
        for i = 1, #paddedStr do
            if paddedStr:sub(i, i) == "0" then
                paddedStr = paddedStr:sub(1, i - 1) .. "_" .. paddedStr:sub(i + 1)
            else
                break
            end
        end

        for i = 1, #paddedStr do
            local char = paddedStr:sub(i, i)
            if char == "_" then
                self.sprites[i]:animate("DISABLED", false)
                if i == #paddedStr then
                    self.sprites[i]:animate("0", false)
                end
            else
                self.sprites[i].visible = true
                self.sprites[i]:animate(char, false)
            end
        end
    end
} 
-- 10 numbers max, AKA 9999999999 max score to be displayed
local tallies = {}
local resultsMusic

local dontLoopPlaySecondLoop = false

local function calculateRank(scoreData)
    if scoreData == nil or scoreData.totalNotes == 0 then
        return nil
    end

    local isPerfectGold = scoreData.sickCount == scoreData.totalNotes
    if isPerfectGold then
        return "PERFECT_GOLD"
    end

    local grade = (scoreData.sickCount + scoreData.goodCount) / scoreData.totalNotes
    --local clear = scoreData.totalNotesHit / scoreData.totalNotes
    
    if grade == CONSTANTS.RANK_PERFECT_THRESHOLD then
        return "PERFECT"
    elseif grade >= CONSTANTS.RANK_EXCELLENT_THRESHOLD then
        return "EXCELLENT"
    elseif grade >= CONSTANTS.RANK_GREAT_THRESHOLD then
        return "GREAT"
    elseif grade >= CONSTANTS.RANK_GOOD_THRESHOLD then
        return "GOOD"
    else
        return "SHIT"
    end
end

local function getMusicDelay(rank)
    if rank == "PERFECT_GOLD" or rank == "PERFECT" then
        return 95 / 24
    elseif rank == "EXCELLENT" then
        return 0
    elseif rank == "GREAT" then
        return 5 / 24
    elseif rank == "GOOD" then
        return 3 / 24
    elseif rank == "SHIT" then
        return 2 / 24
    end

    return 3.5
end

return {
    enter = function(self, last, scoreData_)
        music:stop()

        soundSystem = love.filesystem.load("sprites/resultsScreen/soundSystem.lua")()
        soundSystem.visible = false
        soundSystem.x, soundSystem.y = 425, 300

       --[[  resultsGF = love.filesystem.load("sprites/resultsScreen/resultGirlfriend" .. variationToFile[resultsVariation] .. ".lua")()
        resultsGF.visible = false
        resultsGF.x, resultsGF.y = 760, 500 ]]
        --[[ 
        resultsPLAYER = love.filesystem.load("sprites/resultsScreen/resultBoyfriend" .. variationToFile[resultsVariation] .. ".lua")()
        resultsPLAYER.visible = false
        resultsPLAYER.x, resultsPLAYER.y = 965, 265 ]]

        --[[ resultsMusic = love.audio.newSource("music/results/results" .. resultsVariation .. ".ogg", "stream") ]]
        --[[ resultsMusic:setLooping(true)
        resultsMusic:play() ]]

        resultsFont.quads = {}
        resultsFont.img = love.graphics.newImage(graphics.imagePath("resultsScreen/tardlingSpritesheet"))
        -- 49x62 per quads
        for x = 0, resultsFont.img:getWidth() - 49, 49 do
            table.insert(resultsFont.quads, love.graphics.newQuad(x, 0, 49, 62, resultsFont.img:getDimensions()))
        end
        for y = 62, resultsFont.img:getHeight() - 62, 62 do
            for x = 0, resultsFont.img:getWidth() - 49, 49 do
                table.insert(resultsFont.quads, love.graphics.newQuad(x, y, 49, 62, resultsFont.img:getDimensions()))
            end
        end

        topBarBlack = graphics.newImage(graphics.imagePath("resultsScreen/topBarBlack"))
        topBarBlack.y = -topBarBlack:getHeight()/2
        topBarBlack.x = topBarBlack:getWidth()/2
        Timer.after(0.5, function()
            Timer.tween(
                0.4,
                topBarBlack,
                {
                    y = topBarBlack:getHeight()/2
                },
                "out-quart"
            )
        end)

        resultsAnim = love.filesystem.load("sprites/resultsScreen/resultsAnim.lua")()
        resultsAnim.x = 1280/2 - resultsAnim:getFrameWidth()/2
        resultsAnim.y = resultsAnim:getFrameHeight() + 35
        Timer.after(6/24, function()
            resultsAnim.visible = true
            resultsAnim:animate("idle", false)
        end)

        _resultsCache.ratingsPopin = love.graphics.newImage(graphics.imagePath("resultsScreen/ratingsPopin"))
        _resultsCache.scorePopin = love.graphics.newImage(graphics.imagePath("resultsScreen/scorePopin"))
        _resultsCache.tallieNumber = love.graphics.newImage(graphics.imagePath("resultsScreen/tallieNumber"))
        _resultsCache.scoreDigitalNumbers = love.graphics.newImage(graphics.imagePath("resultsScreen/score-digital-numbers"))

        ratingsPopin = love.filesystem.load("sprites/resultsScreen/ratingsPopin.lua")()
        ratingsPopin.x, ratingsPopin.y = 110, 330
        ratingsPopin.visible = false

        scorePopin = love.filesystem.load("sprites/resultsScreen/scorePopin.lua")()
        scorePopin.x, scorePopin.y = 180, 590
        scorePopin.visible = false

        curDiff = graphics.newImage(graphics.imagePath("resultsScreen/" .. diffToFile[scoreData_.diff]))
        curDiff.x, curDiff.y = 570 + curDiff:getWidth()/2, 160
        thePosEverX = curDiff.x
        thePosEverY = {curDiff.y}

        scoreData = scoreData_
        diffName = scoreData.diff
        songName = scoreData.song
        scores = scoreData.scores
        artist = scoreData.artist

        if not boyfriend then boyfriend = {data={}} end
        if not boyfriend.data.results then 
            boyfriend.data = love.filesystem.load("data/characters/resultsData/boyfriend.lua")()
        end

        scores.totalNotes = scores.sickCount + scores.goodCount + scores.badCount + scores.shitCount + scores.missedCount
        scores.totalNotesHit = scores.sickCount + scores.goodCount + scores.badCount + scores.shitCount
        local rank = calculateRank(scores)

        resultsMusic = love.audio.newSource("music/" .. boyfriend.data.results.music[rank] .. ".ogg", "stream")
        if util.endsWith(boyfriend.data.results.music[rank], "intro") then
            resultsMusic:setLooping(false)
            --resultsMusic:play()
            dontLoopPlaySecondLoop = true
            resultsMusicSecondary = love.audio.newSource("music/" .. boyfriend.data.results.music[rank]:gsub("-intro", "") .. ".ogg", "stream")
            resultsMusicSecondary:setLooping(true)
        else
            resultsMusic:setLooping(true)
            --resultsMusic:play()
        end

        resultsPLAYER = love.filesystem.load("sprites/results/" .. boyfriend.data.results[rank] .. ".lua")()
        if boyfriend.data.results[rank].secondary then
            resultsPLAYER.backSprite = love.filesystem.load("sprites/results/" .. boyfriend.data.results[rank].secondary .. ".lua")()
        end
        
        -- Tallies (Dogshit code ahead)
        for i = 1, 7 do 
            tallies[i] = {sprites={},colour={1, 1, 1},num=0,curNum=0,displayedNums=1,storedX={},flippedSprites={},visibleSprites={},visible=false}
        end

        for i = 1, #tostring(scores.totalNotes) do
            table.insert(tallies[1].sprites, love.filesystem.load("sprites/resultsScreen/tallieNumber.lua")())
            tallies[1].sprites[i]:animate("0", false)
            tallies[1].sprites[i].x = 400 + (i - 1) * 38
            tallies[1].sprites[i].y = 155
            tallies[1].num = scores.totalNotes
            tallies[1].storedX[i] = tallies[1].sprites[i].x

            tallies[1].colour = {1, 1, 1}
        end
        newStoredX = {}
        for i = #tallies[1].sprites, 1, -1 do
            table.insert(newStoredX, tallies[1].storedX[i])
        end
        tallies[1].storedX = newStoredX
        for i = 2, #tallies[1].sprites do
            tallies[1].sprites[i].visible = false
        end

        for i = 1, #tostring(scores.maxCombo) do
            table.insert(tallies[2].sprites, love.filesystem.load("sprites/resultsScreen/tallieNumber.lua")())
            tallies[2].sprites[i]:animate("0", false)
            tallies[2].sprites[i].x = 400 + (i - 1) * 38
            tallies[2].sprites[i].y = 225
            tallies[2].num = scores.maxCombo
            tallies[2].storedX[i] = tallies[2].sprites[i].x

            tallies[2].colour = {1, 1, 1}
        end
        newStoredX = {}
        for i = #tallies[2].sprites, 1, -1 do
            table.insert(newStoredX, tallies[2].storedX[i])
        end
        tallies[2].storedX = newStoredX
        for i = 2, #tallies[2].sprites do
            tallies[2].sprites[i].visible = false
        end

        for i = 1, #tostring(scores.sickCount) do
            table.insert(tallies[3].sprites, love.filesystem.load("sprites/resultsScreen/tallieNumber.lua")())
            tallies[3].sprites[i]:animate("0", false)
            tallies[3].sprites[i].x = 255 + (i - 1) * 38
            tallies[3].sprites[i].y = 285
            tallies[3].num = scores.sickCount
            tallies[3].storedX[i] = tallies[3].sprites[i].x

            tallies[3].colour = {137/255, 229/255, 158/255}
        end
        local newStoredX = {}
        for i = #tallies[3].sprites, 1, -1 do
            table.insert(newStoredX, tallies[3].storedX[i])
        end
        tallies[3].storedX = newStoredX
        for i = 2, #tallies[3].sprites do
            tallies[3].sprites[i].visible = false
        end

        for i = 1, #tostring(scores.goodCount) do
            table.insert(tallies[4].sprites, love.filesystem.load("sprites/resultsScreen/tallieNumber.lua")())
            tallies[4].sprites[i]:animate("0", false)
            tallies[4].sprites[i].x = 235 + (i - 1) * 38
            tallies[4].sprites[i].y = 340
            tallies[4].num = scores.goodCount
            tallies[4].storedX[i] = tallies[4].sprites[i].x

            tallies[4].colour = {137/255, 201/255, 229/255}
        end
        newStoredX = {}
        for i = #tallies[4].sprites, 1, -1 do
            table.insert(newStoredX, tallies[4].storedX[i])
        end
        tallies[4].storedX = newStoredX
        for i = 2, #tallies[4].sprites do
            tallies[4].sprites[i].visible = false
        end

        for i = 1, #tostring(scores.badCount) do
            table.insert(tallies[5].sprites, love.filesystem.load("sprites/resultsScreen/tallieNumber.lua")())
            tallies[5].sprites[i]:animate("0", false)
            tallies[5].sprites[i].x = 210 + (i - 1) * 38
            tallies[5].sprites[i].y = 390
            tallies[5].num = scores.badCount
            tallies[5].storedX[i] = tallies[5].sprites[i].x

            tallies[5].colour = {230/255, 207/255, 138/255}
        end
        newStoredX = {}
        for i = #tallies[5].sprites, 1, -1 do
            table.insert(newStoredX, tallies[5].storedX[i])
        end
        tallies[5].storedX = newStoredX
        for i = 2, #tallies[5].sprites do
            tallies[5].sprites[i].visible = false
        end

        for i = 1, #tostring(scores.shitCount) do
            table.insert(tallies[6].sprites, love.filesystem.load("sprites/resultsScreen/tallieNumber.lua")())
            tallies[6].sprites[i]:animate("0", false)
            tallies[6].sprites[i].x = 235 + (i - 1) * 38
            tallies[6].sprites[i].y = 440
            tallies[6].num = scores.shitCount
            tallies[6].storedX[i] = tallies[6].sprites[i].x

            tallies[6].colour = {230/255, 140/255, 138/255}
        end
        newStoredX = {}
        for i = #tallies[4].sprites, 1, -1 do
            table.insert(newStoredX, tallies[6].storedX[i])
        end
        tallies[6].storedX = newStoredX
        for i = 2, #tallies[6].sprites do
            tallies[6].sprites[i].visible = false
        end

        for i = 1, #tostring(scores.missedCount) do
            table.insert(tallies[7].sprites, love.filesystem.load("sprites/resultsScreen/tallieNumber.lua")())
            tallies[7].sprites[i]:animate("0", false)
            tallies[7].sprites[i].x = 265 + (i - 1) * 38
            tallies[7].sprites[i].y = 500
            tallies[7].num = scores.missedCount
            tallies[7].storedX[i] = tallies[7].sprites[i].x

            tallies[7].colour = {198/255, 138/255, 230/255}
        end
        newStoredX = {}
        for i = #tallies[7].sprites, 1, -1 do
            table.insert(newStoredX, tallies[7].storedX[i])
        end
        tallies[7].storedX = newStoredX
        for i = 2, #tallies[7].sprites do
            tallies[7].sprites[i].visible = false
        end

        scoreNumbers.score = scores.score
        scoreNumbers.visible = false
        scoreNumbers.sprites = {}
        local paddedScoreStr = string.format("%010d", scores.score)
        for i = 1, #paddedScoreStr do
            local char = paddedScoreStr:sub(i, i)
            local num = tonumber(char)
            if num then
                table.insert(scoreNumbers.sprites, love.filesystem.load("sprites/resultsScreen/scoreDigitalNumbers.lua")())
                scoreNumbers.sprites[i]:animate("DISABLED", false)
                scoreNumbers.sprites[i].x = 130 + (i - 1) * (scoreNumbers.sprites[i]:getFrameWidth()-15)
                scoreNumbers.sprites[i].y = 670
            end
        end

        Timer.after(21/24, function()
            ratingsPopin:animate("idle", false, function()
                
            end)
            ratingsPopin.visible = true
        end)

        Timer.after(36 / 24, function()
            scorePopin.visible = true
            scorePopin:animate("idle", false, function()
                
            end)
        end)

        Timer.after(37/24, function()
            scoreNumbers.visible = true
            scoreNumbers:animateNumbers()
        end)

        Timer.after(
            0.4, function()
                soundSystem:animate("idle")
                soundSystem.visible = true
            end
        )

        Timer.after(
            (1/24) * 22, function()
                --[[ resultsGF:animate("idle", false, function()
                    resultsGF:animate("idle", true, nil, false, 10, true)
                end)
                resultsGF.visible = true ]]
            end
        )

        for i = 1, #tallies do
            Timer.after(
                0.3 * i + 1.2, function()
                    tallies[i].visible = true
                    Timer.tween(0.5, tallies[i], {
                        curNum = tallies[i].num
                    }, "out-quart", function()
                        if tallies[i] then
                            tallies[i].curNum = tallies[i].num
                        end
                    end)
                end
            )
        end

        playedMusic = false
        Timer.after(getMusicDelay(rank), function()
            resultsMusic:play()
            playedMusic = true
        end)

        resultsPLAYER.visible = true
        resultsPLAYER:animate("intro", false, function()
            resultsPLAYER:animate("idle", true)
        end)
    end,

    update = function(self, dt)
        resultsPLAYER:update(dt)
        soundSystem:update(dt)

        resultsAnim:update(dt)

        ratingsPopin:update(dt)
        scorePopin:update(dt)

        if dontLoopPlaySecondLoop and not resultsMusic:isPlaying() and playedMusic then
            resultsMusicSecondary:play()
            dontLoopPlaySecondLoop = false
        end

        if thePosEverY[1] == 160 and not textTween then
            thePosEverX = thePosEverX - 5 * dt * 100

            curDiff.y = curDiff.y + 5.5 * dt * 7
            -- get y based on x
            curDiff.x = thePosEverX
        else
            if not textTween then
                curDiff.x = 570 + curDiff:getWidth()/2
                curDiff.y = 160 - 300
                textTween = Timer.after(0.5, function()
                    textTween = Timer.tween(
                        1, thePosEverY, {160}, "out-quart",
                        function()
                            textTween = Timer.after(0.25, function() textTween = nil end)
                            thePosEverY[1] = 160
                        end
                    )
                end)
            end
            curDiff.y = thePosEverY[1]
        end

        if thePosEverX < -1500 then
            thePosEverX = 570 + curDiff:getWidth()/2
            curDiff.y = 160 - 300
            thePosEverY[1] = 160 - 300
        end

        -- update tallies for rating counts making the needed digits visible when needed
        for i = 1, #tallies do
            if math.floor(tallies[i].curNum) > tallies[i].num then
                tallies[i].curNum = tallies[i].num
            end
            local flipped = tostring(math.floor(tallies[i].curNum)):reverse()
            for j = 1, #flipped do
                local num = tonumber(flipped:sub(j, j))
                if num then
                    tallies[i].sprites[j]:animate(tostring(num), false)
                    if j > 1 and num > 0 and not tallies[i].sprites[j].visible then
                        tallies[i].sprites[j].visible = true
                        tallies[i].sprites[j].x = tallies[i].storedX[j-1] - 38
                        for k = 1, j-1 do
                            tallies[i].sprites[k].x = tallies[i].storedX[k]
                        end
                    end
                end
            end
        end

        for i = 1, #scoreNumbers.sprites do
            scoreNumbers.sprites[i]:update(dt)
        end

        if input:pressed("confirm") and scoreNumbers.visible then
            resultsMusic:stop()
            Gamestate.switch(menuSelect)
            music:play()
        end
    end,

    draw = function(self)
        love.graphics.push()
            graphics.setColor(255/255, 204/255, 92/255)
                love.graphics.rectangle("fill", 0, 0, 1280, 720)
            graphics.setColor(1, 1, 1)
            curDiff:draw()
            love.graphics.push()
                love.graphics.translate(1280/2, 720/2)
                love.graphics.rotate(-0.08)
                love.graphics.translate(-1280/2, -720/2)
                local formattedStr
                if artist ~= nil then
                    formattedStr = string.format("%s by %s", songName, artist)
                else
                    formattedStr = songName
                end
                printResultsFont(thePosEverX + curDiff:getWidth()/2+25, thePosEverY[1] - curDiff:getHeight()/4, formattedStr, 1)

                graphics.setColor(255/255, 204/255, 92/255)
                    love.graphics.rectangle("fill", 0, 0, 1280/2-80, 720) -- Rectangle because Nintendo switch doesn't support Sprite Clipping
                graphics.setColor(1, 1, 1)
            love.graphics.pop()

            resultsPLAYER:draw()
            soundSystem:draw()

            topBarBlack:draw()
            resultsAnim:draw()

            ratingsPopin:draw()
            scorePopin:draw()

            for i = 1, #tallies do
                for j = 1, #tallies[i].sprites do
                    if not tallies[i].visible then
                        break
                    end
                    graphics.setColor(tallies[i].colour[1], tallies[i].colour[2], tallies[i].colour[3])
                    tallies[i].sprites[j]:draw()
                    graphics.setColor(1, 1, 1)
                end
            end

            for i = 1, #scoreNumbers.sprites do
                if not scoreNumbers.visible then
                    break
                end
                scoreNumbers.sprites[i]:draw()
            end
        love.graphics.pop()
    end,

    leave = function(self)
        tallies = {}
        scoreNumbers.sprites = {}
        resultsPLAYER = nil
        soundSystem = nil
        ratingsPopin = nil
        scorePopin = nil
        resultsAnim = nil
        topBarBlack = nil
        resultsFont = {quads={}, img=nil}
        curDiff = nil
        thePosEverX = 0
        thePosEverY = {0}
        textTween = nil
    end
}