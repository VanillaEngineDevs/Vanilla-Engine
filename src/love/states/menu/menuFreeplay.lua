local leftFunc, rightFunc, confirmFunc, backFunc, drawFunc

local menuState

local menuNum = 1
local songNum

local songNum, songAppend
local songDifficulty = 2

local difficultyStrs
local ratingText

return {
    enter = function(self)
        menuBG = graphics.newImage(graphics.imagePath("menu/fp_bg"))
        songSelect = graphics.newImage(graphics.imagePath("menu/fp_songSelect"))
        songStats = graphics.newImage(graphics.imagePath("menu/fp_songStats"))
        tabs = graphics.newImage(graphics.imagePath("menu/fp_tabs"))
        weekSelect = graphics.newImage(graphics.imagePath("menu/fp_weekSelect"))
        weekStats = graphics.newImage(graphics.imagePath("menu/fp_weekStats"))
        backButton = graphics.newImage(graphics.imagePath("menu/backBtn"))

        graphics:fadeInWipe(0.6)

        difficultyStrs = {
            "-easy",
            "",
            "-hard"
        }
        songBefore = ""
        songAfter = ""

        menuNum = 1
        songNum = 1
        weekNum = 1

        curWeekScore = 0
        averageAccuracy = 0
        ratingText = "???"

        curSongScore = 0
        curSongAccuracy = 0

        for i = 1, #weekMeta[weekNum][2] do
            curWeekScore = 0
            averageAccuracy = 0
        end
        averageAccuracy = 0
        if averageAccuracy >= 101 then
            ratingText = "what"
        elseif averageAccuracy >= 100 then
            ratingText = "Perfect!!!"
        elseif averageAccuracy >= 90 then
            ratingText = "Marvelous!"
        elseif averageAccuracy >= 70 then
            ratingText = "Good!"
        elseif averageAccuracy >= 69 then
            ratingText = "Nice!"
        elseif averageAccuracy >= 60 then
            ratingText = "Okay"
        elseif averageAccuracy >= 50 then
            ratingText = "Meh..."
        elseif averageAccuracy >= 40 then
            ratingText = "Could be better..."
        elseif averageAccuracy >= 30 then
            ratingText = "It's an issue of skill."
        elseif averageAccuracy >= 20 then
            ratingText = "Bad."
        elseif averageAccuracy >= 10 then
            ratingText = "How."
        elseif averageAccuracy >= 1 then
            ratingText = "Bruh."
        elseif averageAccuracy >= 0 then
            ratingText = "???"
        end
        averageAccuracy = string.format("%.2f%%", averageAccuracy)

    end,
    
    update = function(self, dt)
        if input:pressed("down") then
            if menuNum == 1 then
                weekNum = weekNum + 1
                if weekNum > #weekMeta then
                    weekNum = 1
                end
                curWeekScore = 0
                averageAccuracy = 0
                for i = 1, #weekMeta[weekNum][2] do
                    if savedata[weekNum] then
                        if savedata[weekNum][i] then
                            curWeekScore = curWeekScore + savedata[weekNum][i].score
                            averageAccuracy = averageAccuracy + savedata[weekNum][i][2].accuracy
                        end
                    end
                end
                if averageAccuracy >= 101 then
                    ratingText = "what"
                elseif averageAccuracy >= 100 then
                    ratingText = "Perfect!!!"
                elseif averageAccuracy >= 90 then
                    ratingText = "Marvelous!"
                elseif averageAccuracy >= 70 then
                    ratingText = "Good!"
                elseif averageAccuracy >= 69 then
                    ratingText = "Nice!"
                elseif averageAccuracy >= 60 then
                    ratingText = "Okay"
                elseif averageAccuracy >= 50 then
                    ratingText = "Meh..."
                elseif averageAccuracy >= 40 then
                    ratingText = "Could be better..."
                elseif averageAccuracy >= 30 then
                    ratingText = "It's an issue of skill."
                elseif averageAccuracy >= 20 then
                    ratingText = "Bad."
                elseif averageAccuracy >= 10 then
                    ratingText = "How."
                elseif averageAccuracy >= 1 then
                    ratingText = "Bruh."
                elseif averageAccuracy >= 0 then
                    ratingText = "???"
                end
                averageAccuracy = string.format("%.2f%%", averageAccuracy)
            elseif menuNum == 2 then
                songNum = songNum + 1
                if songNum > #weekMeta[weekNum][2] then
                    songNum = 1
                end
                curSongAccuracy = 0
                curSongScore = 0
                if savedata[weekNum] then
                    if savedata[weekNum][songNum] then
                        curSongScore = savedata[weekNum][songNum].score
                        curSongAccuracy = savedata[weekNum][songNum][2].accuracy
                    end
                end

                curSongAccuracy = string.format("%.2f%%", curSongAccuracy)
            end
            if menuNum ~= 1 then
                songBefore = weekMeta[weekNum][2][songNum-1] or ""
                songAfter = weekMeta[weekNum][2][songNum+1] or ""
            end
            audio.playSound(selectSound)
        elseif input:pressed("up") then
            if menuNum == 1 then
                weekNum = weekNum - 1
                if weekNum < 1 then
                    weekNum = #weekMeta
                end
                curWeekScore = 0
                averageAccuracy = 0
                for i = 1, #weekMeta[weekNum][2] do
                    if savedata[weekNum] then
                        if savedata[weekNum][i] then
                            curWeekScore = curWeekScore + savedata[weekNum][i][1]
                            averageAccuracy = averageAccuracy + savedata[weekNum][i][2]
                        end
                    end
                end
                averageAccuracy = 0
                if averageAccuracy >= 101 then
                    ratingText = "what"
                elseif averageAccuracy >= 100 then
                    ratingText = "Perfect!!!"
                elseif averageAccuracy >= 90 then
                    ratingText = "Marvolous!"
                elseif averageAccuracy >= 70 then
                    ratingText = "Good!"
                elseif averageAccuracy >= 69 then
                    ratingText = "Nice!"
                elseif averageAccuracy >= 60 then
                    ratingText = "Okay"
                elseif averageAccuracy >= 50 then
                    ratingText = "Meh..."
                elseif averageAccuracy >= 40 then
                    ratingText = "Could be better..."
                elseif averageAccuracy >= 30 then
                    ratingText = "It's an issue of skill."
                elseif averageAccuracy >= 20 then
                    ratingText = "Bad."
                elseif averageAccuracy >= 10 then
                    ratingText = "How."
                elseif averageAccuracy >= 1 then
                    ratingText = "Bruh."
                elseif averageAccuracy >= 0 then
                    ratingText = "???"
                end
                averageAccuracy = string.format("%.2f%%", averageAccuracy)
            elseif menuNum == 2 then
                songNum = songNum - 1
                if songNum < 1 then
                    songNum = #weekMeta[weekNum][2]
                end

                curSongAccuracy = 0
                curSongScore = 0
                if savedata[weekNum] then
                    if savedata[weekNum][songNum] then
                        curSongScore = savedata[weekNum][songNum].score
                        curSongAccuracy = savedata[weekNum][songNum][2].accuracy
                    end
                end

                curSongAccuracy = string.format("%.2f%%", curSongAccuracy)
            elseif menuNum == 3 then
                songDifficulty = songDifficulty - 1
                if songDifficulty < 1 then
                    songDifficulty = 3
                end
            end
            if menuNum ~= 1 then
                songBefore = weekMeta[weekNum][2][songNum-1] or ""
                songAfter = weekMeta[weekNum][2][songNum+1] or ""
            end
            audio.playSound(selectSound)
        elseif input:pressed("left") then
            songDifficulty = songDifficulty - 1 
            if songDifficulty < 1 then
                songDifficulty = 3
            end
            audio.playSound(selectSound)
            curWeekScore = 0
            averageAccuracy = 0
            ratingText = "???"
            for i = 1, #weekMeta[weekNum][2] do
                curWeekScore = 0
                averageAccuracy = 0
            end
            averageAccuracy = 0
            if averageAccuracy >= 101 then
                ratingText = "what"
            elseif averageAccuracy >= 100 then
                ratingText = "Perfect!!!"
            elseif averageAccuracy >= 90 then
                ratingText = "Marvelous!"
            elseif averageAccuracy >= 70 then
                ratingText = "Good!"
            elseif averageAccuracy >= 69 then
                ratingText = "Nice!"
            elseif averageAccuracy >= 60 then
                ratingText = "Okay"
            elseif averageAccuracy >= 50 then
                ratingText = "Meh..."
            elseif averageAccuracy >= 40 then
                ratingText = "Could be better..."
            elseif averageAccuracy >= 30 then
                ratingText = "It's an issue of skill."
            elseif averageAccuracy >= 20 then
                ratingText = "Bad."
            elseif averageAccuracy >= 10 then
                ratingText = "How."
            elseif averageAccuracy >= 1 then
                ratingText = "Bruh."
            elseif averageAccuracy >= 0 then
                ratingText = "???"
            end
            averageAccuracy = string.format("%.2f%%", averageAccuracy)
        elseif input:pressed("right") then
            songDifficulty = songDifficulty + 1
            if songDifficulty > 3 then
                songDifficulty = 1
            end
            audio.playSound(selectSound)
            curWeekScore = 0
            averageAccuracy = 0
            ratingText = "???"
            for i = 1, #weekMeta[weekNum][2] do
                curWeekScore = 0
                averageAccuracy = 0
            end
            averageAccuracy = 0
            if averageAccuracy >= 101 then
                ratingText = "what"
            elseif averageAccuracy >= 100 then
                ratingText = "Perfect!!!"
            elseif averageAccuracy >= 90 then
                ratingText = "Marvelous!"
            elseif averageAccuracy >= 70 then
                ratingText = "Good!"
            elseif averageAccuracy >= 69 then
                ratingText = "Nice!"
            elseif averageAccuracy >= 60 then
                ratingText = "Okay"
            elseif averageAccuracy >= 50 then
                ratingText = "Meh..."
            elseif averageAccuracy >= 40 then
                ratingText = "Could be better..."
            elseif averageAccuracy >= 30 then
                ratingText = "It's an issue of skill."
            elseif averageAccuracy >= 20 then
                ratingText = "Bad."
            elseif averageAccuracy >= 10 then
                ratingText = "How."
            elseif averageAccuracy >= 1 then
                ratingText = "Bruh."
            elseif averageAccuracy >= 0 then
                ratingText = "???"
            end
            averageAccuracy = string.format("%.2f%%", averageAccuracy)
        elseif input:pressed("confirm") then
            if menuNum == 1 then songNum = 1 end
            if menuNum == 2 then
                status.setLoading(true)
    
                graphics:fadeOutWipe(
                    0.7,
                    function()
                        songAppend = difficultyStrs[songDifficulty]
                        _psychmod = false
    
                        storyMode = false
    
                        music:stop()
    
                        Gamestate.switch(weekData[weekNum], songNum, songAppend, weekNum)
    
                        status.setLoading(false)
                    end
                )
            end
            if menuNum ~= 2 then
                menuNum = menuNum + 1

                curSongAccuracy = 0
                curSongScore = 0

                if savedata[weekNum] then
                    if savedata[weekNum][songNum] then
                        curSongScore = savedata[weekNum][songNum].score
                        curSongAccuracy = savedata[weekNum][songNum][2].accuracy
                    end
                end

                curSongAccuracy = string.format("%.2f%%", curSongAccuracy)
            end
            
            songBefore = weekMeta[weekNum][2][songNum-1] or ""
            songAfter = weekMeta[weekNum][2][songNum+1] or ""
            audio.playSound(confirmSound)
        elseif input:pressed("back") then
            if menuNum ~= 1 then
                menuNum = menuNum - 1
            else
                graphics:fadeOutWipe(0.7, function()
                    Gamestate.switch(menuSelect)
                end)
            end
            audio.playSound(selectSound)
        elseif input:pressed("tab") then
            if menuNum == 1 then
                songNum = 1
                menuNum = 2
                songBefore = weekMeta[weekNum][2][songNum-1] or ""
                songAfter = weekMeta[weekNum][2][songNum+1] or ""
            else
                menuNum = 1
            end
        end
    end,

    draw = function(self, dt)
        love.graphics.push()
            love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
            menuBG:draw()
            tabs:draw()
            if menuNum == 1 then weekSelect:draw() else songSelect:draw() end
            if menuNum == 1 then
                weekStats:draw()
                love.graphics.setFont(weekFont)
                graphics.setColor(1,1,1,1)
                uitextf(weekMeta[weekNum][1] or "", -55, -18, 600, "center")
                love.graphics.setFont(weekFontSmall)
                uitextf(curWeekScore, -545, 50, 600, "center")
                uitextf(averageAccuracy, -825, 50, 600, "center")
                uitextf(ratingText, -675, 195, 600, "center")
            else
                songStats:draw()
                graphics.setColor(141/255, 130/255, 123/255)
                love.graphics.setFont(weekFontSmall)
                love.graphics.printf(songBefore, 60, -72, 600, "center")

                graphics.setColor(1,1,1,1)
                love.graphics.setFont(weekFont)
                love.graphics.printf(weekMeta[weekNum][2][songNum], 65, -18, 600, "center")

                graphics.setColor(141/255, 130/255, 123/255)
                love.graphics.setFont(weekFontSmall)
                love.graphics.printf(songAfter, 60, 72, 600, "center")

                love.graphics.setFont(weekFontSmall)
                uitextf(curSongScore, -545, 50, 600, "center")
                uitextf(curSongAccuracy, -825, 50, 600, "center")

                graphics.setColor(1,1,1,1)
            end
            --if menuNum == 1 then weekStats:draw() else songStats:draw() end
            love.graphics.setFont(weekFont)
            -- make the current dificulties first letter uppercase
            local difficultyStr = difficultyStrs[songDifficulty]
            difficultyStr = difficultyStr:sub(1,1):upper() .. difficultyStr:sub(2)
            if difficultyStr == "" then 
                difficultyStr = "Normal"
            else
                -- remove the first letter from the difficulty string
                difficultyStr = difficultyStr:sub(2)
                -- make the first letter uppercase
                difficultyStr = difficultyStr:sub(1,1):upper() .. difficultyStr:sub(2)
                --difficultyStr:gsub("-", "")
            end
            uitextf(difficultyStr, 65, -370, 600, "center")
            backButton:draw()
        love.graphics.pop()
    end
}