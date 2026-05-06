local modmanager = {}

function modmanager:loadMods()
    local modList = love.filesystem._originalGetDirectoryItems("mods")
    for _, mod in ipairs(modList) do
        local info = love.filesystem.getInfo("mods/" .. mod)
        if info and info.type == "directory" then
            if love.filesystem.getInfo("mods/" .. mod .. "/" .. "_polymod_meta.json") then
                local data = json.decode(love.filesystem.read("mods/" .. mod .. "/" .. "_polymod_meta.json"))
                data.path = "mods/" .. mod .. "/"
                table.insert(poly.list, data)

                for _, level in ipairs(love.filesystem._originalGetDirectoryItems("mods/" .. mod .. "/" .. "data/levels")) do
                    if love.filesystem.getInfo("mods/" .. mod .. "/" .. "data/levels/" .. level) then
                        local data = json.decode(love.filesystem.read("mods/" .. mod .. "/" .. "data/levels/" .. level))
                        data.id = level:sub(1, -6)
                        data.mod = poly.list[#poly.list]
                        table.insert(weekData, data)

                        print("Loaded level: " .. data.id)
                    end
                end

                for _, version in ipairs(love.filesystem._originalGetDirectoryItems("mods/" .. mod .. "/" .. "data/versions")) do
                    if love.filesystem.getInfo("mods/" .. mod .. "/" .. "data/versions/" .. version) then
                        local data = json.decode(love.filesystem.read("mods/" .. mod .. "/" .. "data/versions/" .. version))
                        data.extension = version:sub(1, -6)
                        data.mod = poly.list[#poly.list]
                        table.insert(versionData, data)

                        print("Loaded version: " .. data.name)
                    end
                end
            end
        end
    end

    poly:setPriority(nil)
end

return modmanager