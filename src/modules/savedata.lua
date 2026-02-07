---@diagnostic disable: return-type-mismatch, param-type-mismatch

local Settings = {}
local Savedata = {}

local SETTINGS_VERSION = 8
local SETTINGS_FILE = "settings.lua"
local SAVEDATA_FILE = "savedata.lua"

local defaults = {
    hardwareCompression = true,
    downscroll = false,
    ghostTapping = true,
    showDebug = false,
    sideJudgements = false,
    middlescroll = false,
    practiceMode = false,
    noMiss = false,
    customScrollSpeed = 1,
    keystrokes = false,
    scrollUnderlayTrans = 0,
    window = false,
    fpsCap = 60,
    pixelPerfect = false,
    shaders = true,
    scoringType = "KE",
    accuracyMode = "Simple",
    popupScoreMode = "Stack",
    judgePreset = "PBot1",
    flashinglights = false,
    settingsVer = SETTINGS_VERSION
}

local function safeDeserialize(path)
    if love.filesystem.getInfo(path) then
        local ok, data = pcall(lume.deserialize, love.filesystem.read(path))
        if ok and type(data) == "table" then
            return data
        end
    end
    return nil
end

local function save(path, data)
    love.filesystem.write(path, lume.serialize(data))
end

local dataStore = {}

function Settings.load()
    local loaded = safeDeserialize(SETTINGS_FILE)
    if loaded and loaded.settingsVer == SETTINGS_VERSION then
        for k,v in pairs(defaults) do
            dataStore[k] = loaded[k] ~= nil and loaded[k] or v
        end
    else
        love.window.showMessageBox("Uh Oh!", "Settings have been reset to defaults.", "warning")
        Settings.reset()
    end
end

function Settings.save(restartOnChange)
    restartOnChange = restartOnChange ~= false

    local newSettings = {}
    for k, _ in pairs(defaults) do
        newSettings[k] = dataStore[k]
    end
    newSettings.settingsVer = SETTINGS_VERSION

    local currentSerialized = lume.serialize(dataStore)
    local newSerialized = lume.serialize(newSettings)

    if currentSerialized ~= newSerialized then
        save(SETTINGS_FILE, newSettings)
        if restartOnChange then
            love.window.showMessageBox("Settings Saved!", "Settings saved. Restarting Vanilla Engine to apply changes.")
            love.event.quit("restart")
        end
    end
end

function Settings.reset()
    for k,v in pairs(defaults) do
        dataStore[k] = v
    end
    save(SETTINGS_FILE, dataStore)
end

function Settings.get(key)
    return dataStore[key]
end

function Settings.set(key, value)
    dataStore[key] = value
end

local savedataStore = {}

function Savedata.load()
    local loaded = safeDeserialize(SAVEDATA_FILE)
    if loaded then
        for k,v in pairs(loaded) do
            savedataStore[k] = v
        end
    else
        savedataStore = {}
    end
end

function Savedata.save()
    save(SAVEDATA_FILE, savedataStore)
end

function Savedata.get(key)
    return savedataStore[key]
end

function Savedata.set(key, value)
    savedataStore[key] = value
end

Savedata.load()
Settings.load()

local oldSetShader = love.graphics.setShader
local oldNewShader = love.graphics.newShader

function love.graphics.setShader(shader)
    if type(shader) ~= "table" then
        oldSetShader(shader)
    end
end

function love.graphics.newShader(code)
    if dataStore.shaders then
        return oldNewShader(code)
    else
        return { send = function() end }
    end
end

ret = {}

ret.load = function() return Settings.load() end
ret.save = function() return Settings.save() end
ret.reset = function() return Settings.reset() end
ret.savedataSave = function() return Savedata.save() end
ret.savedataLoad = function() return Savedata.load() end

setmetatable(ret, {
    __index = function(_, key)
        local val = Settings.get(key)
        if val ~= nil then return val end
        val = Savedata.get(key)
        return val
    end,
    __newindex = function(_, key, value)
        if Settings.get(key) ~= nil then
            Settings.set(key, value)
        else
            Savedata.set(key, value)
        end
    end
})

return ret
