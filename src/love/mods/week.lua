local psychweek
local enemyOffsets, boyfriendOffsets, girlfriendOffsets = {}, {}, {}
empty = ''
downscroll = settings.downscroll
local flixelTweenTypes = {
    ["linear"] = "linear",
    ["sineIn"] = "in-sine",
    ["sineOut"] = "out-sine",
    ["sineInOut"] = "in-out-sine",
    ["quadIn"] = "in-quad",
    ["quadOut"] = "out-quad",
    ["quadInOut"] = "in-out-quad",
    ["cubicIn"] = "in-cubic",
    ["cubicOut"] = "out-cubic",
    ["cubicInOut"] = "in-out-cubic",
    ["quartIn"] = "in-quart",
    ["quartOut"] = "out-quart",
    ["quartInOut"] = "in-out-quart",
    ["quintIn"] = "in-quintic",
    ["quintOut"] = "out-quintic",
    ["quintInOut"] = "in-out-quintic",
    ["expoIn"] = "in-expo",
    ["expoOut"] = "out-expo",
    ["expoInOut"] = "in-out-expo",
    ["circIn"] = "in-circ",
    ["circOut"] = "out-circ",
    ["circInOut"] = "in-out-circ",
    ["elasticIn"] = "in-elastic",
    ["elasticOut"] = "out-elastic",
    ["elasticInOut"] = "in-out-elastic",
    ["backIn"] = "in-back",
    ["backOut"] = "out-back",
    ["backInOut"] = "in-out-back",
    ["bounceIn"] = "in-bounce",
    ["bounceOut"] = "out-bounce",
    ["bounceInOut"] = "in-out-bounce"
}
sineIn = "sineIn"
sineOut = "sineOut"
sineInOut = "sineInOut"
quadIn = "quadIn"
quadOut = "quadOut"
quadInOut = "quadInOut"
cubicIn = "cubicIn"
cubicOut = "cubicOut"
cubicInOut = "cubicInOut"
quartIn = "quartIn"
quartOut = "quartOut"
quartInOut = "quartInOut"
quintIn = "quintIn"
quintOut = "quintOut"
quintInOut = "quintInOut"
expoIn = "expoIn"
expoOut = "expoOut"
expoInOut = "expoInOut"
circIn = "circIn"
circOut = "circOut"
circInOut = "circInOut"
elasticIn = "elasticIn"
elasticOut = "elasticOut"
elasticInOut = "elasticInOut"
backIn = "backIn"
backOut = "backOut"
backInOut = "backInOut"
bounceIn = "bounceIn"
bounceOut = "bounceOut"
bounceInOut = "bounceInOut"

camGame = xmlcamera()
camGame.follow = {x=0, y=0}
camGame.target = {x=0, y=0}
camHud = xmlcamera()
other = camHud
local function tryExcept(f1, f2)
    local ok, err = pcall(f1)
    if not ok then
        f2(err)
    end

    print(err)
end
customEvents = {}
function getImage(key)
    local key = key .. ".png"
    if graphics.cache[key] then
        return graphics.cache[key]
    else
        local img = love.graphics.newImage(key)
        graphics.cache[key] = img
        return img
    end

    return nil
end
function getSparrow(key)
    local ip, xp = key, key .. ".xml"
    local i = getImage(ip)
    if love.filesystem.getInfo(xp) then
        local o = Sprite.getFramesFromSparrow(i, love.filesystem.read(xp))
        return o
    end

    return nil
end

local stagesprs = {}
local sprnames = {}
local textnames = {}
local stagetexts = {}
local frontstagesprs = {}
local tt = {} -- tween timers

function makeLuaSprite(name, path, x, y)
    pcall(
        function()
            local spr = Sprite()
            if path ~= "" and path ~= "empty" or path == nil then
                local path = "mods/" .. weekMeta[psychweek][3] .. "/images/" .. path
                spr:load(getImage(path))
            end
            spr.x = x
            spr.y = y
            spr.camera = camGame
            sprnames[name] = spr
            return spr
        end
    )
end
function addLuaSprite(name, front)
    -- adds a makeLuaSprite object to the stage
    local ok, err = pcall(
        function()
            if not front then
                table.insert(stagesprs, sprnames[name])
            else
                table.insert(frontstagesprs, sprnames[name])
            end
        end
    )
    
end
function removeLuaSprite(name)
    -- removes a makeLuaSprite object from the stage
    for i, v in ipairs(stagesprs) do
        if v == sprnames[name] then
            table.remove(stagesprs, i)
        end
    end
end
function makeAnimatedLuaSprite(name, path, x, y)
    local ok, err = pcall(
        function()
            local spr = Sprite()
            local path = "mods/" .. weekMeta[psychweek][3] .. "/images/" .. path
            spr:setFrames(getSparrow(path))
            spr.x = x
            spr.y = y
            spr.camera = camGame
            sprnames[name] = spr
            return spr
        end
    )
end
function setLuaSpriteScrollFactor(name, x, y)
    pcall(
        function()
            sprnames[name].scrollFactor.x = x
            sprnames[name].scrollFactor.y = y
        end
    )
end
setScrollFactor = setLuaSpriteScrollFactor
function scaleObject(name, x, y, updateHitbox)
    pcall(
        function()
            sprnames[name].scale.x = x
            sprnames[name].scale.y = y
            if updateHitbox then
                sprnames[name]:updateHitbox()
            end
        end
    )
end
function makeGraphic(name, width, height, color)
    local ok, err = pcall(
        function()
            sprnames[name]:makeGraphic(width, height, color)
        end
    )
end
function setProperty(name, value)
    -- name is given as 'name.property'
    -- can also be given as 'V1.scale.x' tho
    pcall(
        function()
            local name = util.split(name, ".")
            if name[1] == "camFollowPos" then
                camGame.follow[name[2]] = value
            elseif name[1] == "dad" then
                enemy[name[2]] = value
            elseif name[1] == "gf" then
                girlfriend[name[2]] = value
            else
                sprnames[name[1]][name[2]] = value
            end
        end
    ) 
end
function screenCenter(name, value)
    pcall(
        function()
            stagesprs[name]:screenCenter(value)
        end
    )
end
function addAnimationByPrefix(sprname, name, prefix, fps, loop)
    local ok, err = pcall(
        function()
            sprnames[sprname]:addAnimByPrefix(name, prefix, fps, loop)
        end
    )
end
function addAnimationByIndices(sprname, name, indices, fps, loop)
    pcall(
        function() end
    )
end
function objectPlayAnimation(name, anim, force)
    local ok, err = pcall(
        function()
            local force = force or true
            sprnames[name]:animate(anim, force)
        end
    )
end
function setObjectCamera(name, cameraname)
    pcall(
        function()
            -- cameraname comes as a string, so we need to convert it to a camera object
            cameraname = _G[cameraname]
            sprnames[name].camera = cameraname
        end
    )
end
function doTweenAlpha(tweenName, name, value, time, tweenType)
    tweenType = flixelTweenTypes[tweenType]
    local ok, err = pcall(
        function()
            local tweenName = tweenName
            if tt[tweenName] then
                Timer.cancel(tt[tweenName])
                tt[tweenName] = nil
            end
            if name ~= "boyfriend" and name ~= "dad" and name ~= "gf" then
                tt[tweenName] = Timer.tween(tonumber(time), sprnames[name], {alpha = tonumber(value)}, tweenType)
            else
                if name == "boyfriend" then
                    tt[tweenName] = Timer.tween(tonumber(time), boyfriend, {alpha = tonumber(value)}, tweenType)
                elseif name == "dad" then
                    tt[tweenName] = Timer.tween(tonumber(time), enemy, {alpha = tonumber(value)}, tweenType)
                elseif name == "gf" then
                    tt[tweenName] = Timer.tween(tonumber(time), girlfriend, {alpha = tonumber(value)}, tweenType)
                end
            end
        end
    )
end
function close()
    -- is a function for some reason but does really nothing tbh
end
function doTweenColor(tweenName, name, value, time, tweenType)
    tweenType = flixelTweenTypes[tweenType]
    local ok, err = pcall(
        function()
            value = hex2rgb(value)
            local tweenName = tweenName .. name
            if tt[tweenName] then
                Timer.cancel(tt[tweenName])
                tt[tweenName] = nil
            end
            if name ~= "boyfriend" and name ~= "dad" and name ~= "gf" then
                tt[tweenName] = Timer.tween(tonumber(time), sprnames[name], {color = value}, tweenType)
            else
                if name == "boyfriend" then
                    tt[tweenName] = Timer.tween(tonumber(time), boyfriend, {color = value}, tweenType)
                elseif name == "dad" then
                    tt[tweenName] = Timer.tween(tonumber(time), enemy, {color = value}, tweenType)
                elseif name == "gf" then
                    tt[tweenName] = Timer.tween(tonumber(time), girlfriend, {color = value}, tweenType)
                end
            end
        end
    )

    print(err)
end

function doTweenY(tweenName, name, pos, time, tweenType)
    tweenType = flixelTweenTypes[tweenType]
    local ok, err = pcall(
        function()
            local tweenName = tweenName .. name
            if tt[tweenName] then
                Timer.cancel(tt[tweenName])
                tt[tweenName] = nil
            end
            if name ~= "boyfriend" and name ~= "dad" and name ~= "gf" then
                tt[tweenName] = Timer.tween(tonumber(time), sprnames[name], {y = tonumber(pos)}, tweenType)
            else
                if name == "boyfriend" then
                    tt[tweenName] = Timer.tween(tonumber(time), boyfriend, {y = tonumber(pos)}, tweenType)
                elseif name == "dad" then
                    tt[tweenName] = Timer.tween(tonumber(time), enemy, {y = tonumber(pos)}, tweenType)
                elseif name == "gf" then
                    tt[tweenName] = Timer.tween(tonumber(time), girlfriend, {y = tonumber(pos)}, tweenType)
                end
            end
        end
    )
end

textStr = ""
textColor = {1, 1, 1}
function makeLuaText(name, text, posX, posY, limit)
    local text = {
        name = name,
        text = text,
        x = posX,
        y = posY,
        limit = limit,
        color = {1,1,1},
        align = "left",
        size = 24 -- 24px is the default size
    }

    table.insert(textnames, text)
end
function addLuaText(name)
    local ok, err = pcall(
        function()
            table.insert(stagetexts, textnames[name])
        end
    )
end
function setTextSize(name, size)
    local ok, err = pcall(
        function()
            textnames[name].size = size -- size in px
        end
    )
end
function setTextString(name, value)
    local ok, err = pcall(
        function()
            textnames[name].text = value
        end
    )
end
function setTextColor(name, value)
    local ok, err = pcall(
        function()
            textnames[name].color = hex2rgb(value)
        end
    )
end
function setTextAlignment(name, value)
    local ok, err = pcall(
        function()
            textnames[name].align = value
        end
    )
end

function getPropertyFromGroup(group, name, property)
    if group == "strumLineNotes" then
        if tonumber(name) then
            name = name + 1
            if name < 5 then
                -- enemy arrows
                if property == "x" then
                    return 0
                elseif property == "y" then
                    return 0
                end
            else
                name = name - 4
                -- boyfriend arrows
                if property == "x" then
                    return 0
                elseif property == "y" then
                    return 0
                end
            end
        end
    elseif group == "playerStrums" then
        if tonumber(name) then
            name = name + 1

            return 0
        end
    elseif group == "opponentStrums" then
        if tonumber(name) then
            name = name + 1

            return 0
        end
    end
end

function setPropertyFromGroup(group, name, property, value)
    if group == "strumLineNotes" then
        if tonumber(name) then
            name = name + 1
            if name < 5 then
                -- enemy arrows
                if property == "x" then
                    enemyArrows[name].offsetX = value
                    for i = 1, #enemyNotes[name] do
                        enemyNotes[name][i].offsetX = value
                    end
                elseif property == "y" then
                    enemyArrows[name].offsetY = value
                    for i = 1, #enemyNotes[name] do
                        enemyNotes[name][i].offsetY = value
                    end
                end
            else
                name = name - 4
                -- boyfriend arrows
                if property == "x" then
                    boyfriendArrows[name].offsetX = value
                    for i = 1, #boyfriendNotes[name] do
                        boyfriendNotes[name][i].offsetX = value
                    end
                elseif property == "y" then
                    boyfriendArrows[name].offsetY = value
                    for i = 1, #boyfriendNotes[name] do
                        boyfriendNotes[name][i].offsetY = value
                    end
                end
            end
        end
    else

    end
end

function noteTweenY(tweenName, index, pos, time, tweenType)
    tweenType = flixelTweenTypes[tweenType]
    local ok, err = pcall(
        function()
            index = index + 1
            if index < 5 then
                -- enemy arrows
                tt[tweenName .. index] = Timer.tween(tonumber(time), enemyArrows[index], {offsetY = tonumber(pos)}, tweenType)
                for i = 1, #enemyNotes[index] do
                    tt[tweenName .. index .. "note" .. i] = Timer.tween(tonumber(time), enemyNotes[index][i], {offsetY = tonumber(pos)}, tweenType)
                end
            else
                index = index - 4
                -- boyfriend arrows
                tt[tweenName .. index] = Timer.tween(tonumber(time), boyfriendArrows[index], {offsetY = tonumber(pos)}, tweenType)
                for i = 1, #boyfriendNotes[index] do
                    tt[tweenName .. index .. "note" .. i] = Timer.tween(tonumber(time), boyfriendNotes[index][i], {offsetY = tonumber(pos)}, tweenType)
                end
            end
        end
    )
end

function noteTweenX(tweenName, index, pos, time, tweenType)
    tweenType = flixelTweenTypes[tweenType]
    local ok, err = pcall(
        function()
            index = index + 1
            if index < 5 then
                -- enemy arrows
                tt[tweenName .. index] = Timer.tween(tonumber(time), enemyArrows[index], {offsetX = tonumber(pos)}, tweenType)
                for i = 1, #enemyNotes[index] do
                    tt[tweenName .. index .. "note" .. i] = Timer.tween(tonumber(time), enemyNotes[index][i], {offsetX = tonumber(pos)}, tweenType)
                end
            else
                index = index - 4
                -- boyfriend arrows
                tt[tweenName .. index] = Timer.tween(tonumber(time), boyfriendArrows[index], {offsetX = tonumber(pos)}, tweenType)
                for i = 1, #boyfriendNotes[index] do
                    tt[tweenName .. index .. "note" .. i] = Timer.tween(tonumber(time), boyfriendNotes[index][i], {offsetX = tonumber(pos)}, tweenType)
                end
            end
        end
    )
end

function getPropertyFromClass(class, prop)
    if class == "Conductor" then
        if prop == "songPosition" then
            return musicTime
        else
            return 0
        end
    elseif class == "ClientPrefs" then
        if prop == "downScroll" then
            return settings.downscroll
        else
            return 0
        end
    else
        return 0
    end
end

function runTimer(v1, v2)
    tt[v1] = Timer.after(tonumber(v2), function() 
        
    end)
end
function cancelTimer(v1)
    if tt[v1] then
        Timer.cancel(tt[v1])
    end
end

function runHaxeCode()
    -- forget about it. this isn't haxe. this is lua.
end
function addHaxeLibrary()
    -- forget about it. this isn't haxe. this is lua.
end
return {
	enter = function(self, from, songNum, songAppend, weeknum)
        _psychmod = true
		weeks:enter()
        enemyOffsets, boyfriendOffsets, girlfriendOffsets = {}, {}, {}
        boyfriendCamPositions = {x=0,y=0}
        girlfriendCamPositions = {x=0,y=0}
        enemyCamPositions = {x=0,y=0}

        customEvents = {}

		song = songNum
		difficulty = songAppend

		enemyIcon:animate("dad", false)

        psychweek = weeknum

        screenHeight = graphics.getHeight()
        screenWidth = graphics.getWidth()

		self:load()
	end,

	load = function(self)
		weeks:load()

		self:initUI()

        tryExcept(
            function()
                local enemyPath = "mods/" .. weekMeta[psychweek][3] .. "/"
                enemyPath = enemyPath .. "characters/" .. psychenemy .. ".json"
                local enemyJson = json.decode(love.filesystem.read(enemyPath))
                local imagePath = enemyJson.image
                local realPath = "mods/" .. weekMeta[psychweek][3] .. "/images/" .. imagePath
                enemy = Sprite()
                if love.filesystem.getInfo(realPath .. ".png") and love.filesystem.getInfo(realPath .. ".xml") then
                    enemy:setFrames(getSparrow(realPath))
                else
                    enemy:setFrames(getSparrow("images/png/week1/daddy-dearest"))
                end

                enemyOffsets = enemyJson.position
                enemyCamPositions.x = enemyJson.camera_position[1] + 25
                enemyCamPositions.y = enemyJson.camera_position[2] - 75

                enemy.scale.x, enemy.scale.y = enemyJson.scale, enemyJson.scale
                enemy:updateHitbox()

                for i, anim in ipairs(enemyJson.animations) do
                    local animoffsets = anim.offsets
                    local animloop = anim.loop
                    local animname = anim.anim
                    local animfps = anim.fps
                    local animprefix = anim.name
                    local indices = anim.indices

                    if #indices > 0 then
                        enemy:addAnimByIndices(animname, animprefix, indices, animfps, animloop)
                    else
                        enemy:addAnimByPrefix(animname, animprefix, animfps, animloop)
                    end

                    enemy:addOffset(animname, animoffsets[1], animoffsets[2])
                end

                if enemy:isAnimName("idle") then enemy:animate("idle", true)
                else enemy:animate("danceLeft", true) end
            end,

            function()
                enemy = Sprite()
                enemy:setFrames(getSparrow("images/png/week1/daddy-dearest"))
                
                enemy:addAnimByPrefix("idle", "Dad idle dance", 24, false)
                enemy:addAnimByPrefix("singUP", "Dad Sing Note UP", 24, false)
                enemy:addAnimByPrefix("singRIGHT", "Dad Sing Note RIGHT", 24, false)
                enemy:addAnimByPrefix("singDOWN", "Dad Sing Note DOWN", 24, false)
                enemy:addAnimByPrefix("singLEFT", "Dad Sing Note LEFT", 24, false)

                enemy:addOffset("singUP", -6, 50)
                enemy:addOffset("singRIGHT", 0, 27)
                enemy:addOffset("singLEFT", -10, 10)
                enemy:addOffset("singDOWN", 0, -30)

                enemy.singDuration = 6.1
            end
        )
        
        tryExcept(
            function()
                local boyfriendpath = "mods/" .. weekMeta[psychweek][3] .. "/"
                boyfriendpath = boyfriendpath .. "characters/" .. psychboyfriend .. ".json"
                local boyfriendjson = json.decode(love.filesystem.read(boyfriendpath))
                local boyfriendimagepath = boyfriendjson.image
                local boyfriendrealpath = "mods/" .. weekMeta[psychweek][3] .. "/images/" .. boyfriendimagepath
                boyfriend = Sprite()
                if love.filesystem.getInfo(boyfriendrealpath .. ".png") and love.filesystem.getInfo(boyfriendrealpath .. ".xml") then
                    boyfriend:setFrames(getSparrow(boyfriendrealpath))
                else
                    boyfriend:setFrames(getSparrow("images/png/boyfriend"))
                end

                boyfriendOffsets = boyfriendjson.position
                boyfriendCamPositions.x = boyfriendjson.camera_position[1] + 25
                boyfriendCamPositions.y = boyfriendjson.camera_position[2] - 75

                boyfriend.scale.x, boyfriend.scale.y = boyfriendjson.scale, boyfriendjson.scale
                boyfriend:updateHitbox()

                for i, anim in ipairs(boyfriendjson.animations) do
                    local animoffsets = anim.offsets
                    local animloop = anim.loop
                    local animname = anim.anim
                    local animfps = anim.fps
                    local animprefix = anim.name
                    local indices = anim.indices

                    if #indices > 0 then
                        boyfriend:addAnimByIndices(animname, animprefix, indices, animfps, animloop)
                    else
                        boyfriend:addAnimByPrefix(animname, animprefix, animfps, animloop)
                    end

                    boyfriend:addOffset(animname, animoffsets[1], animoffsets[2])
                end

                if boyfriend:isAnimName("idle") then boyfriend:animate("idle", true)
                else boyfriend:animate("danceLeft", true) end
            end,

            function()
                boyfriend = Sprite()
                boyfriend:setFrames(getSparrow("images/png/boyfriend"))

                boyfriend:addAnimByPrefix("idle", "BF idle dance", 24, false)
                boyfriend:addAnimByPrefix("singUP", "BF NOTE UP0", 24, false)
                boyfriend:addAnimByPrefix("singLEFT", "BF NOTE LEFT0", 24, false)
                boyfriend:addAnimByPrefix("singRIGHT", "BF NOTE RIGHT0", 24, false)
                boyfriend:addAnimByPrefix("singDOWN", "BF NOTE DOWN0", 24, false)

                boyfriend:addOffset("idle", -5, 0)
                boyfriend:addOffset("singUP", -46, 28)
                boyfriend:addOffset("singRIGHT", -49, -6)
                boyfriend:addOffset("singLEFT", 3, -7)
                boyfriend:addOffset("singDOWN", -20, -51)
            end
        )

        tryExcept(
            function()
                local girlfriendpath = "mods/" .. weekMeta[psychweek][3] .. "/"
                girlfriendpath = girlfriendpath .. "characters/" .. psychgirlfriend .. ".json"
                local girlfriendjson = json.decode(love.filesystem.read(girlfriendpath))
                local girlfriendimagepath = girlfriendjson.image
                local girlfriendrealpath = "mods/" .. weekMeta[psychweek][3] .. "/images/" .. girlfriendimagepath
                girlfriend = Sprite()
                if love.filesystem.getInfo(girlfriendrealpath .. ".png") and love.filesystem.getInfo(girlfriendrealpath .. ".xml") then
                    girlfriend:setFrames(getSparrow(girlfriendrealpath))
                else
                    girlfriend:setFrames(getSparrow("images/png/girlfriend"))
                end

                girlfriendOffsets = girlfriendjson.position
                girlfriendCamPositions.x = girlfriendjson.camera_position[1]
                girlfriendCamPositions.y = girlfriendjson.camera_position[2]

                girlfriend.scale.x, girlfriend.scale.y = girlfriendjson.scale, girlfriendjson.scale
                girlfriend:updateHitbox()

                for i, anim in ipairs(girlfriendjson.animations) do
                    local animoffsets = anim.offsets
                    local animloop = anim.loop
                    local animname = anim.anim
                    local animfps = anim.fps
                    local animprefix = anim.name
                    local indices = anim.indices

                    if #indices > 0 then
                        girlfriend:addAnimByIndices(animname, animprefix, indices, animfps, animloop)
                    else
                        girlfriend:addAnimByPrefix(animname, animprefix, animfps, animloop)
                    end

                    girlfriend:addOffset(animname, animoffsets[1], animoffsets[2])
                end

                if girlfriend:isAnimName("idle") then girlfriend:animate("idle", true)
                else girlfriend:animate("danceLeft", true) end
            end,
            
            function()
                girlfriend = Sprite()
                girlfriend:setFrames(getSparrow("images/png/girlfriend"))

                girlfriend:addAnimByIndices("danceLeft", "GF Dancing Beat", {
                    30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14
                }, 24, false)
                girlfriend:addAnimByIndices("danceRight", "GF Dancing Beat", {
                    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29
                }, 24, false)
            
                girlfriend:addAnimByIndices("sad", "gf sad", {
                    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12
                }, 24, false)
            
                girlfriend:addOffset("danceLeft", 0, -9)
                girlfriend:addOffset("danceRight", 0, -9)
                girlfriend:addOffset("sad", -2, -21)

                girlfriend.danceSpeed = 1

                girlfriend:animate("danceLeft", true)

                girlfriendOffsets = {0, 0}
                girlfriendCamPositions.x = 0
                girlfriendCamPositions.y = 0
            end
        )

        local stagepath = "mods/" .. weekMeta[psychweek][3] .. "/"
        local ps = psychstage
        stagepath = stagepath .. "stages/" .. psychstage .. ".json"
        stageluapath = stagepath:gsub(".json", ".lua")
        local stagejson = json.decode(love.filesystem.read(stagepath))
        camera.defaultZoom = stagejson.defaultZoom
        
        -- run the stage lua file
        local stage = love.filesystem.load(stageluapath)()
        if onCreate then onCreate() end
        if onUpdate then stageOnUpdate = onUpdate end
        if onUpdatePost then stageOnUpdatePost = onUpdatePost end
        if onBeatHit then stageOnBeatHit = onBeatHit end

        for i, v in ipairs(love.filesystem.getDirectoryItems("mods/" .. weekMeta[psychweek][3] .. "/custom_events")) do
            -- if file ends with .lua
            if v:find(".lua") then
                local event = love.filesystem.load("mods/" .. weekMeta[psychweek][3] .. "/custom_events/" .. v)()
                if onCreate then onCreate(); onCreate = nil end
                if onCreatePost then onCreatePost(); onCreatePost = nil end
                if onSongStart then onSongStart(); onSongStart = nil end
                customEvents[v:gsub(".lua", "")] = {
                    onEvent = onEvent,
                    onUpdate = onUpdate,
                    onSongStart = onSongStart,
                    onTimerCompleted = onTimerCompleted,
                }
            end
        end
        -- now do the same in events/
        for i, v in ipairs(love.filesystem.getDirectoryItems("events")) do
            -- if file ends with .lua
            if v:find(".lua") then
                local event = love.filesystem.load("events/" .. v)()
                if onCreatePost then onCreatePost() end
                if onSongStart then onSongStart() end
                customEvents[v:gsub(".lua", "")] = {
                    onEvent = onEvent,
                    onUpdate = onUpdate,
                    onSongStart = onSongStart,
                }
            end
        end

        enemy.camera, boyfriend.camera, girlfriend.camera = camGame, camGame, camGame
        boyfriend.x, boyfriend.y = stagejson.boyfriend[1] + boyfriendOffsets[1] - 50, stagejson.boyfriend[2] + boyfriendOffsets[2] + 45
        enemy.x, enemy.y = stagejson.opponent[1] + enemyOffsets[1] + 70, stagejson.opponent[2] + enemyOffsets[2] + 30
        girlfriend.x, girlfriend.y = stagejson.girlfriend[1] + girlfriendOffsets[1] + 90, stagejson.girlfriend[2] + girlfriendOffsets[2] + 125

        print(stagejson.boyfriend[1], stagejson.boyfriend[2], " | ", boyfriendOffsets[1], boyfriendOffsets[2], " | ", boyfriend.x, boyfriend.y)

        if not camera.points["enemy"] then 
			if enemy then
				camera:addPoint("enemy", -enemy.x - 100, -enemy.y + 75) 
			end
		end

        table.insert(stagesprs, girlfriend)
        table.insert(stagesprs, boyfriend)
        table.insert(stagesprs, enemy)

		weeks:setupCountdown()
	end,

	initUI = function(self)
		weeks:initUI()

        weeks:generateNotes(nil, psychweek, song, difficulty)
        weeks:generateEvents(nil, psychweek, song, difficulty)

        -- load all .lua scripts in CURSONGFULLPATH
        for i, v in ipairs(love.filesystem.getDirectoryItems(CURSONGFULLPATH)) do
            -- if file ends with .lua
            if v:find(".lua") then
                local event = love.filesystem.load(CURSONGFULLPATH .. "/" .. v)()
                if onCreate then onCreate() end
                if onUpdate then onUpdate() end
                if onSongStart then onSongStart() end
                if onTimerCompleted then onTimerCompleted() end
            end
        end
	end,

	update = function(self, dt)
		weeks:update(dt)

		if health >= 1.595 then
			if enemyIcon:getAnimName() == "dad" then
				enemyIcon:animate("dad losing", false)
			end
		else
			if enemyIcon:getAnimName() == "dad losing" then
				enemyIcon:animate("dad", false)
			end
		end

        if stagesprs.whitebg then
        end
        camGame.zoom = camera.zoom

        camGame.target.x, camGame.target.y = util.coolLerp(camGame.target.x, camGame.follow.x, 0.04), util.coolLerp(camGame.target.y, camGame.follow.y, 0.04)

        if mustHitSection then
            local midPoint = boyfriend:getMidpoint()
            camGame.follow.x = midPoint.x - 100 - boyfriend.cameraPosition.x - boyfriendCamPositions.x
            camGame.follow.y = midPoint.y - 100 + boyfriend.cameraPosition.y + boyfriendCamPositions.y
        else
            local midPoint = enemy:getMidpoint()
            camGame.follow.x = midPoint.x + 150 - enemy.cameraPosition.x - enemyCamPositions.x
            camGame.follow.y = midPoint.y - 100 - enemy.cameraPosition.y + enemyCamPositions.y
        end

        for i, event in ipairs(songEvents) do
            if musicTime > event.time then
                if customEvents[event.n] and customEvents[event.n].onEvent then
                    customEvents[event.n].onEvent(event.n, event.args, event.args2)
                end
                table.remove(songEvents, i)
            end
        end
        
        -- for all in customEvents, do onUpdate
        for i, v in pairs(customEvents) do
            if v.onUpdate then
                v.onUpdate(dt)
            end
        end

        -- for all in sprnames do update
        for i, v in pairs(sprnames) do
            if v.update then
                v:update(dt)
            end
        end

		if not (countingDown or graphics.isFading()) and not (inst:isPlaying()) and not paused then
			if storyMode and song < 3 then
				song = song + 1

				self:load()
			else
				status.setLoading(true)

				graphics:fadeOutWipe(
					0.7,
					function()
						Gamestate.switch(menu)

						status.setLoading(false)
					end
				)
			end
		end

		weeks:updateUI(dt)
        if stageOnUpdate then stageOnUpdate(dt) end
        if stageOnUpdatePost then stageOnUpdatePost(dt) end

        curBeat = beatHandler.getBeat()

        if beatHandler.onBeat() then
            if stageOnBeatHit then stageOnBeatHit() end
        end
	end,

	draw = function(self)
		love.graphics.push()
			love.graphics.scale(camera.zoom, camera.zoom)
            for i, v in ipairs(stagesprs) do
                v:draw()
            end
            for i, v in ipairs(stagetexts) do
                -- convert v.size (its in pixels) to scaling
                love.graphics.push()
                    love.graphics.translate(graphics.getWidth()/2, graphics.getHeight()/2)
                    love.graphics.setColor(v.color)
                    love.graphics.printf(v.text, v.x, v.y, v.limit, "left", 0, v.size / 100)
                    love.graphics.setColor(1, 1, 1, 1)
                love.graphics.pop()
            end
		love.graphics.pop()

        for i, v in ipairs(frontstagesprs) do
            v:draw()
        end

		weeks:drawUI()
	end,

	leave = function(self)
		enemy = nil
		boyfriend = nil
		girlfriend = nil

		graphics.clearCache()

        inst = nil
        voices = nil
        songEvents = {}
        customEvents = {}
        sprnames = {}
        stagesprs = {}
        stagetexts = {}
        frontstagesprs = {}
        stageOnUpdate = nil
        stageOnUpdatePost = nil
        stageOnBeatHit = nil
        stageOnDraw = nil
        stageOnDrawPost = nil

		weeks:leave()
	end
}