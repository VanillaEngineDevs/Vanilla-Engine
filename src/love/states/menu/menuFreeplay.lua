local leftFunc, rightFunc, confirmFunc, backFunc, drawFunc

local menuState

local menuNum = 1
local songNum

local songNum, songAppend
local songDifficulty = 2

local ratingText

function table.print(t)
    for k, v in pairs(t) do
        if type(v) == "table" then
            table.print(v)
        else
            print(k, v)
        end
    end
end

local function CreateWeek(weekIndex, hasErect)
    local week = {
        name = weekMeta[weekIndex][1],
        songs = {}
    }

    for _, song in ipairs(weekMeta[weekIndex][2]) do
        if type(song) == "table" then
            local hasErect, hasPico = song.erect, song.pico
            if not song.show then goto continue end
            local newSong = {
                name = song[1],
                diffs = {}
            }
            for _, diff in ipairs(song.diffs or {}) do
                table.insert(newSong.diffs, {diff[1] or "???", diff[2] or "", diff[3] or diff[1] or "???", diff[4] or "-bf"})
            end

            if hasErect then
                table.insert(newSong.diffs, {"erect", "-erect", "erect", "-bf"})
                table.insert(newSong.diffs, {"nightmare", "-erect", "nightmare", "-bf"})
            end
            if hasPico then
                table.insert(newSong.diffs, {"easy-Pico", "-pico", "easy", "-pico"})
                table.insert(newSong.diffs, {"normal-Pico", "-pico", "normal", "-pico"})
                table.insert(newSong.diffs, {"hard-Pico", "-pico", "hard", "-pico"})
            end

            table.insert(week.songs, newSong)
        elseif type(song) == "string" then
            local song = {
                name = song,
                diffs = {
                    {"easy", "", "easy", "-bf"},
                    {"normal", "", "normal", "-bf"},
                    {"hard", "", "hard", "-bf"}
                }
            }

            table.insert(week.songs, song)
        end

        ::continue::
    end

    return week
end

local allWeeks = {}

local function calculateRatingText(accuracy)
    if averageAccuracy >= 101 then
        return "what"
    elseif averageAccuracy >= 100 then
        return "Perfect!"
    elseif averageAccuracy >= 90 then
        return "Marvelous!"
    elseif averageAccuracy >= 70 then
        return "Good!"
    elseif averageAccuracy >= 69 then
        return "Nice!"
    elseif averageAccuracy >= 60 then
        return "Okay"
    elseif averageAccuracy >= 50 then
        return "Meh..."
    elseif averageAccuracy >= 40 then
        return "Could be better..."
    elseif averageAccuracy >= 30 then
        return "It's an issue of skill."
    elseif averageAccuracy >= 20 then
        return "Bad."
    elseif averageAccuracy >= 10 then
        return "How."
    elseif averageAccuracy >= 1 then
        return "Bruh."
    elseif averageAccuracy >= 0 then
        return "???"
    end
end

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

        averageAccuracy = 0
        
        averageAccuracy = string.format("%.2f%%", averageAccuracy)

        for i = 1, #weekMeta do
            allWeeks[i] = CreateWeek(i)
        end

        songDifficulty = util.clamp(2, 1, #allWeeks[weekNum].songs[songNum].diffs)
    end,
    
    update = function(self, dt)
        if input:pressed("down") then
            if menuNum == 1 then
                weekNum = weekNum + 1
                if weekNum > #weekMeta then
                    weekNum = 1
                end
                if songDifficulty > #allWeeks[weekNum].songs[songNum].diffs then
                    songDifficulty = #allWeeks[weekNum].songs[songNum].diffs
                end
            elseif menuNum == 2 then
                songNum = songNum + 1
                if songNum > #allWeeks[weekNum].songs then
                    songNum = 1
                end
                if songDifficulty > #allWeeks[weekNum].songs[songNum].diffs then
                    songDifficulty = #allWeeks[weekNum].songs[songNum].diffs
                end
            end
            if menuNum ~= 1 then
                songBefore = weekMeta[weekNum][2][songNum-1] and weekMeta[weekNum][2][songNum-1][1] or ""
                songAfter = weekMeta[weekNum][2][songNum+1] and weekMeta[weekNum][2][songNum+1][1] or ""
            end
            audio.playSound(selectSound)
        elseif input:pressed("up") then
            if menuNum == 1 then
                weekNum = weekNum - 1
                if weekNum < 1 then
                    weekNum = #weekMeta
                end

                if songDifficulty > #allWeeks[weekNum].songs[songNum].diffs then
                    songDifficulty = #allWeeks[weekNum].songs[songNum].diffs
                end
            elseif menuNum == 2 then
                songNum = songNum - 1
                if songNum < 1 then
                    songNum = #allWeeks[weekNum].songs
                end
                if songDifficulty > #allWeeks[weekNum].songs[songNum].diffs then
                    songDifficulty = #allWeeks[weekNum].songs[songNum].diffs
                end
            elseif menuNum == 3 then
                songDifficulty = songDifficulty - 1
                if songDifficulty < 1 then
                    songDifficulty = #allWeeks[weekNum].songs[songNum].diffs
                end
            end
            if menuNum ~= 1 then
                songBefore = weekMeta[weekNum][2][songNum-1] and weekMeta[weekNum][2][songNum-1][1] or ""
                songAfter = weekMeta[weekNum][2][songNum+1] and weekMeta[weekNum][2][songNum+1][1] or ""
            end
            audio.playSound(selectSound)
        elseif input:pressed("left") then
            songDifficulty = songDifficulty - 1 
            if songDifficulty < 1 then
                songDifficulty = #allWeeks[weekNum].songs[songNum].diffs
            end
            audio.playSound(selectSound)
        elseif input:pressed("right") then
            songDifficulty = songDifficulty + 1
            if songDifficulty > #allWeeks[weekNum].songs[songNum].diffs then
                songDifficulty = 1
            end
            audio.playSound(selectSound)
        elseif input:pressed("confirm") then
            if menuNum == 1 then songNum = 1 end
            if menuNum == 2 then
                status.setLoading(true)
    
                graphics:fadeOutWipe(
                    0.7,
                    function()
                        importMods.inMod = weekNum > modWeekPlacement
    
                        storyMode = false
    
                        music:stop()
    
                        Gamestate.switch(weekData[weekNum], songNum, allWeeks[weekNum].songs[songNum].diffs[songDifficulty][3], allWeeks[weekNum].songs[songNum].diffs[songDifficulty][2], allWeeks[weekNum].songs[songNum].diffs[songDifficulty][4])
    
                        status.setLoading(false)
                    end
                )
            end
            if menuNum ~= 2 then
                menuNum = menuNum + 1

                curSongAccuracy = 0
                curSongScore = 0

                curSongAccuracy = string.format("%.2f%%", curSongAccuracy)
            end
            
            songBefore = weekMeta[weekNum][2][songNum-1] and weekMeta[weekNum][2][songNum-1][1] or ""
            songAfter = weekMeta[weekNum][2][songNum+1] and weekMeta[weekNum][2][songNum+1][1] or ""
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
                songBefore = weekMeta[weekNum][2][songNum-1] and weekMeta[weekNum][2][songNum-1][1] or ""
                songAfter = weekMeta[weekNum][2][songNum+1] and weekMeta[weekNum][2][songNum+1][1] or ""
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
            else
                songStats:draw()
                
                graphics.setColor(1,1,1,1)
                love.graphics.setFont(weekFont)
                love.graphics.printf(allWeeks[weekNum].songs[songNum].name, 65, -18, 600, "center")

                graphics.setColor(1,1,1,1)
            end
            --if menuNum == 1 then weekStats:draw() else songStats:draw() end
            love.graphics.setFont(weekFont)
            -- make the current dificulties first letter uppercase
            local difficultyStr = allWeeks[weekNum].songs[songNum].diffs[songDifficulty][1]
            if difficultyStr == "" then 
                difficultyStr = "Normal"
            else
                -- make the first letter uppercase
                difficultyStr = difficultyStr:sub(1,1):upper() .. difficultyStr:sub(2)
                --difficultyStr:gsub("-", "")
            end
            uitextf(difficultyStr, 65, -370, 600, "center")
            backButton:draw()
        love.graphics.pop()
    end
}