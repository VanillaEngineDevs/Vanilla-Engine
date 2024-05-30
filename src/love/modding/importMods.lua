local importMods = {}
importMods.storedMods = {}
importMods.storedModsScripts = {}
importMods.inMod = false
importMods.uiHealthbarMod = nil
importMods.uiHealthbarTextMod = nil

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

    if love.filesystem.getInfo("mods/" .. mod .. "/notetypes/") then
        local notetypesList = love.filesystem.getDirectoryItems("mods/" .. mod .. "/notetypes")
        for i, notetype in ipairs(notetypesList) do
            local notetypeData = require(("mods." .. mod .. ".notetypes." .. notetype):gsub("/", "."):gsub(".lua", ""))
            noteTypes[notetypeData.name] = notetypeData
        end
    end

    if love.filesystem.getInfo("mods/" .. mod .. "/scripts/") then
        local scriptsList = love.filesystem.getDirectoryItems("mods/" .. mod .. "/scripts")
        for i, script in ipairs(scriptsList) do
            local scriptData = require(("mods." .. mod .. ".scripts." .. script):gsub("/", "."):gsub(".lua", ""))
            if type(scriptData) == "function" then
                scriptData = {true, script, scriptData}
            elseif type(scriptData) == "boolean" then
                scriptData = {scriptData, script, CONSTANTS.MISC.EMPTY_FUNCTION}
            end
            if #scriptData == 0 then
                scriptData = {false, "unknown", CONSTANTS.MISC.EMPTY_FUNCTION}
            end
            if #scriptData > 1 then
                if scriptData[1] then
                    if scriptData[2] == "uiHealthbarText"then
                        importMods.uiHealthbarTextMod = scriptData[3]
                    elseif scriptData[2] == "uiHealthbar" then
                        importMods.uiHealthbarMod = scriptData[3]
                    end
                end
            end

            if importMods.storedModsScripts[mod] == nil then
                importMods.storedModsScripts[mod] = {}
            end
            table.insert(importMods.storedModsScripts[mod], scriptData)
        end
    end

    table.insert(importMods.storedMods, {
        name = mod,
        path = "mods/" .. mod
    })
end

function importMods.setupScripts()
    local currentMod = importMods.getCurrentMod()

    if importMods.storedModsScripts[currentMod.name] then
        for _, script in ipairs(importMods.storedModsScripts[currentMod.name]) do
            if script[2] == "uiHealthbarText" then
                importMods.lastUiHealthbarTextMod = importMods.uiHealthbarTextMod
                importMods.uiHealthbarTextMod = script[3]
            elseif script[2] == "uiHealthbar" then
                importMods.lastUiHealthbarMod = importMods.uiHealthbarMod
                importMods.uiHealthbarMod = script[3]
                print("Setting uiHealthbar")
            end
        end
    end
end

function importMods.removeScripts()
    importMods.uiHealthbarTextMod = importMods.lastUiHealthbarTextMod
    importMods.uiHealthbarMod = importMods.lastUiHealthbarMod

    importMods.lastUiHealthbarTextMod = nil
    importMods.lastUiHealthbarMod = nil

    print("Removing scripts", importMods.uiHealthbarMod, importMods.uiHealthbarTextMod)
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
    return love.graphics.newImage(path)
end

function getFilePath(path)
    local currentMod = importMods.getCurrentMod()

    if currentMod then
        return currentMod.path .. "/" .. path
    else
        return path
    end
end

return importMods