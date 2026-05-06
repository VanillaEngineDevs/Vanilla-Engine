local curdir = (...):match("(.-)[^%.]+$")
local class = require(curdir .. "class")

local Async = class:extend("Async")

function Async:new()
    self.vars = {}
    self.definedVars = {}

    self.currentFun = nil
    self.currentLoop = nil
    self.currentBreak = nil

    self.uid = 0
    self.asyncIdents = nil
end

local function tag(e)
    return e.tag
end

local function mk(t, data)
    data = data or {}
    data.tag = t
    return data
end

function Async:ident(name)
    return mk("EIdent", { v = name })
end

function Async:block(arr)
    return mk("EBlock", { e = arr })
end

function Async:call(fn, args)
    return mk("ECall", { e = fn, params = args })
end

function Async:fun(arg, body, name)
    return mk("EFunction", {
        args = { { name = arg } },
        body = body,
        name = name
    })
end

function Async:ignore(e)
    local body = {}

    if e then
        body[1] = e
    end

    return mk("EFunction", {
        args = { { name = "_" } },
        body = mk("EBlock", { e = body })
    })
end

function Async:defineVar(v, mode)
    table.insert(self.definedVars, {
        n = v,
        prev = self.vars[v]
    })

    self.vars[v] = mode
end

function Async:restoreVars(k)
    while #self.definedVars > k do
        local v = table.remove(self.definedVars)

        if v.prev == nil then
            self.vars[v.n] = nil
        else
            self.vars[v.n] = v.prev
        end
    end
end

function Async:saveVars()
    return #self.definedVars
end

function Async:makeCall(ecall, args, rest)
    local names = {}
    local rargs = {}

    for i = 1, #args do
        local n = "_a" .. self.uid
        self.uid = self.uid + 1

        names[i] = n
        rargs[i] = self:ident(n)
    end

    table.insert(rargs, 1, rest)

    local nextExpr = mk("ECall", {
        e = ecall,
        params = rargs
    })

    for i = #args, 1, -1 do
        nextExpr = self:toCps(args[i], self:fun(names[i], nextExpr))
    end

    return nextExpr
end

function Async:isSync(e)
    if tag(e) == "ECall" then
        local fn = e.e

        if tag(fn) == "EIdent" then
            local id = fn.v

            if not self.asyncIdents or self.asyncIdents[id] then
                return false
            end
        end
    end

    return true
end

function Async:toCps(e, rest)
    if self:isSync(e) then
        return self:call(rest, { e })
    end

    local t = tag(e)

    if t == "EBlock" then
        local el = e.e
        local r = rest

        for i = #el, 1, -1 do
            local ex = el[i]

            r = self:ignore(self:toCps(ex, r))
        end

        return r
    end

    if t == "EFunction" then
        local args = e.args

        table.insert(args, 1, { name = "_onEnd" })

        local frest = self:ident("_onEnd")
        local body = self:toCps(e.body, frest)

        local fn = mk("EFunction", {
            args = args,
            body = body,
            name = e.name
        })

        if rest then
            return self:call(rest, { fn })
        end

        return fn
    end

    if t == "ECall" then
        local fn = e.e

        if tag(fn) == "EIdent" then
            local id = fn.v
            local asyncName = "a_" .. id

            return self:makeCall(self:ident(asyncName), e.params, rest)
        end
    end

    if t == "EReturn" then
        return self:toCps(e.e, rest)
    end

    error("Unsupported async expression " .. tostring(t))
end

function Async.toAsync(e)
    local a = Async()
    local endCont = a:ignore()

    return a:toCps(e, endCont)
end

local AsyncInterp = class:extend("AsyncInterp")

function AsyncInterp:new()
    self.variables = {}
end

function AsyncInterp:setContext(api)
    self.variables["split"] = self.split
    self.variables["makeIterator"] = self.makeIterator

    for k, v in pairs(api) do
        if type(v) == "function" then
            self.variables[k] = v

            if not self.variables["a_" .. k] then
                self.variables["a_" .. k] = function(onEnd, ...) onEnd(v(...)) end
            end
        end
    end
end

function AsyncInterp:callAsync(id, args, onResult)
    local fn = self.variables[id]

    if not fn then
        error("Missing function " .. id .. "()")
    end

    if not onResult then
        onResult = function() end
    end

    table.insert(args, 1, onResult)

    fn(table.unpack(args))
end

function AsyncInterp:split(rest, args)
    local count = #args

    if count == 0 then
        rest(nil)
        return
    end

    local function next()
        count = count - 1

        if count == 0 then
            rest(nil)
        end
    end

    for _, a in ipairs(args) do
        a(next)
    end
end

return {
    Async = Async,
    AsyncInterp = AsyncInterp
}