---@class TransitionableState : State
local TransitionableState = State:extend()

TransitionableState.defaultTransIn = nil
TransitionableState.defaultTransOut = nil

function TransitionableState:new(transIn, transOut)
    self.skipNextTransIn = false
    self.skipNextTransOut = false

    self.transIn = nil
    self.transOut = nil

    self.hasTransIn = false
    self.hasTransOut = false

    if self.transIn == nil and TransitionableState.defaultTransIn ~= nil then
        self.transIn = TransitionableState.defaultTransIn
    end
    if self.transOut == nil and TransitionableState.defaultTransOut ~= nil then
        self.transOut = TransitionableState.defaultTransOut
    end

    self.transOutFinished = false
    self._exiting = false
    self._onExit = nil

    State.new(self)
end

function TransitionableState:create()
    State.create(self)
    self:transitionIn()
end

function TransitionableState:transitionIn()
    if self.transIn ~= nil and self.transIn.type ~= "NONE" then

    end
end

function TransitionableState:transitionOut()
    if self.transOut ~= nil and self.transOut.type ~= "NONE" then

    end
end

function TransitionableState:createTransition(data)

end

function TransitionableState:finishTransIn()
    self:closeSubState()
end

function TransitionableState:finishTransOut()
    self.transOutFinished = true
    if self._exiting then self:closeSubState() end

    if self._onExit then self._onExit() end
end

return TransitionableState