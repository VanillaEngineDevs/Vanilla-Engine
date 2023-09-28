local WeekData = Object:extend()
WeekData.weeksLoaded = {}
WeekData.weeksList = {}
WeekData.folder = ""

-- Json Variables
WeekData.songs = {}
WeekData.weekCharacters = {}
WeekData.weekBackground = ""
WeekData.weekBefore = ""
WeekData.storyName = ""
WeekData.weekName = ""
WeekData.freeplayColor = {255, 255, 255}
WeekData.startUnlocked = true
WeekData.hiddenUntilUnlocked = false
WeekData.hideStoryMode = false
WeekData.hideFreeplay = false
WeekData.difficulties = ""

WeekData.fileName = ""

function WeekData:createWeekFile()
    local weekFile = {
        songs = {{"Bopeebo", "dad", {143, 113, 253}}, {"Fresh", "dad", {143, 113, 253}}, {"Dad Battle", "dad", {146, 113, 253}}},
        weekCharacters = {"dad", "bf", "gf"},
        weekBackground = "stage",
        weekBefore = "tutorial",
        storyName = "Your New Week",
        weekName = "Custom Week",
        freeplayColor = {146, 113, 253},
        startUnlocked = true,
        hiddenUntilUnlocked = false,
        hideStoryMode = false,
        hideFreeplay = false,
        difficulties = ""
    }

    return weekFile
end

function WeekData:new(weekFile, fileName)
    -- weekFile is pre-parsed json

    self.songs = weekFile.songs
    self.weekCharacters = weekFile.weekCharacters
    self.weekBackground = weekFile.weekBackground
    self.weekBefore = weekFile.weekBefore
    self.storyName = weekFile.storyName
    self.weekName = weekFile.weekName
    self.freeplayColor = weekFile.freeplayColor
    self.startUnlocked = weekFile.startUnlocked
    self.hiddenUntilUnlocked = weekFile.hiddenUntilUnlocked
    self.hideStoryMode = weekFile.hideStoryMode
    self.hideFreeplay = weekFile.hideFreeplay
    self.difficulties = weekFile.difficulties

    self.fileName = fileName
end

function WeekData:reloadWeekFiles(isStoryMode)
    local isStoryMode = isStoryMode or false

    WeekData.weeksList = {}
    WeekData.weeksLoaded = {}
    local directories = {"assets/"}
    local originalLength = #directories

    local sexList = {}
    for line in love.filesystem.lines("assets/weeks/weekList.txt") do
        if line ~= "" then
            table.insert(sexList, line)
        end
    end

    for i = 1, #sexList do
        for j = 1, #directories do
            local fileToCheck = directories[j] .. "weeks/" .. sexList[i] .. ".json"
            if not WeekData.weeksLoaded[sexList[i]] then
                local week = WeekData:getWeekFile(fileToCheck)
                if week then
                    local weekFile = WeekData(week, sexList[i])

                    if weekFile and (not isStoryMode or (isStoryMode and not weekFile.hideStoryMode) or (not isStoryMode and not weekFile.hideFreeplay)) then
                        table.insert(WeekData.weeksList, sexList[i])
                        WeekData.weeksLoaded[sexList[i]] = weekFile
                    end
                end
            end
        end
    end
end

function WeekData:addWeek(weekToCheck, path, directory, i, originalLength)
    if not self.weeksLoaded[weekToCheck] then
        local week = self:getWeekFile(path)
        if week then
            local weekFile = WeekData(week, weekToCheck)
            if i >= originalLength then
                -- mods
            end

            if (PlayState.isStoryMode and not weekFile.hideStoryMode) or (not PlayState.isStoryMode and not weekFile.hideFreeplay) then
                table.insert(self.weeksList, weekToCheck)
                self.weeksLoaded[weekToCheck] = weekFile
            end
        end
    end
end

function WeekData:getWeekFile(path)
    local rawJson = nil

    if love.filesystem.getInfo(path) then
        rawJson = love.filesystem.read(path)
    else
        return nil
    end

    if rawJson and rawJson ~= "" then
        return json.decode(rawJson)
    else
        return nil
    end
end

function WeekData:getWeekFileName()
    return self.weeksList[PlayState.storyWeek]
end

function WeekData:getCurrentWeek()
    return self.weeksLoaded[self.weeksList[PlayState.storyWeek]]
end

function setDirectoryFromWeek(data)
    -- mods shit
end

return WeekData