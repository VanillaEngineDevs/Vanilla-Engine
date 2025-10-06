local Stage = SpriteGroup:extend("Stage")
Stage:implement(IPlayStateScriptedClass)

function Stage:new(stageData)
    SpriteGroup.new(self)

    self.data = stageData or {}
    self.namedProps = {}
    self.boppers = {}
    self.characters = {}
end

function Stage:get_camZoom()
    return self.data.cameraZoom or 1.0
end

function Stage:onCreate(e)
    self:buildStage()
    self:refresh()
end

function Stage:resetStage()
    if self:getBoyfriend() ~= nil then
        self:getBoyfriend():resetCharacter(true)

        local stageCharData = self.data.characters.bf
        local finalScale = self:getBoyfriend():getBaseScale() * stageCharData.scale

        self:getBoyfriend():setScale(finalScale)
        self:getBoyfriend().cameraFocusPoint.x = self:getBoyfriend().cameraFocusPoint.x + stageCharData.cameraOffsets[1]
        self:getBoyfriend().cameraFocusPoint.y = self:getBoyfriend().cameraFocusPoint.y + stageCharData.cameraOffsets[2]
    else
        print("STAGE RESET: No boyfriend found in stage data.")
    end

    if self:getGirlfriend() ~= nil then
        self:getGirlfriend():resetCharacter(true)

        local stageCharData = self.data.characters.gf
        local finalScale = self:getGirlfriend():getBaseScale() * stageCharData.scale

        self:getGirlfriend():setScale(finalScale)
        self:getGirlfriend().cameraFocusPoint.x = self:getGirlfriend().cameraFocusPoint.x + stageCharData.cameraOffsets[1]
        self:getGirlfriend().cameraFocusPoint.y = self:getGirlfriend().cameraFocusPoint.y + stageCharData.cameraOffsets[2]
    else
        print("STAGE RESET: No girlfriend found in stage data.")
    end

    if self:getDad() ~= nil then
        self:getDad():resetCharacter(true)

        local stageCharData = self.data.characters.dad
        local finalScale = self:getDad():getBaseScale() * stageCharData.scale

        self:getDad():setScale(finalScale)
        self:getDad().cameraFocusPoint.x = self:getDad().cameraFocusPoint.x + stageCharData.cameraOffsets[1]
        self:getDad().cameraFocusPoint.y = self:getDad().cameraFocusPoint.y + stageCharData.cameraOffsets[2]
    else
        print("STAGE RESET: No dad found in stage data.")
    end

    for name, propData in pairs(self.data.props) do
        local prop = self:getNamedProp(name)
        if prop ~= nil then
            prop.x = propData.position[1]
            prop.y = propData.position[2]
            prop.zIndex = propData.zIndex or 0
        end
    end
end

function Stage:buildStage()
    printf("BUILDING STAGE FOR: %s", self.data.name)

    for name, propData in pairs(self.data.props) do
        local isSolidColor = propData.assetPath:startsWith("#")
        local isAnimated = #propData.animations > 0

        local propSprite

        if propData.danceEvery ~= 0 then
            propSprite = Bopper(propData.danceEvery)
            --goto continue
        else
            propSprite = StageProp(name)
        end

        if isAnimated then
            if propData.animType == "packer" then
                --propData.loadPacker(propData.assetPath)
            else
                print(propData.assetPath)
                propSprite:loadSparrow(propData.assetPath)
            end
        elseif isSolidColor then
            local w, h = 1, 1
        else
            propSprite:loadTexture(propData.assetPath)

            propData.active = false
        end

        propSprite.x, propSprite.y = propData.position[1], propData.position[2]

        propSprite.alpha = propData.alpha or 1
        propSprite.antialiasing = not propData.isPixel

        propSprite.scale.x, propSprite.scale.y = propData.scale[1] or 1, propData.scale[2] or 1
        propSprite.scrollFactor.x, propSprite.scrollFactor.y = propData.scroll[1] or 1, propData.scroll[2] or 1
        propSprite.angle = propData.angle or 0
        --propSprite.color = Color.fromString(propData.color or "#FFFFFF")

        propSprite.zIndex = propData.zIndex or 0

        propSprite.flipX, propSprite.flipY = propData.flipX or false, propData.flipY or false

        if not isSolidColor then
            if propData.animType == "packer" then
                for _, anim in ipairs(propData.animations) do
                    propSprite:addAnimByFrames(anim.name, anim.frameIndices)

                    if propSprite:isInstanceOf(Bopper) then
                        propSprite:setAnimationOffsets(anim.name, anim.offsets[1] or 0, anim.offsets[2] or 0)
                    end
                end
            else
                for _, anim in pairs(propData.animations) do
                    anim.offsets = anim.offsets or {0, 0}
                    if anim.frameIndices == nil or #anim.frameIndices <= 0 then
                        propSprite:addAnimByPrefix(anim.name, anim.prefix, tonumber(anim.framerate), anim.looped)
                        propSprite:setAnimationOffsets(anim.name, anim.offsets[1] or 0, anim.offsets[2] or 0)
                    else
                        propSprite:addAnimByIndices(anim.name, anim.prefix, anim.frameIndices, tonumber(anim.framerate), anim.looped)
                        propSprite:setAnimationOffsets(anim.name, anim.offsets[1] or 0, anim.offsets[2] or 0)
                    end
                end
            end
        end

        if propData.startingAnimation ~= nil then
            propSprite:play(propData.startingAnimation)
        end

        if propSprite:isInstanceOf(Bopper) then
            self:addBopper(propSprite, propData.name)
        else
            self:addProp(propSprite, propData.name)
        end

        propSprite:updateHitbox()

        --::continue::
    end
end

function Stage:addBopper(bopper, name)
    name = name or ("bopper_" .. #self.boppers + 1)
    table.insert(self.boppers, bopper)
    self:addProp(bopper, name)
    bopper.name = name
end

function Stage:addProp(prop, name)
    if name ~= nil then
        self.namedProps[name] = prop
        prop.name = name
    end
    self:add(prop)
end

function Stage:dispatchToCharacters(event, event2)

end

function Stage:dispatchToBoppers(event)
    for _, bopper in ipairs(self.boppers) do
        self:dispatchToBopper(bopper, event)
    end
end

function Stage:dispatchToBopper(bopper, event)
    ScriptEventDispatcher:callEvent(bopper, eventClone)
end

function Stage:getCharacter(name)
    return self.characters[name] or nil
end

function Stage:getBoyfriend(pop)
    local boyfriend = self:getCharacter("bf")

    if pop then
        self:remove(boyfriend)
        self.characters["bf"] = nil
    end

    return boyfriend
end

function Stage:getGirlfriend(pop)
    local girlfriend = self:getCharacter("gf")

    if pop then
        self:remove(girlfriend)
        self.characters["gf"] = nil
    end

    return girlfriend
end

function Stage:getDad(pop)
    local dad = self:getCharacter("dad")

    if pop then
        self:remove(dad)
        self.characters["dad"] = nil
    end

    return dad
end

function Stage:getOpponent(pop)
    return self:getDad(pop)
end

function Stage:onScriptEvent(event)
    for _, bopper in ipairs(self.boppers) do
        ScriptEventDispatcher:callEvent(bopper, event)
    end
end

function Stage:onNoteHit(event)
    for _, bopper in ipairs(self.boppers) do
        ScriptEventDispatcher:callEvent(bopper, event)
    end
end

function Stage:onNoteMiss(event)
    for _, bopper in ipairs(self.boppers) do
        ScriptEventDispatcher:callEvent(bopper, event)
    end
end

function Stage:onNoteGhostMiss(event)
    for _, bopper in ipairs(self.boppers) do
        ScriptEventDispatcher:callEvent(bopper, event)
    end
end

return Stage