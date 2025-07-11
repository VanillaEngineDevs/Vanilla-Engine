local ModuleHandler = Class:extend()
ModuleHandler.moduleCache = {}
ModuleHandler.modulePriorityOrder = {}

function ModuleHandler:loadModuleCache()
    self:clearModuleCache()

    local scriptedModuleClassNames = ScriptedModule:listScriptClasses()

    for _, moduleCls in ipairs(scriptedModuleClassNames) do
        print("Loading module: " .. moduleCls.__ID)
        self:addModuleToCache(moduleCls)
    end

    self:reorderModuleCache()
end

function ModuleHandler:buildModuleCallbacks()
    --
end

function ModuleHandler:onStateSwitchComplete()
    self:callEvent(StateChangeScriptEvent("STATE_CHANGE_END", Game.state, true))
end

function ModuleHandler:addToModuleCache(module)
    self.moduleCache[module.moduleId] = module
end

function ModuleHandler:reorderModuleCache()
    -- sort by priority, then sort by alphabetical order of moduleId if priorities are equal
    local sortedModules = {}
    for _, module in pairs(self.moduleCache) do
        table.insert(sortedModules, module)
    end
    table.sort(sortedModules, function(a, b)
        if a.priority == b.priority then
            return a.moduleId < b.moduleId
        end
        return a.priority < b.priority
    end)

    self.modulePriorityOrder = {}
    for _, module in ipairs(sortedModules) do
        table.insert(self.modulePriorityOrder, module)
    end

    return self.modulePriorityOrder
end

function ModuleHandler:getModule(moduleId)
    return self.moduleCache[moduleId] or nil
end

function ModuleHandler:activateModule(moduleId)
    local module = self:getModule(moduleId)
    if module ~= nil then
        module.active = true
    end
end

function ModuleHandler:deactivateModule(moduleId)
    local module = self:getModule(moduleId)
    if module ~= nil then
        module.active = false
    end
end

function ModuleHandler:clearModuleCache()
    self.moduleCache = {}
    self.modulePriorityOrder = {}
end

function ModuleHandler:callEvent(event)
    for _, module in ipairs(self.modulePriorityOrder) do
        moduleData = self:getModule(module.moduleId)
        if moduleData ~= nil and moduleData.active then
            ScriptEventDispatcher:callEvent(moduleData, event)
        end
    end
end

function ModuleHandler:callOnCreate()
    self:callEvent(ScriptEvent("CREATE", false))
end

return ModuleHandler