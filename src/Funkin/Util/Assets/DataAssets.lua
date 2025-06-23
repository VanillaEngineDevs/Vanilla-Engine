local DataAssets = {}

function DataAssets:buildDataPath(path)
    return "assets/data/" .. path
end

function DataAssets:listSongDataFilesInPath(path, suffix)
    suffix = suffix or ".json"

    local queryPath = self:buildDataPath(path)

    local results = {}

    for _, songFolder in ipairs(love.filesystem.getDirectoryItems(queryPath)) do
        -- read files in folder 
        for _, file in ipairs(love.filesystem.getDirectoryItems(queryPath .. songFolder)) do
            if file:endsWith(suffix) then
                local pathNoSuffix = file:sub(1, #file - #suffix)

                table.insert(results, pathNoSuffix)
            end
        end
    end

    print("Found " .. #results .. " data files in " .. queryPath)

    function results:map(callback)
        local newResults = {}

        for i, result in ipairs(self) do
            newResults[i] = callback(result)
        end

        function newResults:filter(callback)
            local filteredResults = {}

            for _, result in ipairs(self) do
                if callback(result) then
                    table.insert(filteredResults, result)
                end
            end

            return filteredResults
        end

        return newResults
    end

    return results
end

function DataAssets:listDataFilesInPath(path, suffix)
    suffix = suffix or ".json"

    local queryPath = self:buildDataPath(path)

    local results = {}

    for _, file in ipairs(love.filesystem.getDirectoryItems(queryPath)) do
        if file:endsWith(suffix) then
            local pathNoSuffix = file:sub(1, #file - #suffix)

            table.insert(results, pathNoSuffix)
        end
    end

    print("Found " .. #results .. " data files in " .. queryPath)

    function results:map(callback)
        local newResults = {}

        for i, result in ipairs(self) do
            newResults[i] = callback(result)
        end

        function newResults:filter(callback)
            local filteredResults = {}

            for _, result in ipairs(self) do
                if callback(result) then
                    table.insert(filteredResults, result)
                end
            end

            return filteredResults
        end

        return newResults
    end

    return results
end

return DataAssets