local Difficulty = Object:extend()

Difficulty.defaultList = {
    "Easy",
    "Normal",
    "Hard"
}

Difficulty.list = {}
Difficulty.defaultDifficulty = "Normal"

function Difficulty:getFilePath(num)
    if not num then num = PlayState.storyDifficulty end

    local fileSuffix = self.list[num]
    if fileSuffix ~= self.defaultDifficulty then
        fileSuffix = "-" .. fileSuffix
    else
        fileSuffix = ""
    end
    return Paths.formatToSongPath(fileSuffix)
end

function Difficulty:loadFromWeek(week)
    if not week then week = WeekData:getCurrentWeek() end

    local diffStr = week.difficulties
    if diffStr ~= nil and #diffStr > 0 then
        local diffs = diffStr:split(",")
        local i = #diffs
        while i > 0 do
            if diffs[i] then
                diffs[i] = diffs[i]:trim()
                if #diffs[i] < 1 then
                    table.remove(diffs, i)
                end
            end
            i = i - 1
        end

        if #diffs > 0 and #diffs[1] > 0 then
            self.list = diffs
        else
            self.list = self.defaultList
        end
    else
        self:resetList()
    end
end

function Difficulty:resetList()
    self.list = self.defaultList
end

function Difficulty:copyFrom(diffs)
    self.list = {}
    for i = 1, #diffs do
        self.list[i] = diffs[i]
    end
end

function Difficulty:getString(num)
    return self.list[num or PlayState.storyDifficulty]
end

function Difficulty:getDefault()
    return self.defaultDifficulty
end

return Difficulty