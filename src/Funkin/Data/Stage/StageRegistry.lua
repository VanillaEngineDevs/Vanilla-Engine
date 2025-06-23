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
end

function StageRegistry:loadEntries()
    self:clearEntries()

    local entryIdList = DataAssets:listDataFilesInPath("stages/"):map(function(stageDataPath)
        return stageDataPath:split("/")[1]
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
            print("Error loading stage data for " .. id .. ": " .. entryData)
        end
    end
end

return StageRegistry