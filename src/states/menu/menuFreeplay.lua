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
    local wk = weekData[weekIndex]

    local week = {
        name = wk.id,
        songs = {}
    }

    for _, song in ipairs(wk.songs or {}) do
        local name = song

        local s = {
            name = name,
            diffs = {
            }
        }

        local id = songNameToFolder(name)

        for _, ver in ipairs(versionData) do
            local path = "data/songs/" .. id .. "/" .. id .. "-chart" .. ver.extension .. ".json"
            if poly.checkAllDirs(path) then
                for _, diff in ipairs(ver.diffs) do
                    local diffName, songAppend, display = unpack(diff)
                    local dontAppend = songAppend == "-bf"
                    if not dontAppend then
                        diffName = diffName .. songAppend
                    end
                    table.insert(s.diffs, {
                        name = songAppend,
                        diffName, ver.extension, ver.extension, ver.extension, display
                    })
                end
            else
                path = "data/songs/" .. id .. "/" .. id .. "-chart-" .. ver.extension .. ".json"
                if poly.checkAllDirs(path) then
                    for _, diff in ipairs(ver.diffs) do
                        local songAppend, diffName, display = unpack(diff)
                        local dontAppend = songAppend == "-bf"
                        if not dontAppend then
                            diffName = diffName .. songAppend
                        end
                        local mod = poly.getModFromDirectory(path)
                        table.insert(s.diffs, {
                            name = songAppend,
                            diffName, "-" .. ver.extension, "-" .. ver.extension, "-" .. ver.extension,
                            display, 
                            mod = mod
                        })
                    end
                end
            end
        end

        table.insert(week.songs, s)

        ::continue::
    end

    if #week.songs == 0 then
        table.insert(week.songs, {name = "", diffs = {{"", "", "", ""}}})
    end

    return week
end


local allWeeks = {}

local function getSongCount(wi)
    return #(((allWeeks[wi] or {}).songs or {}))
end

local function getDiffCount(wi, si)
    return #((((allWeeks[wi] or {}).songs or {})[si] or {}).diffs or {{""}})
end

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
        if not music:isPlaying() then
			music:play()
		end
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

        for i = 1, #weekData do
            allWeeks[i] = CreateWeek(i)
        end

        local diffs = (((allWeeks[weekNum] or {}).songs or {})[songNum] or {}).diffs or {{""}}
        songDifficulty = util.clamp(2, 1, #diffs)
    end,
    
    update = function(self, dt)
        if input:pressed("down") then
            if menuNum == 1 then
                weekNum = weekNum + 1
                if weekNum > #weekData then
                    weekNum = 1
                end
                local songCount = getSongCount(weekNum)
                if songNum > songCount then
                    songNum = 1
                end
                if songDifficulty > getDiffCount(weekNum, songNum) then
                    songDifficulty = getDiffCount(weekNum, songNum)
                end
            elseif menuNum == 2 then
                songNum = songNum + 1
                if songNum > getSongCount(weekNum) then
                    songNum = 1
                end
                if songDifficulty > getDiffCount(weekNum, songNum) then
                    songDifficulty = getDiffCount(weekNum, songNum)
                end
            end
            if menuNum ~= 1 then
                local prev = weekData[weekNum-1]
                local nextw = weekData[weekNum+1]
                songBefore = prev and prev.songs and prev.songs[songNum] and prev.songs[songNum].name or ""
                songAfter = nextw and nextw.songs and nextw.songs[songNum] and nextw.songs[songNum].name or ""
            end
            audio.playSound(selectSound)
        elseif input:pressed("up") then
            if menuNum == 1 then
                weekNum = weekNum - 1
                if weekNum < 1 then
                    weekNum = #weekData
                end

                local songCount = getSongCount(weekNum)
                if songNum > songCount then
                    songNum = 1
                end
                if songDifficulty > getDiffCount(weekNum, songNum) then
                    songDifficulty = getDiffCount(weekNum, songNum)
                end
            elseif menuNum == 2 then
                songNum = songNum - 1
                if songNum < 1 then
                    songNum = getSongCount(weekNum)
                end
                if songDifficulty > getDiffCount(weekNum, songNum) then
                    songDifficulty = getDiffCount(weekNum, songNum)
                end
            elseif menuNum == 3 then
                songDifficulty = songDifficulty - 1
                if songDifficulty < 1 then
                    songDifficulty = getDiffCount(weekNum, songNum)
                end
            end
            if menuNum ~= 1 then
                local prev = weekData[weekNum-1]
                local nextw = weekData[weekNum+1]
                songBefore = prev and prev.songs and prev.songs[songNum] and prev.songs[songNum].name or ""
                songAfter = nextw and nextw.songs and nextw.songs[songNum] and nextw.songs[songNum].name or ""
            end
            audio.playSound(selectSound)
        elseif input:pressed("left") then
            songDifficulty = songDifficulty - 1 
            if songDifficulty < 1 then
                songDifficulty = getDiffCount(weekNum, songNum)
            end
            audio.playSound(selectSound)
        elseif input:pressed("right") then
            songDifficulty = songDifficulty + 1
            if songDifficulty > getDiffCount(weekNum, songNum) then
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
                        storyMode = false

                        music:stop()

                        local selectedWeek = weekData[weekNum]
                        local dif = allWeeks[weekNum].songs[songNum].diffs[songDifficulty]

                        weeks.songs = { allWeeks[weekNum].songs[songNum].name }

                        print("MOD: ", selectedWeek.mod)
                        poly:setPriority(allWeeks[weekNum].songs[songNum].diffs[songDifficulty].mod)
                        Gamestate.switch(weeks, 1, dif.name, dif[2], dif[3], dif[4])

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
            
            local prev = weekData[weekNum-1]
            local nextw = weekData[weekNum+1]
            songBefore = prev and prev.songs and prev.songs[songNum] and prev.songs[songNum].name or ""
            songAfter = nextw and nextw.songs and nextw.songs[songNum] and nextw.songs[songNum].name or ""
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
                local prev = weekData[weekNum-1]
                local nextw = weekData[weekNum+1]
                songBefore = prev and prev.songs and prev.songs[songNum] and prev.songs[songNum].name or ""
                songAfter = nextw and nextw.songs and nextw.songs[songNum] and nextw.songs[songNum].name or ""
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
            local selWeek = weekData[weekNum]
            if menuNum == 1 then
                weekStats:draw()
                love.graphics.setFont(weekFont)
                graphics.setColor(1,1,1,1)
                uitextf(selWeek.id or "", -55, -18, 600, "center")
            else
                songStats:draw()
                
                graphics.setColor(1,1,1,1)
                love.graphics.setFont(weekFont)
                graphics.setColor(1,1,1,0.5)
                love.graphics.printf(songBefore, -300, -18, 250, "right")
                love.graphics.printf(songAfter, 50, -18, 250, "left")
                graphics.setColor(1,1,1,1)
                local selSong = selWeek.songs[songNum]
                uitextf(selSong, 0, -18, 600, "center")

                graphics.setColor(1,1,1,1)
            end

            love.graphics.setFont(weekFont)

            local selWeek = allWeeks[weekNum]
            local difficultyStr = ((selWeek.songs[songNum] or {}).diffs or {{""}})[songDifficulty] and ((selWeek.songs[songNum] or {}).diffs or {{""}})[songDifficulty][1] or ""
            if difficultyStr == "" then 
                difficultyStr = "Normal"
            else
                difficultyStr = difficultyStr:sub(1,1):upper() .. difficultyStr:sub(2)
            end
            -- if the difficulty has a display, set it to that instead
            local display = ((selWeek.songs[songNum] or {}).diffs or {{""}})[songDifficulty] and ((selWeek.songs[songNum] or {}).diffs or {{""}})[songDifficulty][5]
            if display and display ~= "" then
                difficultyStr = display
            end
            uitextf(difficultyStr, 65, -370, 600, "center")
            backButton:draw()
        love.graphics.pop()
    end
}