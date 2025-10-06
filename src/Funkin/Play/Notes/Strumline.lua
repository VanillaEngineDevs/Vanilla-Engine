local Strumline = SpriteGroup:extend()

Strumline.DIRECTIONS = {
    LEFT = 0,
    DOWN = 1,
    UP = 2,
    RIGHT = 3
}

Strumline.STRUMLINE_SIZE = 104
Strumline.NOTE_SPACING = Strumline.STRUMLINE_SIZE + 8

Strumline.INITIAL_OFFSET = 0.275 * Strumline.STRUMLINE_SIZE
Strumline.NUDGE = 2

Strumline.KEY_COUNT = 4
Strumline.NOTE_SPLASH_CAP = 6

function Strumline:_getRenderDistanceMS()
    return Game.height / Constants.PIXELS_PER_MS
end

function Strumline:new(noteStyle, isPlayer)
    SpriteGroup.new(self)

    self.isPlayer = isPlayer
    self.noteStyle = noteStyle

    self.conductorInUse = Conductor
    self.scrollSpeed = 1

    self.notes = SpriteGroup()
    self.notes.zIndex = 30
    self:add(self.notes)

    self.holdNotes = SpriteGroup()
    self.holdNotes.zIndex = 20

    self.strumlineNotes = SpriteGroup()
    self.strumlineNotes.zIndex = 10
    self:add(self.strumlineNotes)

    self.noteSplashes = SpriteGroup()
    self.noteSplashes.zIndex = 50

    self.noteHoldCovers = SpriteGroup()
    self.noteHoldCovers.zIndex = 40

    self.notesVwoosh = SpriteGroup()
    self.notesVwoosh.zIndex = 31

    self.holdNotesVwoosh = SpriteGroup()
    self.holdNotesVwoosh.zIndex = 21

    self.noteStyle = noteStyle
    self.ghostTapTimer = 0

    self.noteData = {}
    self.nextNoteIndex = -1
    self.heldKeys = {}

    self:refresh()
    self.onNoteIncoming = Signal()
    self:resetScrollSpeed()

    for i = 1, self.KEY_COUNT do
        local child = StrumlineNote(noteStyle, isPlayer, table.find(Strumline.DIRECTIONS, i - 1))
        child.x = self.INITIAL_OFFSET
        child.x = child.x + self:getXPos(table.find(Strumline.DIRECTIONS, i - 1))
        child.x = child.x + self.INITIAL_OFFSET
        child.y = 0
        self.strumlineNotes:add(child)
    end

    for i = 1, self.KEY_COUNT do
        table.insert(self.heldKeys, false)
    end

    self.active = true
end

function Strumline:getXPos(dir)
    if dir == NoteDirection.LEFT then
        return 0
    elseif dir == Strumline.DIRECTIONS.DOWN then
        return 0 + (1 * self.NOTE_SPACING)
    elseif dir == Strumline.DIRECTIONS.UP then
        return 0 + (2 * self.NOTE_SPACING)
    elseif dir == Strumline.DIRECTIONS.RIGHT then
        return 0 + (3 * self.NOTE_SPACING)
    else
        return 0
    end
end

local function compareNoteData(a, b)
    return a.t < b.t
end

function Strumline:applyNoteData(data)
    self.notes:clear()

    self.noteData = table.copy(data)
    self.nextNoteIndex = 1
    table.sort(self.noteData, compareNoteData)
end

function Strumline:resetScrollSpeed()
    local speed = 1
    if PlayState.instance then
        local curChart = PlayState.instance:get_currentChart()
        if curChart and curChart.scrollSpeed then
            speed = curChart.scrollSpeed
        end
    end

    self.scrollSpeed = speed
end

function Strumline:update(dt)
    SpriteGroup.update(self, dt)

    self:updateNotes()
end

function Strumline:updateNotes()
    if #self.noteData == 0 then
        return
    end
    
    local songStart = PlayState.instance.startTimestamp or 0
    local hitWindowStart = self.conductorInUse.songPosition - Constants.HIT_WINDOW_MS
    local renderWindowStart = self.conductorInUse.songPosition + self:_getRenderDistanceMS()
    --printf("Strumline:updateNotes: songStart = %s, hitWindowStart = %s, renderWindowStart = %s", songStart, hitWindowStart, renderWindowStart)
    
    for i = self.nextNoteIndex, #self.noteData do
        local note = self.noteData[i]

        if not note then
            goto continue
        end

        if note.t < songStart or note.t < hitWindowStart then
            -- Note is in the past, skip it.
            --print("Strumline:updateNotes: Skipping note in the past: ", note.t, " < ", songStart, " or ", note.t, " < ", hitWindowStart)
            self.nextNoteIndex = i + 1
            goto continue
        end

        if note.t > renderWindowStart then
            break
        end

        --printf("Strumline:updateNotes: Adding note at index %d with time %s", i, note.t)

        local noteSprite = self:buildNoteSprite(note)
        --[[
            if note.length > 0 then
                noteSprite.holdNoteSprite = self:buildHoldNoteSprite(note)
            end
        ]]

        self.nextNoteIndex = i + 1

        self.onNoteIncoming:dispatch(noteSprite)

        ::continue::
    end

    for i, note in ipairs(self.notes:getObjects()) do
        if not note then
            goto continue
        end

        
        if not note.customPositionData then
            note.x = self:getXPos(note.direction)
            note.y = self.y + self:calculateNoteYPos(note.strumTime) + note.yOffset - note.height*1.5
        end

        local isOffscreen = note.y < -note.height
        if note.handledMiss and isOffscreen then
            self:killNote(note)
        end

        ::continue::
    end
end

--[[
 public function calculateNoteYPos(strumTime:Float):Float
  {
    return
      Constants.PIXELS_PER_MS * (conductorInUse.songPosition - strumTime - Conductor.instance.inputOffset) * scrollSpeed * (Preferences.downscroll ? 1 : -1);
  }]]

function Strumline:calculateNoteYPos(strumTime)
    return Constants.PIXELS_PER_MS * (self.conductorInUse.songPosition - strumTime) * self.scrollSpeed * (-1)
end

function Strumline:killNote(note)
    note.visible = false
    note:kill()
end

function Strumline:buildNoteSprite(note)
    local noteSprite = self:constructNoteSprite()

    if not noteSprite then
        return nil
    end

    --[[ local noteKindStyle = NoteKindManager:getNoteStyle(note.kind, self.noteStyle.id) or self.noteStyle
    noteSprite:setupNoteGraphic(noteKindStyle) ]]
    noteSprite:setupNoteGraphic(self.noteStyle)

    noteSprite:setData(note)
    noteSprite.isEnemy = noteSprite.noteData.d >= 4

    noteSprite.x = self:getXPos(noteSprite.direction)
    if noteSprite.isEnemy then
        noteSprite.x = noteSprite.x - 1280/2
    end
    --[[ noteSprite.x = noteSprite.x + self:getXPos(note.direction)
    noteSprite.x = noteSprite.x - (noteSprite.width - Strumline.STRUMLINE_SIZE) / 2 -- Center it
    noteSprite.x = noteSprite.x - Strumline.NUDGE ]]
    noteSprite.y = self:calculateNoteYPos(note.t)
    --noteSprite.printIfDrawing = true

    --printf("Strumline:buildNoteSprite: x = %s, y = %s", noteSprite.x, noteSprite.y)

    return noteSprite
end

function Strumline:constructNoteSprite()
    local result

    result = NoteSprite(self.noteStyle, 0)

    self.notes:add(result)

    --print(#self.notes.group.members, "notes in Strumline")

    return result
end

function Strumline:hitNote(note, removeNote)
    if removeNote == nil then removeNote = true end

    self:playConfirm(note.direction)
    note.hasBeenHit = true

    if removeNote then
        self:killNote(note)
    else
        note.alpha = 0.5
        --note:desaturate()
    end

    if note.holdNoteSprite ~= nil then
        --
    end
end

function Strumline:playConfirm(direction)
    self:getByDirection(direction):playConfirm()
end

function Strumline:playPress(direction)
    self:getByDirection(direction):playPress()
end

function Strumline:playStatic(direction)
    self:getByDirection(direction):playStatic()
end

function Strumline:getByDirection(direction)
    for _, strum in ipairs(self.strumlineNotes:getObjects()) do
        if strum.direction == direction then
            return strum
        end
    end

    return nil
end

function Strumline:getNotesMayHit()
    return table.filter(self.notes:getObjects(), function(note)
        return note ~= nil and note.alive and not note.hasBeenHit and note.mayHit
    end)
end

function Strumline:pressKey(direction)
    self.heldKeys[direction + 1] = true
end

function Strumline:releaseKey(direction)
    self.heldKeys[direction + 1] = false
end

return Strumline