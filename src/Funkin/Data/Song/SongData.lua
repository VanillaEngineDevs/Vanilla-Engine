---@class SongMetadata
local SongMetadata = Class:extend()

---@class SongTimeChange
SongTimeChange = Class:extend()

---@class SongOffsets
SongOffsets = Class:extend()

function SongOffsets:getVocalOffset()
    return 0
end

SongChartData = Class:extend()

function SongChartData:new(scrollSpeed, events, notes)
    self.version = "2.0.2"

    self.events = events
    self.notes = notes
    self.scrollSpeed = scrollSpeed

    self.generatedBy = SongRegistry.DEFAULT_GENERATEDBY
end

function SongChartData:getScrollSpeed(diff)
    local result = self.scrollSpeed[diff]

    if result == 0.0 and diff ~= "default" then
        return self:getScrollSpeed("default")
    end

    return result == 0.0 and 1.0 or result
end

function SongChartData:setScrollSpeed(value, diff)
    self.scrollSpeed[diff] = value
    return value
end

function SongChartData:getNotes(diff)
    local result = self.notes[diff]

    if result == nil and diff ~= "normal" then
        return self:getNotes("normal")
    end

    return result == nil and {} or result
end

function SongChartData:setNotes(value, diff)
    self.notes[diff] = value
    return value
end

function SongChartData:serialize(pretty)
    self:updateVersionToLatest()

end

function SongChartData:updateVersionToLatest()
    self.version = SongRegistry.SONG_CHART_DATA_VERSION
    self.generatedBy = SongRegistry.DEFAULT_GENERATEDBY
end

function SongChartData:clone()
    local noteDataClone = {}
    for key, value in pairs(self.notes) do
        noteDataClone[key] = value:deepClone()
    end
    local eventDataClone = self.events:deepClone()

    local result = SongChartData(self.scrollSpeed:clone(), eventDataClone, noteDataClone)
    result.version = self.version
    result.generatedBy = self.generatedBy
    result.variation = self.variation

    return result
end

function SongChartData:toString()
    return "SongChartData(" .. #self.events .. " events, " .. #self.notes .. " difficulties, " .. self.generatedBy .. ")"
end

return SongMetadata