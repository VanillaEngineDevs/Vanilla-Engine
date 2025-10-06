local Module = Class:extend()
Module:implement(IPlayStateScriptedClass, IStateChangingScriptedClass)

function Module:new(moduleId, priority)
    self.active = true
    self.moduleId = moduleId or "UNKNOWN"
    self.priority = priority or 1000
end

function Module:onNoteHit(event) end

return Module