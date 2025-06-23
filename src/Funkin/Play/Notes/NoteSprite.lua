local NoteSprite = FunkinSprite:extend("NoteSprite")

NoteSprite.DIRECTION_COLORS = {"purple", "blue", "green", "red"}

function NoteSprite:new(noteStyle, direction)
    FunkinSprite.new(self, 0, 0)
    self.holdNoteSprite = nil
    self.noteData = nil
    self.isHoldNote = false
    self.direction = direction or 0

    self.yOffset = 0
    self.hasBeenHit = false
    self.lowPriority = false
    self.hasMissed = false
    self.tooEarly = false
    self.mayHit = false
    self.handledMiss = false

    self.hsvShader = nil

    self:setupNoteGraphic(noteStyle)
end

function NoteSprite:setupNoteGraphic(noteStyle)
    noteStyle:buildNoteSprite(self)

    self.active = true
end

function NoteSprite:setData(data)
    self.noteData = data
    self.strumTime = data.t
    self.direction = data.d % 4

    self:playNoteAnimation(self.direction)
end

function NoteSprite:getParam(name)
    for _, param in pairs(self.noteData.params or {}) do
        if param.name == name then
            return param.value
        end
    end

    return nil
end

function NoteSprite:playNoteAnimation(v)
    self:play(NoteSprite.DIRECTION_COLORS[v + 1] .. "Scroll")
end

function NoteSprite:revive()
    FunkinSprite.revive(self)

    self.visible = true
    self.alpha = 1
    self.active = false
    self.tooEarly = false
    self.hasBeenHit = false
    self.mayHit = false
    self.hasMissed = false
end

return NoteSprite