local psychweek
local enemyOffsets, boyfriendOffsets, girlfriendOffsets = {}, {}, {}
camGame = xmlcamera()
camGame.follow = {x=0, y=0}
camGame.target = {x=0, y=0}
local function tryExcept(f1, f2)
    local ok, err = pcall(f1)
    if not ok then
        f2(err)
    end
end
customEvents = {}
local function getImage(key)
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
local function getSparrow(key)
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
local tt = {} -- tween timers
function makeLuaSprite(name, path, x, y)
    pcall(
        function()
            local spr = Sprite()
            if path ~= "" then
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
function addLuaSprite(name)
    -- adds a makeLuaSprite object to the stage
    pcall(
        function()
            table.insert(stagesprs, sprnames[name])
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
    pcall(
        function()
            local spr = Sprite()
            spr.x = x
            spr.y = y
            spr.camera = camGame
            spr:setFrames(getSparrow(path))
            sprnames[name] = spr
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
function scaleObject(name, x, y)
    pcall(
        function()
            sprnames[name].scale.x = x
            sprnames[name].scale.y = y
            sprnames[name]:updateHitbox()
        end
    )
end
function makeGraphic(name, width, height, color)
    local ok, err = pcall(
        function()
            sprnames[name]:makeGraphic(width, height, color)
        end
    )

    print(ok, err)
end
function setProperty(name, value)
    -- name is given as 'name.property'
    pcall(
        function()
            local name = util.split(name, ".")
            print(name[1], name[2], value)
            sprnames[name[1]][name[2]] = value
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
function doTweenAlpha(tweenName, name, value, time, type)
    local ok, err = pcall(
        function()
            local tweenName = tweenName .. name
            if tt[tweenName] then
                Timer.cancel(tt[tweenName])
                tt[tweenName] = nil
            end
            print(name, value, time, type)
            if name ~= "boyfriend" and name ~= "dad" and name ~= "gf" then
                tt[tweenName] = Timer.tween(tonumber(time), sprnames[name], {alpha = tonumber(value)}, type)
            else
                if name == "boyfriend" then
                    tt[tweenName] = Timer.tween(tonumber(time), boyfriend, {alpha = tonumber(value)}, type)
                elseif name == "dad" then
                    tt[tweenName] = Timer.tween(tonumber(time), enemy, {alpha = tonumber(value)}, type)
                elseif name == "gf" then
                    tt[tweenName] = Timer.tween(tonumber(time), girlfriend, {alpha = tonumber(value)}, type)
                end
            end
        end
    )
end
function doTweenColor(tweenName, name, value, time, type)
    local ok, err = pcall(
        function()
            value = hex2rgb(value)
            local tweenName = tweenName .. name
            if tt[tweenName] then
                Timer.cancel(tt[tweenName])
                tt[tweenName] = nil
            end
            print(name, value, time, type)
            if name ~= "boyfriend" and name ~= "dad" and name ~= "gf" then
                print(sprnames[name])
                tt[tweenName] = Timer.tween(tonumber(time), sprnames[name], {color = value}, type)
            else
                if name == "boyfriend" then
                    tt[tweenName] = Timer.tween(tonumber(time), boyfriend, {color = value}, type)
                elseif name == "dad" then
                    tt[tweenName] = Timer.tween(tonumber(time), enemy, {color = value}, type)
                elseif name == "gf" then
                    tt[tweenName] = Timer.tween(tonumber(time), girlfriend, {color = value}, type)
                end
            end
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
    else

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

function getPropertyFromClass(class, prop)
    if class == "Conductor" then
        if prop == "songPosition" then
            return musicTime
        else
            return 0
        end
    else
        return 0
    end
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

		enemyIcon:animate("daddy dearest", false)

        psychweek = weeknum

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

                girlfriend:animate("danceLeft")
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

        for i, v in ipairs(love.filesystem.getDirectoryItems("mods/" .. weekMeta[psychweek][3] .. "/custom_events")) do
            -- if file ends with .lua
            if v:find(".lua") then
                local event = love.filesystem.load("mods/" .. weekMeta[psychweek][3] .. "/custom_events/" .. v)()
                if onCreatePost then onCreatePost() end
                if onSongStart then onSongStart() end
                customEvents[v:gsub(".lua", "")] = {
                    onEvent = onEvent,
                    onUpdate = onUpdate,
                    onSongStart = onSongStart,
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
	end,

	update = function(self, dt)
		weeks:update(dt)

		if health >= 1.595 then
			if enemyIcon:getAnimName() == "daddy dearest" then
				enemyIcon:animate("daddy dearest losing", false)
			end
		else
			if enemyIcon:getAnimName() == "daddy dearest losing" then
				enemyIcon:animate("daddy dearest", false)
			end
		end

        if stagesprs.whitebg then
        print(stagesprs['whitebg'].alpha)
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
                if customEvents[event.n].onEvent then
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

		if not (countingDown or graphics.isFading()) and not (inst:isPlaying() and voices:isPlaying()) and not paused then
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
	end,

	draw = function(self)
		love.graphics.push()
			love.graphics.scale(camera.zoom, camera.zoom)
            for i, v in ipairs(stagesprs) do
                v:draw()
            end
		love.graphics.pop()

		weeks:drawUI()
	end,

	leave = function(self)
		enemy = nil
		boyfriend = nil
		girlfriend = nil

		graphics.clearCache()

		weeks:leave()
	end
}