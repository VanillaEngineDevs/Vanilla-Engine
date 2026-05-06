local curdir = (...):match("(.-)[^%.]+$")
local class = require(curdir .. "class")

local Interp = class:extend("Interp")

local Stop = {
    Break = "SBreak",
    Continue = "SContinue",
    Return = "SReturn"
}

local function cleanErrorMessage(err)
    local msg = tostring(err)
    while true do
        local stripped = msg:match("^.-:%d+: (.+)$")
        if not stripped then break end
        msg = stripped
    end
    return msg
end

local function arrayLength(t)
    local maxIndex = -1
    for k, _ in pairs(t) do
        if type(k) == "number" and k >= 0 and k % 1 == 0 and k > maxIndex then
            maxIndex = k
        end
    end
    return maxIndex + 1
end

function Interp:new()
    self.locals = {}
    self.variables = {}
    self.declared = {}
    self.binops = {}
    self.importResolver = nil
    self.usingResolver = nil

    self.depth = 0
    self.inTry = false
    self.returnValue = nil

    self:resetVariables()
    self:initOps()
end

function Interp:setImportResolver(resolver)
    self.importResolver = resolver
    return self
end

function Interp:setUsingResolver(resolver)
    self.usingResolver = resolver
    return self
end

function Interp:bindImport(path, value, star, name)
    if star then
        if type(value) ~= "table" then
            error("Star import requires table exports for: " .. tostring(path), 0)
        end

        for k, v in pairs(value) do
            self.variables[k] = v
        end

        return nil
    end

    local targetName = name
    if targetName == nil then
        targetName = tostring(path):match("([^.]+)$")
    end

    if targetName and targetName ~= "" then
        self.variables[targetName] = value
    end

    return value
end

function Interp:resolveImportPath(path)
    local imports = self.variables.import
    if type(imports) ~= "table" then
        return nil
    end

    local direct = imports[path]
    if direct ~= nil then
        return direct
    end

    local current = imports
    for part in tostring(path):gmatch("[^%.]+") do
        if type(current) ~= "table" then
            return nil
        end
        current = current[part]
        if current == nil then
            return nil
        end
    end

    return current
end

function Interp:resolvePath(path)
    local current = self.variables
    for part in tostring(path):gmatch("[^%.]+") do
        if type(current) ~= "table" then
            return nil
        end
        current = current[part]
        if current == nil then
            return nil
        end
    end

    return current
end

function Interp:createClass(name, base)
    local cls = class:extend(name)

    if base ~= nil then
        if type(base) ~= "table" then
            error("Class extends non-table value: " .. tostring(name), 0)
        end

        cls:implement(base)
        cls.base = base
    end

    return cls
end

function Interp:resetVariables()
    self.variables = {
        ["null"] = nil,
        ["true"] = true,
        ["false"] = false,
        ["trace"] = function(...)
            print(...)
        end
    }
end

function Interp:initOps()
    local function op(f)
        return function(e1, e2)
            return f(self:expr(e1), self:expr(e2))
        end
    end

    self.binops["+"]  = op(function(a,b)
        if type(a) == "string" or type(b) == "string" then
            return tostring(a) .. tostring(b)
        else
            return a + b
        end
    end)
    self.binops["-"]  = op(function(a,b) return a - b end)
    self.binops["*"]  = op(function(a,b) return a * b end)
    self.binops["/"]  = op(function(a,b) return a / b end)
    self.binops["%"]  = op(function(a,b) return a % b end)

    self.binops["=="] = op(function(a,b) return a == b end)
    self.binops["!="] = op(function(a,b) return a ~= b end)

    self.binops[">"]  = op(function(a,b) return a > b end)
    self.binops["<"]  = op(function(a,b) return a < b end)
    self.binops[">="] = op(function(a,b) return a >= b end)
    self.binops["<="] = op(function(a,b) return a <= b end)

    self.binops["&&"] = function(e1, e2)
        local v1 = self:expr(e1)
        if not v1 then return false end
        local v2 = self:expr(e2)
        return not not v2
    end
    self.binops["||"] = function(e1, e2)
        local v1 = self:expr(e1)
        if v1 then return true end
        local v2 = self:expr(e2)
        return not not v2
    end
    self.binops["??"] = function(e1, e2)
        local v1 = self:expr(e1)
        if v1 ~= nil then return v1 end
        return self:expr(e2)
    end

    self.binops["="] = function(e1,e2)
        return self:assign(e1,e2)
    end
end

function Interp:setVar(name, v)
    self.variables[name] = v
    return v
end

function Interp:register(name, value)
    return self:setVar(name, value)
end

function Interp:setContext(api)
    if not api then
        return self
    end

    for name, value in pairs(api) do
        self.variables[name] = value
    end

    return self
end

function Interp:getClass(name)
    if type(name) ~= "string" or name == "" then
        error("Class name must be a non-empty string", 0)
    end

    local localSlot = self.locals[name]
    if localSlot ~= nil then
        return localSlot.r
    end

    local direct = self.variables[name]
    if direct ~= nil then
        return direct
    end

    local resolved = self:resolvePath(name)
    if resolved ~= nil then
        return resolved
    end

    error("Unknown class: " .. name, 0)
end

function Interp:call(fn, ...)
    local f = fn
    
    if type(fn) == "string" then
        f = self.variables[fn]
    end
    
    if type(f) ~= "function" then
        --error("Cannot call non-function value: " .. tostring(fn), 0)
        return
    end
    
    return f(...)
end

function Interp:resolve(id)
    if id == "null" then
        return nil
    end

    local v = self.variables[id]

    if v == nil and self.variables[id] == nil then
        error("Unknown variable: "..id, 0)
    end

    return v
end

function Interp:assign(e1, e2)
    local v = self:expr(e2)

    if e1.tag == "EIdent" then
        local id = e1.v
        local l = self.locals[id]

        if l == nil then
            self:setVar(id, v)
        else
            l.r = v
        end
    elseif e1.tag == "EField" then
        local obj = self:expr(e1.e)
        if obj == nil then
            error("Invalid field assignment on nil")
        end
        obj[e1.f] = v
    elseif e1.tag == "EArray" then
        local arr = self:expr(e1.e)
        local index = self:expr(e1.index)
        if type(arr) ~= "table" then
            error("Invalid array assignment on non-table")
        end

        ---@diagnostic disable-next-line: need-check-nil
        arr[index] = v
    else
        error("Invalid assignment")
    end

    return v
end

function Interp:execute(expr)
    self.depth = 0
    self.locals = {}
    self.declared = {}

    return self:exprReturn(expr)
end

function Interp:exprReturn(e)
    local ok, result = pcall(function()
        return self:expr(e)
    end)

    if ok then return result end

    if result == Stop.Return then
        local v = self.returnValue
        self.returnValue = nil
        return v
    end

    error(cleanErrorMessage(result), 0)
end

function Interp:restore(old)
    while #self.declared > old do
        local d = table.remove(self.declared)
        self.locals[d.n] = d.old
    end
end

function Interp:expr(e)
    local t = e.tag

    if t == "EConst" then
        local c = e.c
        if c.tag == "CInt" then
            return c.v
        elseif c.tag == "CFloat" then
            return c.f
        elseif c.tag == "CString" then
            return c.s
        end
        return nil
    end

    if t == "EIdent" then
        local l = self.locals[e.v]

        if l then
            return l.r
        end

        return self:resolve(e.v)
    end

    if t == "EVar" then
        table.insert(self.declared, {
            n = e.n,
            old = self.locals[e.n]
        })

        self.locals[e.n] = {
            r = e.e and self:expr(e.e) or nil
        }

        return nil
    end

    if t == "EFinal" then
        table.insert(self.declared, {
            n = e.n,
            old = self.locals[e.n]
        })

        self.locals[e.n] = {
            r = e.e and self:expr(e.e) or nil
        }

        return nil
    end

    if t == "EParent" then
        return self:expr(e.e)
    end

    if t == "EBlock" then
        local old = #self.declared
        local v = nil

        for _,ex in ipairs(e.e or {}) do
            v = self:expr(ex)
        end

        self:restore(old)

        return v
    end

    if t == "EField" then
        local obj = self:expr(e.e)
        if type(obj) ~= "table" then
            error("Invalid field access on non-table")
        end

        if e.f == "length" then
            local v = rawget(obj, "length")
            if v ~= nil then return v end
            return arrayLength(obj)
        end

        return obj[e.f]
    end

    if t == "EBinop" then
        local f = self.binops[e.op]

        if not f then
            error("Invalid operator "..e.op)
        end

        return f(e.e1, e.e2)
    end

    if t == "EUnop" then
        local v = self:expr(e.e)

        if e.op == "!" then
            return not v
        elseif e.op == "-" then
            return -v
        end
    end

    if t == "EIf" then
        if self:expr(e.cond) then
            return self:expr(e.e1)
        elseif e.e2 then
            return self:expr(e.e2)
        end

        return nil
    end

    if t == "ECall" then
        local receiver = nil
        local f = nil
        local isClassMethod = false

        if e.e.tag == "EField" then
            receiver = self:expr(e.e.e)
            if type(receiver) ~= "table" then
                error("Invalid method call on non-table value")
            end
            f = receiver[e.e.f]
            
            local mt = getmetatable(receiver)
            if type(mt) == "table" and mt[e.e.f] == f then
                isClassMethod = true
            end
        else
            f = self:expr(e.e)
        end

        local args = {}

        for i,p in ipairs(e.params) do
            args[i] = self:expr(p)
        end

        if type(f) == "function" then
            if isClassMethod then
                table.insert(args, 1, receiver)
            end
            return f(unpack(args))
        end

        local mt = type(f) == "table" and getmetatable(f) or nil
        local call = mt and mt.__call or nil
        if type(call) == "function" then
            if isClassMethod then
                table.insert(args, 1, receiver)
            end
            return call(f, unpack(args))
        end

        error("Attempt to call non-function value")
    end

    if t == "EReturn" then
        self.returnValue = e.e and self:expr(e.e) or nil
        error(Stop.Return)
    end

    if t == "EBreak" then
        error(Stop.Break)
    end

    if t == "EContinue" then
        error(Stop.Continue)
    end

    if t == "EArrayDecl" then
        local arr = {}

        for i, v in ipairs(e.e or {}) do
            arr[i - 1] = self:expr(v)
        end

        return arr
    end

    if t == "EArray" then
        local arr = self:expr(e.e)
        local idx = self:expr(e.index)
        if type(arr) ~= "table" then
            error("Invalid array access on non-table")
        end

        return arr[idx]
    end

    if t == "ETernary" then
        if self:expr(e.cond) then
            return self:expr(e.e1)
        else
            return self:expr(e.e2)
        end
    end

    if t == "EThrow" then
        local v = e.e and self:expr(e.e) or nil
        error(v)
    end

    if t == "ETry" then
        local ok, result = pcall(function()
            return self:expr(e.e)
        end)

        if ok then
            return result
        else
            local errorMsg = result
            if type(result) == "string" then
                local stripped = result:match("^[^:]+:%d+: (.+)$")
                if stripped then
                    errorMsg = stripped
                end
            end

            local old = #self.declared
            table.insert(self.declared, {
                n = e.v,
                old = self.locals[e.v]
            })

            self.locals[e.v] = {
                r = errorMsg
            }

            local catchResult = self:expr(e.ecatch)
            self:restore(old)
            return catchResult
        end
    end

    if t == "EWhile" then
        local old = #self.declared
        while self:expr(e.cond) do
            local ok, result = pcall(function()
                return self:expr(e.e)
            end)
            
            if not ok then
                local errStr = tostring(result)
                if errStr:find(Stop.Break, 1, true) then
                    break
                elseif errStr:find(Stop.Continue, 1, true) then
                    -- NEXDT!!!
                elseif errStr:find(Stop.Return, 1, true) then
                    error(result)
                else
                    error(result)
                end
            end
        end
        self:restore(old)
        return nil
    end

    if t == "EFor" then
        local old = #self.declared
        local iterable = self:expr(e.it)
        
        if type(iterable) ~= "table" then
            error("Cannot iterate over non-table value")
        end
        
        table.insert(self.declared, {
            n = e.v,
            old = self.locals[e.v]
        })
        
        local i = 0
        while iterable[i] ~= nil do
            local value = iterable[i]
            self.locals[e.v] = { r = value }
            
            local ok, result = pcall(function()
                return self:expr(e.e)
            end)
            
            if not ok then
                local errStr = tostring(result)
                if errStr:find(Stop.Break, 1, true) then
                    break
                elseif errStr:find(Stop.Continue, 1, true) then
                    -- contiune to the next iter
                elseif errStr:find(Stop.Return, 1, true) then
                    error(result)
                else
                    error(result)
                end
            end
            
            i = i + 1
        end
        
        self:restore(old)
        return nil
    end

    if t == "EFunction" then
        local capturedSelf = self
        local funcArgs = e.args
        local funcBody = e.e
        local funcName = e.name

        local capturedEnv = {}
        for name, slot in pairs(self.locals) do
            capturedEnv[name] = slot
        end
        
        local func = function(...)
            local args = {...}

            local previousLocals = capturedSelf.locals
            local previousDeclared = capturedSelf.declared

            local callLocals = {}
            for name, slot in pairs(capturedEnv) do
                callLocals[name] = slot
            end

            capturedSelf.locals = callLocals
            capturedSelf.declared = {}

            local old = #capturedSelf.declared
            
            for i, arg in ipairs(funcArgs) do
                local argName = arg.name
                local argValue = args[i]
                
                table.insert(capturedSelf.declared, {
                    n = argName,
                    old = capturedSelf.locals[argName]
                })
                
                capturedSelf.locals[argName] = { r = argValue }
            end
            
            local ok, result = pcall(function()
                return capturedSelf:expr(funcBody)
            end)
            
            capturedSelf:restore(old)
            capturedSelf.locals = previousLocals
            capturedSelf.declared = previousDeclared
            
            if not ok then
                local errStr = tostring(result)
                if errStr:find(Stop.Return, 1, true) then
                    local v = capturedSelf.returnValue
                    capturedSelf.returnValue = nil
                    return v
                elseif errStr:find(Stop.Break, 1, true) or errStr:find(Stop.Continue, 1, true) then
                    error(result)
                else
                    error(result)
                end
            end
            
            return result
        end

        if funcName then
            local selfCell = { r = func }
            capturedEnv[funcName] = selfCell
        end
        
        if funcName then
            table.insert(self.declared, {
                n = funcName,
                old = self.locals[funcName]
            })
            self.locals[funcName] = capturedEnv[funcName] or { r = func }
            return nil
        end
        
        return func
    end

    if t == "EObject" then
        local obj = {}
        for _, field in ipairs(e.fl or {}) do
            obj[field.name] = self:expr(field.e)
        end
        return obj
    end

    if t == "EImport" then
        local value = self:resolveImportPath(e.path)

        if value == nil and type(self.importResolver) == "function" then
            value = self.importResolver(e.path, {
                kind = "import",
                star = e.star,
                name = e.name,
            })
        end

        if value == nil then
            error("Unknown import path: " .. tostring(e.path), 0)
        end

        return self:bindImport(e.path, value, e.star, e.name)
    end

    if t == "EUsing" then
        if type(self.usingResolver) == "function" then
            return self.usingResolver(e.path, {
                kind = "using",
            })
        end

        if type(self.importResolver) == "function" then
            return self.importResolver(e.path, {
                kind = "using",
            })
        end

        return nil
    end

    if t == "EClassDecl" then
        local base = nil
        if e.extend ~= nil then
            base = self:resolvePath(e.extend)
            if base == nil then
                error("Unknown base class: " .. tostring(e.extend), 0)
            end
        end

        local cls = self:createClass(e.name, base)

        table.insert(self.declared, {
            n = e.name,
            old = self.locals[e.name]
        })

        self.locals[e.name] = {
            r = cls
        }
        self.variables[e.name] = cls

        return nil
    end

    if t == "EClassDeclFull" then
        local base = nil
        if e.extend ~= nil then
            base = self:resolvePath(e.extend)
            if base == nil then
                error("Unknown base class: " .. tostring(e.extend), 0)
            end
        end

        local cls = self:createClass(e.name, base)

        for _, field in ipairs(e.fields or {}) do
            if field.kind and field.kind.tag == "KFunction" then
                local funcDecl = field.kind.f
                local args = funcDecl.args or {}
                local body = funcDecl.expr
                local funcName = field.name

                local capturedSelf = self
                local capturedEnv = {}
                for name, slot in pairs(self.locals) do
                    capturedEnv[name] = slot
                end

                local func = function(...)
                    local args_table = {...}
                    local previousLocals = capturedSelf.locals
                    local previousDeclared = capturedSelf.declared

                    local callLocals = {}
                    for name, slot in pairs(capturedEnv) do
                        callLocals[name] = slot
                    end

                    capturedSelf.locals = callLocals
                    capturedSelf.declared = {}

                    local old = #capturedSelf.declared

                    for i, arg in ipairs(args) do
                        local argName = arg.name
                        local argValue = args_table[i]

                        table.insert(capturedSelf.declared, {
                            n = argName,
                            old = capturedSelf.locals[argName]
                        })

                        capturedSelf.locals[argName] = { r = argValue }
                    end

                    local ok, result = pcall(function()
                        return capturedSelf:expr(body)
                    end)

                    capturedSelf:restore(old)
                    capturedSelf.locals = previousLocals
                    capturedSelf.declared = previousDeclared

                    if not ok then
                        local errStr = tostring(result)
                        if errStr:find(Stop.Return, 1, true) then
                            local v = capturedSelf.returnValue
                            capturedSelf.returnValue = nil
                            return v
                        else
                            error(result)
                        end
                    end

                    return result
                end

                cls[funcName] = func
            end
        end

        table.insert(self.declared, {
            n = e.name,
            old = self.locals[e.name]
        })

        self.locals[e.name] = {
            r = cls
        }
        self.variables[e.name] = cls

        return nil
    end

    error("Unsupported AST node "..t)
end

return Interp