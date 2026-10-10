local poly = {}

poly.priority = nil
poly.list = {}

function poly:setPriority(mod)
    if type(mod) == "nil" then
        self.priority = nil
        return
    end

    if type(mod) == "string" then
        for _, m in ipairs(poly.list) do
            if m.name == mod then
                poly.priority = m
                return
            end
        end
    else
        poly.priority = mod
    end
end


local getInfo = love.filesystem.getInfo

local function resolveAsset(fname)
    if type(fname) ~= "string" then
        return fname
    end

    local function tryModAsset(mod)
        if not mod or not mod.path then
            return nil
        end

        local modPath = mod.path .. fname
        if getInfo(modPath) then
            return modPath
        end

        local assetsPath = mod.path .. "assets/" .. fname
        if getInfo(assetsPath) then
            return assetsPath
        end
    end

    local modPath = tryModAsset(poly.priority)
    if modPath then
        return modPath
    end

    for _, mod in ipairs(poly.list) do
        local path = tryModAsset(mod)
        if path then
            return path
        end
    end

    if fname:sub(1, 7) == "assets/" then
        return fname
    end

    return "assets/" .. fname
end

-- filesystem
function love.filesystem.getInfo(file, ...)
    local path = resolveAsset(file)
    local info = getInfo(path, ...)
    if info then
        return info
    end
    return getInfo(file, ...)
end

local read = love.filesystem.read
function love.filesystem.read(file)
    local path = resolveAsset(file)
    if love.filesystem.getInfo(path) then
        return read(path)
    end


    return read(file)
end

local load = love.filesystem.load
function love.filesystem.load(file)
    local path = resolveAsset(file)
    if love.filesystem.getInfo(path) then
        return load(path)
    end
    
    return load(file)
end

local getDirectoryItems = love.filesystem.getDirectoryItems
love.filesystem._originalGetDirectoryItems = getDirectoryItems
function love.filesystem.getDirectoryItems(dir)
    local items = {}
    local seen = {}

    if poly.priority then
        local modPath = poly.priority.path .. dir
        if getInfo(modPath) then
            for _, item in ipairs(getDirectoryItems(modPath)) do
                table.insert(items, item)
                seen[item] = true
            end
        end
    end

    local basePath = "assets/" .. dir
    if getInfo(basePath) then
        for _, item in ipairs(getDirectoryItems(basePath)) do
            if not seen[item] then
                table.insert(items, item)
                seen[item] = true
            end
        end
    end

    -- fallback to normal game filesystem
    if #items == 0 and getInfo(dir) then
        for _, item in ipairs(getDirectoryItems(dir)) do
            table.insert(items, item)
        end
    end

    return items
end

-- audio
local newsource = love.audio.newSource
function love.audio.newSource(file, type)
    return newsource(resolveAsset(file), type)
end

-- graphics
local newfont = love.graphics.newFont
function love.graphics.newFont(file, size)
    return newfont(resolveAsset(file), size)
end

local newimage = love.graphics.newImage
function love.graphics.newImage(fileordata)
    if type(fileordata) == "string" then
        return newimage(resolveAsset(fileordata))
    end

    return newimage(fileordata)
end

local newshader = love.graphics.newShader
function love.graphics.newShader(fileorsource)
    if love.filesystem.getInfo(resolveAsset(fileorsource)) then
        return newshader(resolveAsset(fileorsource))
    end

    return newshader(fileorsource)
end

-- image
local newImageData = love.image.newImageData
function love.image.newImageData(file)
    return newImageData(resolveAsset(file))
end

function poly.loopAllDirectories(path)
    local pathsToCheck = {}
    
    if poly.priority then
        local modPath = poly.priority.path .. path
        if getInfo(modPath) then
            table.insert(pathsToCheck, modPath)
        end
    end

    for _, mod in ipairs(poly.list) do
        if mod ~= poly.priority then
            local modPath = mod.path .. path
            if getInfo(modPath) then
                table.insert(pathsToCheck, modPath)
            end
        end
    end

    local basePath = "assets/" .. path
    if getInfo(basePath) then
        table.insert(pathsToCheck, basePath)
    end

    return pathsToCheck
end

function poly.checkAllDirs(path)
    if poly.priority then
        local modPath = poly.priority.path .. path
        if getInfo(modPath) then
            return true
        end
    end

    for _, mod in ipairs(poly.list) do
        if mod ~= poly.priority then
            local modPath = mod.path .. path
            if getInfo(modPath) then
                return true
            end
        end
    end

    local basePath = "assets/" .. path
    if getInfo(basePath) then
        return true
    end

    return false
end

function poly.getModFromDirectory(path)
    if poly.priority then
        local modPath = poly.priority.path .. path
        if getInfo(modPath) then
            return poly.priority
        end
    end

    for _, mod in ipairs(poly.list) do
        if mod ~= poly.priority then
            local modPath = mod.path .. path
            if getInfo(modPath) then
                return mod
            end
        end
    end

    return nil
end

return poly