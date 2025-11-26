local BaseCharacter = Bopper:extend("BaseCharacter")

function BaseCharacter:new(id, renderType)
    Bopper.new(self, 1.0)
    self.characterId = id
    self.characterName = ""
    self.ignoreExclusionPref = {"sing"}
    self.characterType = "OTHER"
    self.holdTimer = 0
    self.isDead = false
    self.comboNoteCounts = {}
    self.dropNoteCounts = {}
    --self._data = CharacterDataParser:fetchCharacterData(self.id)
    if self._data == nil then
        error("Could not find character data for characterID: " .. tostring(id))
    elseif self._data.renderType ~= renderType then
        error("Character render type mismatch for characterID: " .. tostring(id))
    else
        self.characterName = self._data.name or ""
        self.name = self._data.name or ""
        self.danceEvery = self._data.danceEvery or 1.0
        self.singTimeSteps = self._data.singTime or 4
        self.globalOffsets = self._data.offsets or {0, 0}
        self.flipX = self._data.flipX or false
    end
    self.shouldBop = false
    self.cameraFocusPoint = Point(0, 0)
end

function BaseCharacter:get_characterOrigin()
    local xpos = self.width / 2
    local ypos = self.height
    return Point(xpos, ypos)
end

function BaseCharacter:get_cornerPosition()
    return Point(self.x, self.y)
end

function BaseCharacter:set_cornerPosition(v)
    local xdiff = v.x - self.x
    local ydiff = v.y - self.y
    self.cameraFocusPoint.x = self.cameraFocusPoint.x + xdiff
    self.cameraFocusPoint.y = self.cameraFocusPoint.y + ydiff
    self:set_x(v.x)
    self:set_y(v.y)
end

function BaseCharacter:get_feetPosition()
    local co = self:get_characterOrigin()
    return Point(self.x + co.x, self.y + co.y)
end

function BaseCharacter:set_x(v)
    if v == self.x then
        return
    end

    local diff = v - self.x
    self.cameraFocusPoint.x = self.cameraFocusPoint.x + diff
    self.x = v
end

function BaseCharacter:set_y(v)
    if v == self.y then
        return
    end

    local diff = v - self.y
    self.cameraFocusPoint.y = self.cameraFocusPoint.y + diff
    self.y = v
end

function BaseCharacter:getDeathCameraOffsets()
    if self._data.death then
        return self._data.death.cameraOffsets or {0, 0}
    end

    return {0, 0}
end

function BaseCharacter:getDeathCameraZoom()
    if self._data.death then
        return self._data.death.cameraZoom or 1.0
    end

    return 1.0
end

function BaseCharacter:getDeathPreTransitionDelay()
    if self._data.death then
        return self._data.death.preTransitionDelay or 0.0
    end

    return 0.0
end

function BaseCharacter:getBaseScale()
    return self._data.scale or 1.0
end

function BaseCharacter:getDataFlipX()
    return self._data.flipX or false
end

function BaseCharacter:findCountAnimations(prefix)
    local animNames = self:getAnimationNameList()
    local result = {}

    for _, anim in ipairs(animNames) do
        if string.startsWith(anim, prefix) then
            local comboNum = tonumber(string.sub(anim, #prefix + 1))
            if comboNum ~= nil then
                table.insert(result, comboNum)
            end
        end
    end

    table.sort(result)
    return result
end

return BaseCharacter