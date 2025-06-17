local StrumlineNote = FunkinSprite:extend()
StrumlineNote.CONFIRM_HOLD_TIME = 0.1
StrumlineNote.DEFAULT_OFFSET = 13

function StrumlineNote:new(noteStyle, isPlayer, direction)
    FunkinSprite.new(self, 0, 0)

    self.isPlayer = isPlayer
    self.forceActive = false
    self.confirmHoldTimer = -1

    self.direction = direction

    self:setup(noteStyle)

    self.animationCallback = self.onAnimationFrame
    self.animationFinishCallback = self.onAnimationFinish

    self.active = true

    self:playAnimation("static", true)
end

function StrumlineNote:onAnimationFrame(name, frameNumber, frameIndex)
end

function StrumlineNote:onAnimationFinished(name)
    if name == "confirm" then
        self.confirmHoldTimer = 0
    end
end

function StrumlineNote:update(dt)
    FunkinSprite.update(self, dt)

    self:centerOrigin()

    if self.confirmHoldTimer >= 0 then
        self.confirmHoldTimer = self.confirmHoldTimer + dt

        if self.confirmHoldTimer >= StrumlineNote.CONFIRM_HOLD_TIME then
            self.confirmHoldTimer = -1
            self:playStatic()
        end
    end
end

function StrumlineNote:setup(noteStyle)
    if noteStyle == nil then
        error("FATAL ERROR: Attempted to initialize PlayState with an invalid NoteStyle.")
    end

    noteStyle:applyStrumlineFrames(self)
    noteStyle:applyStrumlineAnimations(self, self.direction)
    self:play("static", true)

    local scale = noteStyle:getStrumlineScale() or 1
    self.scale.x = scale * 0.7
    self.scale.y = scale * 0.7
    self:updateHitbox()
    --noteStyle:applyStrumlineOffsets(self)

    self:playStatic()
end

function StrumlineNote:playAnimation(name, force, reversed, startFrame)
    self:play(name, force, reversed, startFrame)

    self:centerOffsets()
    self:centerOrigin()
end

function StrumlineNote:playStatic()
    self.active = self.forceActive or self:isAnimationDynamic("static")
    self:playAnimation("static", true)
end

function StrumlineNote:playPress()
    self.active = self.forceActive or self:isAnimationDynamic("press")
    self:playAnimation("press", true)
end

function StrumlineNote:playConfirm()
    self.active = self.forceActive or self:isAnimationDynamic("confirm")
    self:playAnimation("confirm", true)
end

function StrumlineNote:isConfirm()
    return self:getCurrentAnimation():startsWith("confirm")
end

function StrumlineNote:holdConfirm()
    self.active = true

    if self:getCurrentAnimation() == "confirm-hold" then
        return
    elseif self:getCurrentAnimation() == "confirm" then
        if self:isAnimationFinished() then
            self.confirmHoldTimer = -1
            self:playAnimation("confirm-hold", false, false)
        end
    else
        self:playAnimation("confirm", false, false)
    end
end

function StrumlineNote:isAnimationFinished()
    return self.animation.finished
end

function StrumlineNote:getCurrentAnimation()
    if self.animation == nil or self.animation.curAnim == nil then
        return ""
    end

    return self.animation.curAnim.name
end

function StrumlineNote:fixOffsets()
    self:centerOffsets()

    if self:getCurrentAnimation() == "confirm" then
        self.offset.x = self.offset.x - StrumlineNote.DEFAULT_OFFSET
        self.offset.y = self.offset.y - StrumlineNote.DEFAULT_OFFSET
    else
        self:centerOrigin()
    end
end

return StrumlineNote