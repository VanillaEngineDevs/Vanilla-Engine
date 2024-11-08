local importMods = {}
importMods.storedMods = {}
importMods.storedModsScripts = {}
importMods.storedModsIncludingDisabled = {}
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
            weekDataFile.modNum = #importMods.storedMods + 1
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

function importMods.loadModToAllModsIncludingDisabled(modMeta, path)
    table.insert(importMods.storedModsIncludingDisabled, {
        name = modMeta.name,
        description = modMeta.description,
        enabled = modMeta.enabled,
        creator = modMeta.creator,
        path = path
    })
end


function importMods.getAllModsStages()
    local stagesList = {}
    for i, mod in ipairs(importMods.storedMods) do
        if love.filesystem.getInfo(mod.path .. "/stages/") then
            local stages = love.filesystem.getDirectoryItems(mod.path .. "/stages")
            for i, stage in ipairs(stages) do
                table.insert(stagesList, {
                    name = stage,
                    mod = mod.name
                })
            end
        end
    end
    return stagesList
end

function importMods.getAllMods()
    local modsList = {}
    for i, mod in ipairs(importMods.storedModsIncludingDisabled) do
        table.insert(modsList, mod)
    end
    return modsList
end

function importMods.getModFromIndex(index)
    return importMods.storedModsIncludingDisabled[index]
end

function importMods.getStageFileFromName(name)
    for i, mod in ipairs(importMods.storedMods) do
        if love.filesystem.getInfo(mod.path .. "/stages/" .. name .. ".lua") then
            return love.filesystem.load(mod.path .. "/stages/" .. name .. ".lua")
        end
    end
    return love.filesystem.load("stages/" .. name .. ".lua")
end

-- now sprites/ stuffs
function importMods.getAllModsSprites()
    local spritesList = {}
    for i, mod in ipairs(importMods.storedMods) do
        if love.filesystem.getInfo(mod.path .. "/sprites/") then
            local sprites = love.filesystem.getDirectoryItems(mod.path .. "/sprites")
            for i, sprite in ipairs(sprites) do
                table.insert(spritesList, {
                    name = sprite,
                    mod = mod.name
                })
            end
        end
    end
    return spritesList
end

function importMods.getSpriteFileFromName(name)
    for i, mod in ipairs(importMods.storedMods) do
        if love.filesystem.getInfo(mod.path .. "/" .. name) then
            return love.filesystem.load(mod.path .. "/" .. name)
        end
    end
    return nil
end

function importMods.getModFromSprite(fileName)
    for i, mod in ipairs(importMods.storedMods) do
        if love.filesystem.getInfo(mod.path .. "/" .. fileName) then
            return mod
        end
    end
    return nil
end

function importMods.setupScripts()
    local currentMod = importMods.getCurrentMod()
    if not currentMod then
        return
    end

    if importMods.storedModsScripts[currentMod.name] then
        for _, script in ipairs(importMods.storedModsScripts[currentMod.name]) do
            if script[2] == "uiHealthbarText" then
                importMods.lastUiHealthbarTextMod = importMods.uiHealthbarTextMod
                importMods.uiHealthbarTextMod = script[3]
            elseif script[2] == "uiHealthbar" then
                importMods.lastUiHealthbarMod = importMods.uiHealthbarMod
                importMods.uiHealthbarMod = script[3]
            end
        end
    end
end

function importMods.removeScripts()
    importMods.uiHealthbarTextMod = importMods.lastUiHealthbarTextMod
    importMods.uiHealthbarMod = importMods.lastUiHealthbarMod

    importMods.lastUiHealthbarTextMod = nil
    importMods.lastUiHealthbarMod = nil
end

function importMods.loadAllMods()
    local mods = love.filesystem.getDirectoryItems("mods")
    for i, mod in ipairs(mods) do
        if love.filesystem.getInfo("mods/" .. mod .. "/meta.lua") then
            local meta = love.filesystem.load("mods/" .. mod .. "/meta.lua")()
            if meta.enabled == nil or meta.enabled then
                print("Loading mod: " .. mod)
                importMods.loadMod(mod)
            end
            importMods.loadModToAllModsIncludingDisabled(meta, "mods/" .. mod)
        end
    end
end

function importMods.getCurrentMod()
    return importMods.storedMods[weekData[weekNum].modNum]
end

function importMods.setCurrentMod(mod)
    for i, storedMod in ipairs(importMods.storedMods) do
        if storedMod.name == mod.name then
            weekNum = i + modWeekPlacement
            return
        end
    end
    return nil
end

function importMods.getModFromStage(fileName)
    for i, mod in ipairs(importMods.storedMods) do
        if love.filesystem.getInfo(mod.path .. "/stages/" .. fileName .. ".lua") then
            return mod
        end
    end
    return nil
end

function importMods.rewriteAllMetas(newModMetas)
    for i, mod in ipairs(importMods.storedModsIncludingDisabled) do
        mod.name = newModMetas[i].name
        mod.description = newModMetas[i].description
        mod.enabled = newModMetas[i].enabled
        mod.creator = newModMetas[i].creator

        love.filesystem.write(mod.path .. "/meta.lua", [[
return {
    enabled = ]] .. tostring(mod.enabled) .. [[,
    name = "]] .. mod.name .. [[",
    creator = "]] .. mod.creator .. [[",
    description = "]] .. mod.description .. [["
}
        ]])
    end
end

function importMods.reloadAllMods()
    importMods.storedMods = {}
    importMods.storedModsScripts = {}
    importMods.storedModsIncludingDisabled = {}
    -- update weekMeta, weekDesc, and weekData to remove all mods past modWeekPlacement
    for i = #weekMeta, modWeekPlacement + 1, -1 do
        table.remove(weekMeta, i)
        table.remove(weekDesc, i)
        table.remove(weekData, i)
    end
    importMods.loadAllMods()
end

function loadLuaFile(path)
    local currentMod = importMods.getCurrentMod()
    if not currentMod then
        return love.filesystem.load(path)
    end

    if love.filesystem.getInfo(currentMod.path .. "/" .. path) then
        return love.filesystem.load(currentMod.path .. "/" .. path)
    else
        return love.filesystem.load(path)
    end
end

function loadAudioFile(path)
    local currentMod = importMods.getCurrentMod()

    if not currentMod then
        return love.audio.newSource(path, "stream")
    end

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