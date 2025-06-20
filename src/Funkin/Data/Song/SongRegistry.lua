---@class SongRegistry : BaseRegistry
local SongRegistry = BaseRegistry:extend()
SongRegistry.generic = Song

local SONG_CHART_DATA_VERSION_RULE = "2.0.x"
local SONG_METADATA_VERSION_RULE = "2.2.x"

function SongRegistry:loadEntries()
    self:clearEntries()

    local entryIdList = DataAssets:listDataFilesInPath("songs/", "-metadata.json"):map(function(songDataPath)
        return songDataPath:split("/")[1]
    end)

    local unscriptedDataEntryIds = entryIdList:filter(function(id)
        return not self.entries[id]
    end)

    for _, id in ipairs(unscriptedDataEntryIds) do
        local ok, entryData = pcall(function()
            local entry = self:createEntry(id)
            if entry then
                self.entries[id] = entry
            end
        end)

        if not ok then
            print("Error loading song data for " .. id .. ": " .. entryData)
        end
    end
end

function SongRegistry:parseMusicData(id, variation)
    local variation = variation or Constants.DEFAULT_VARIATION
    local jsonData = SongRegistry:loadMusicDataFile(id, variation)
    local data = Json.decode(jsonData.contents)

    return data
end

function SongRegistry:loadMusicDataFile(id, variation)
    local variation = variation or Constants.DEFAULT_VARIATION
    local entryFilePath = Paths.file("music/" .. id .. "/" .. id .. "-metadata" .. (variation == Constants.DEFAULT_VARIATION and "" or ("-" .. variation)) .. ".json")
    return {
        fileName = entryFilePath,
        contents = love.filesystem.read(entryFilePath)
    }
end

function SongRegistry:loadEntryMetadataFile(id, variation)
    local variation = variation or Constants.DEFAULT_VARIATION

    local entryFilePath = Paths.file("data/songs/" .. id .. "/" .. id .. "-metadata" .. (variation == Constants.DEFAULT_VARIATION and "" or ("-" .. variation)) .. ".json")
    return {
        fileName = entryFilePath,
        contents = love.filesystem.read(entryFilePath)
    }
end

function SongRegistry:fetchEntryMetadataVersion(id, variation)
    local variation = variation or Constants.DEFAULT_VARIATION
    local jsonData = SongRegistry:loadEntryMetadataFile(id, variation)
    local data = Json.decode(jsonData.contents)

    return data.version
end

function SongRegistry:parseEntryMetadata(id, variation)
    local variation = variation or Constants.DEFAULT_VARIATION
    local jsonData = SongRegistry:loadEntryMetadataFile(id, variation)
    local data = Json.decode(jsonData.contents)

    return self:cleanMetadata(data, variation)
end

function SongRegistry:parseEntryMetadata_v2_1_0(id, variation)
    local variation = variation or Constants.DEFAULT_VARIATION
    local jsonData = SongRegistry:loadEntryMetadataFile(id, variation)
    local data = Json.decode(jsonData.contents)

    return self:cleanMetadata(data, variation)
end

function SongRegistry:parseEntryMetadata_v2_0_0(id, variation)
    local variation = variation or Constants.DEFAULT_VARIATION
    local jsonData = SongRegistry:loadEntryMetadataFile(id, variation)
    local data = Json.decode(jsonData.contents)

    return self:cleanMetadata(data, variation)
end

function SongRegistry:parseEntryMetadataWithMigration(id, variation, version)
    local variation = variation or Constants.DEFAULT_VARIATION

    if SONG_METADATA_VERSION_RULE == nil or VersionUtil:validateVersion(version, SONG_METADATA_VERSION_RULE) then
        return self:parseEntryMetadata(id, variation)
    elseif VersionUtil:validateVersion(version, "2.1.x") then
        return self:parseEntryMetadata_v2_1_0(id, variation)
    elseif VersionUtil:validateVersion(version, "2.0.x") then
        return self:parseEntryMetadata_v2_0_0(id, variation)
    else
        return self:parseEntryMetadata(id, variation)
    end

    --[[ return self:parseEntryMetadata(id, variation) ]]
end

function SongRegistry:fetchEntryChartVersion(id, variation)
    variation = variation or Constants.DEFAULT_VARIATION
    local entryStr = SongRegistry:loadEntryChartFile(id, variation).contents
    local entryVersion = VersionUtil:getVersionFromJSON(entryStr)

    return entryVersion
end

function SongRegistry:loadEntryChartFile(id, variation)
    local variation = variation and variation.variation or Constants.DEFAULT_VARIATION
    local entryFilePath = Paths.file("data/songs/" .. id .. "/" .. id .. "-chart" .. (variation == Constants.DEFAULT_VARIATION and "" or ("-" .. variation)) .. ".json")
    if not love.filesystem.getInfo(entryFilePath) then
        return nil
    end

    local rawJson = love.filesystem.read(entryFilePath)
    if rawJson == nil then
        return nil
    end

    return {
        fileName = entryFilePath,
        contents = rawJson
    }
end

function SongRegistry:parseEntryChartDataWithMigration(id, variation, version)
    variation = variation or Constants.DEFAULT_VARIATION

    if VersionUtil:validateVersion(version, SONG_CHART_DATA_VERSION_RULE, true) then
        return self:parseEntryChartData(id, variation)
    else
        return self:parseEntryChartData(id, variation)
    end
end

function SongRegistry:parseEntryChartData(id, variation)
    variation = variation or Constants.DEFAULT_VARIATION

    local jsonData = SongRegistry:loadEntryChartFile(id, variation)
    if jsonData == nil then
        return nil
    end

    local data = Json.decode(jsonData.contents)

    local real = SongChartData(data.scrollSpeed, data.events, data.notes)
    real.version = data.version
    oPrint("BALLS", real.notes.normal)

    return self:cleanChartData(real, variation)
end

function SongRegistry:cleanChartData(data, variation)
    data.variation = variation

    return data
end

function SongRegistry:cleanMetadata(data, variation)
    data.variation = variation

    return data
end

return SongRegistry