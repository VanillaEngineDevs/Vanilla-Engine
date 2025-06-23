local NoteStyle = Class:extend()

function NoteStyle:new(id)
    self.id = id
    self._data = self:_fetchData(id)
    print("NoteStyle created with ID: " .. id)
end

function NoteStyle:_fetchData(id)
    local result = NoteStyleRegistry:getInstance():loadEntryFile(id)
    return Json.decode(result.contents)
end

function NoteStyle:getName()
    return self._data.name or "Unknown Note Style"
end

function NoteStyle:getData()
    return self._data
end

function NoteStyle:getFallbackID()
    return self._data.fallback or nil
end

function NoteStyle:getAuthor()
    return self._data.author or "Unknown Author"
end

function NoteStyle:buildNoteSprite(target)
    -- Apply the note sprite frames.
    local atlas = self:buildNoteFrames(false)

    if not atlas then
        error("Could not load spritesheet for note style: " .. self.id)
    end

    target:setFrames(atlas)
    target.antialiasing = not (self._data.assets and self._data.assets.note and self._data.assets.note.isPixel or false)

    self:buildNoteAnimations(target)

    local scale = self._data.assets.note and self._data.assets.note.scale or 1.0
    target.scale.x = scale
    target.scale.y = scale
    target.scale.x, target.scale.y = target.scale.x * 0.7, target.scale.y * 0.7

    target:updateHitbox()
end

function NoteStyle:getAssetLibrary(path)
    return path
end

function NoteStyle:getNoteAssetPath()
    return "notes"
end

function NoteStyle:getStrumAssetPath()
    return "noteStrumline"
end

function NoteStyle:buildNoteFrames(force)
    local noteAssetPath = self:getAssetLibrary(self:getNoteAssetPath())

    if not noteAssetPath then
        error("Note asset path not found for NoteStyle: " .. self.id)
        return nil
    end

    if self.noteFrames and not force then
        return self.noteFrames
    end

    self.noteFrames = Paths.getSparrowAtlas(noteAssetPath)

    if not self.noteFrames then
        error("Could not load note frames for NoteStyle: " .. self.id)
    end

    return self.noteFrames
end

function NoteStyle:buildNoteAnimations(target)
    local leftData = self:fetchNoteAnimationData(Strumline.DIRECTIONS.LEFT)
    if leftData then
        target:addAnimByPrefix("purpleScroll", leftData.prefix or "", leftData.frameRate or 24, leftData.looped or false,
            leftData.flipX, leftData.flipY
        )
    end
    local downData = self:fetchNoteAnimationData(Strumline.DIRECTIONS.DOWN)
    if downData then
        target:addAnimByPrefix("blueScroll", downData.prefix or "", downData.frameRate or 24, downData.looped or false,
            downData.flipX, downData.flipY
        )
    end
    local upData = self:fetchNoteAnimationData(Strumline.DIRECTIONS.UP)
    if upData then
        target:addAnimByPrefix("greenScroll", upData.prefix or "", upData.frameRate or 24, upData.looped or false,
            upData.flipX, upData.flipY
        )
    end
    local rightData = self:fetchNoteAnimationData(Strumline.DIRECTIONS.RIGHT)
    if rightData then
        target:addAnimByPrefix("redScroll", rightData.prefix or "", rightData.frameRate or 24, rightData.looped or false,
            rightData.flipX, rightData.flipY
        )
    end
end

function NoteStyle:applyStrumlineFrames(target)
    local atlas = Paths.getSparrowAtlas(self:getAssetLibrary(self:getStrumAssetPath()))

    if not atlas then
        error("Could not load spritesheet for note style: " .. self.id)
    end

    target:setFrames(atlas)
    target.scale.x = self._data.assets.noteStrumline and self._data.assets.noteStrumline.data and self._data.assets.noteStrumline.data.scale or 1.0
    target.scale.y = target.scale.x
    target.scale.x, target.scale.y = target.scale.x * 0.7, target.scale.y * 0.7

    target.antialiasing = not (self._data.assets.noteStrumline and self._data.assets.noteStrumline.isPixel or false)
end

function NoteStyle:fetchNoteAnimationData(dir)
    local result = nil
    if dir == Strumline.DIRECTIONS.LEFT then
        result = self._data.assets and self._data.assets.note and
            self._data.assets.note.data and self._data.assets.note.data.left
    elseif dir == Strumline.DIRECTIONS.DOWN then
        result = self._data.assets and self._data.assets.note and
            self._data.assets.note.data and self._data.assets.note.data.down
    elseif dir == Strumline.DIRECTIONS.UP then
        result = self._data.assets and self._data.assets.note and
            self._data.assets.note.data and self._data.assets.note.data.up
    elseif dir == Strumline.DIRECTIONS.RIGHT then
        result = self._data.assets and self._data.assets.note and
            self._data.assets.note.data and self._data.assets.note.data.right
    end

    return result
end

local function toNamed(prefix, name)
    return {prefix = prefix.prefix, name = name}
end

function NoteStyle:getStrumlineAnimationData(dir)
    if dir == Strumline.DIRECTIONS.LEFT then
        return {
            toNamed(self._data.assets.noteStrumline.data.leftStatic, "static"),
            toNamed(self._data.assets.noteStrumline.data.leftPress, "press"),
            toNamed(self._data.assets.noteStrumline.data.leftConfirm, "confirm"),
            toNamed(self._data.assets.noteStrumline.data.leftConfirmHold, "confirm-hold")
        }
    elseif dir == Strumline.DIRECTIONS.DOWN then
        return {
            toNamed(self._data.assets.noteStrumline.data.downStatic, "static"),
            toNamed(self._data.assets.noteStrumline.data.downPress, "press"),
            toNamed(self._data.assets.noteStrumline.data.downConfirm, "confirm"),
            toNamed(self._data.assets.noteStrumline.data.downConfirmHold, "confirm-hold")
        }
    elseif dir == Strumline.DIRECTIONS.UP then
        return {
            toNamed(self._data.assets.noteStrumline.data.upStatic, "static"),
            toNamed(self._data.assets.noteStrumline.data.upPress, "press"),
            toNamed(self._data.assets.noteStrumline.data.upConfirm, "confirm"),
            toNamed(self._data.assets.noteStrumline.data.upConfirmHold, "confirm-hold")
        }
    elseif dir == Strumline.DIRECTIONS.RIGHT then
        return {
            toNamed(self._data.assets.noteStrumline.data.rightStatic, "static"),
            toNamed(self._data.assets.noteStrumline.data.rightPress, "press"),
            toNamed(self._data.assets.noteStrumline.data.rightConfirm, "confirm"),
            toNamed(self._data.assets.noteStrumline.data.rightConfirmHold, "confirm-hold")
        }
    end
end

function NoteStyle:getStrumlineScale()
    return self._data.assets.noteStrumline.data.scale
end

function NoteStyle:applyStrumlineAnimations(tgt, dir)
    local anims = self:getStrumlineAnimationData(dir)
    for _, data in ipairs(anims) do
        tgt:addAnimByPrefix(data.name, data.prefix or "", 24, false, false, false)
    end

    tgt:play("static", true)
end

return NoteStyle