local mods = {
    mods = {
        ve = {},
        psych = {},
        list = {}
    }
}

-- create a folder called "mods" if it doesn't exist
love.filesystem.createDirectory("mods")

for i, v in ipairs(love.filesystem.getDirectoryItems("mods")) do
    if love.filesystem.getInfo("mods/" .. v, "directory") then
        table.insert(mods.mods.list, v)
    end
end

-- look for pack.json in each mod folder
for i, v in ipairs(mods.mods.list) do
    if love.filesystem.getInfo("mods/" .. v .. "/pack.json") then
        local pack = love.filesystem.read("mods/" .. v .. "/pack.json")
        local pack = json.decode(pack)
        -- check if pack.type exists
        local packtype = pack.type or "psych"
        if packtype == "ve" then
            table.insert(mods.mods.ve, v)
        elseif packtype == "psych" then
            table.insert(mods.mods.psych, v)
        end
    end
end

-- for each psych mod

for i, v in ipairs(mods.mods.psych) do
    -- get all week jsons in mod/weeks
    local weekjsons = love.filesystem.getDirectoryItems("mods/" .. v .. "/weeks")

    -- for each week json
    for i2, week in ipairs(weekjsons) do
        -- if it ends with .json
        if util.endsWith(week, ".json") then
            local weekfile = json.decode(love.filesystem.read("mods/" .. v .. "/weeks/" .. week))

            weekname = weekfile.weekName
            table.insert(weekMeta, {weekName, {}, mods.mods.psych[i]}) -- 3rd param is the mod folder name
            for i = 1, #weekfile.songs do
                table.insert(weekMeta[#weekMeta][2], weekfile.songs[i][1])
            end

            table.insert(weekData, modweek)
        end
    end
end

return mods