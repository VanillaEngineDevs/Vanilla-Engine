local importMods = {}
importMods.storedMods = {}
importMods.inMod = false

function importMods.setup()
    if not love.filesystem.getInfo("mods") then
        love.filesystem.createDirectory("mods")
    end
end

function importMods.loadMod(mod) -- The file name of the mod
    if love.filesystem.getInfo("mods/" .. mod .. "/stages/") then
        local stagesList = love.filesystem.getDirectoryItems("mods/" .. mod .. "/stages")
        for i, stage in ipairs(stagesList) do
            local stageData = require(("mods." .. mod .. ".stages." .. stage):gsub("/", "."):gsub(".lua", ""))
            stages[stageData.name] = stageData
        end
    end

    if love.filesystem.getInfo("mods/" .. mod .. "/weeks/") then
        local weeksList = love.filesystem.getDirectoryItems("mods/" .. mod .. "/weeks")
        for i, week in ipairs(weeksList) do
            local weekDataFile = require(("mods." .. mod .. ".weeks." .. week):gsub("/", "."):gsub(".lua", ""))
            table.insert(weekData, weekDataFile)
            table.insert(weekDesc, weekDataFile.description)
            table.insert(weekMeta, {
                weekDataFile.name,
                weekDataFile.songs
            })
        end
    end

    table.insert(importMods.storedMods, {
        name = mod,
        path = "mods/" .. mod
    })

    print("Loaded mod: " .. mod)
end

function importMods.loadAllMods()
    local mods = love.filesystem.getDirectoryItems("mods")
    for i, mod in ipairs(mods) do
        if love.filesystem.getInfo("mods/" .. mod .. "/meta.lua") then
            local meta = love.filesystem.load("mods/" .. mod .. "/meta.lua")()
            if meta.enabled == nil or meta.enabled then
                importMods.loadMod(mod)
            end
        end
    end
end

function importMods.getCurrentMod()
    return importMods.storedMods[weekNum - modWeekPlacement]
end

function loadLuaFile(path)
    local currentMod = importMods.getCurrentMod()


    if love.filesystem.getInfo(currentMod.path .. "/" .. path) then
        return love.filesystem.load(currentMod.path .. "/" .. path)
    else
        return love.filesystem.load(path)
    end
end

function loadAudioFile(path)
    local currentMod = importMods.getCurrentMod()

    if love.filesystem.getInfo(currentMod.path .. "/" .. path) then
        return love.audio.newSource(currentMod.path .. "/" .. path, "stream")
    else
        return love.audio.newSource(path, "stream")
    end
    --[[ return love.audio.newSource(currentMod.path .. "/" .. path, "stream") ]]
end

function loadImageFile(path)
    local currentMod = importMods.getCurrentMod()

    return love.graphics.newImage(path)
end

function getFilePath(path)
    local currentMod = importMods.getCurrentMod()

    return currentMod.path .. "/" .. path
end

return importMods