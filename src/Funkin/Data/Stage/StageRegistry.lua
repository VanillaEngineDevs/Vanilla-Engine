local StageRegistry = BaseRegistry:extend("StageRegistry")

function StageRegistry:getInstance()
    if not StageRegistry.instance then
        StageRegistry()
    end

    return StageRegistry.instance
end

function StageRegistry:new()
    StageRegistry.instance = self
    BaseRegistry.new(self, "STAGE", "stages", "x.x.x")
    StageRegistry.generic = StageData
end

function StageRegistry:loadEntries()
    self:clearEntries()

    local entryIdList = DataAssets:listDataFilesInPath("stages/"):map(function(stageDataPath)
        return stageDataPath
    end)

    local unscriptedDataEntryIds = entryIdList:filter(function(id)
        return not self.entries[id]
    end)

    for _, id in ipairs(unscriptedDataEntryIds) do
        local ok, entryData = pcall(function()
            local entry = self:createEntry(id, Json.decode(love.filesystem.read(Paths.json("stages/" .. id))))
            if entry then
                self.entries[id] = entry
            end
        end)

        if not ok then
            print("Error loading stage data for " .. id .. ": " .. entryData)
        end
    end
end

function StageRegistry:fetchEntry(id)
    for i, entry in pairs(self.entries) do
        if id == i then

            return entry
        end
    end
end

return StageRegistry