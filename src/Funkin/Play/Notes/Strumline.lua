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

    self.holdNotes = SpriteGroup()
    self.holdNotes.zIndex = 20

    self.onNoteIncoming = SpriteGroup()

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
        local child = StrumlineNote(noteStyle, isPlayer, --[[ self.DIRECTIONS[i] ]]table.find(Strumline.DIRECTIONS, i - 1))
        child.x = self.INITIAL_OFFSET
        child.x = child.x + self:getXPos(table.find(Strumline.DIRECTIONS, i - 1))
        child.x = child.x + self.INITIAL_OFFSET
        child.y = 0
        print("child.x: " .. child.x, "child.y: " .. child.y, child.scale.x, child.scale.y)
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

return Strumline