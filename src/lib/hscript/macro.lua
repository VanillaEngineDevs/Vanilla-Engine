local curdir = (...):match("(.-)[^%.]+$")
local class = require(curdir .. "class")

local Macro = class:extend("Macro")

function Macro:new(pos)
    self.p = pos

    self.binops = {}
    self.unops = {}

    local assignOps = {
        ["+"] = true,
        ["*"] = true,
        ["/"] = true,
        ["-"] = true,
        ["&"] = true,
        ["|"] = true,
        ["^"] = true,
        ["<<"] = true,
        [">>"] = true,
        [">>>"] = true,
        ["%"] = true
    }

    local ops = {
        ["+"] = "OpAdd",
        ["*"] = "OpMult",
        ["/"] = "OpDiv",
        ["-"] = "OpSub",
        ["="] = "OpAssign",
        ["=="] = "OpEq",
        ["!="] = "OpNotEq",
        [">"] = "OpGt",
        [">="] = "OpGte",
        ["<"] = "OpLt",
        ["<="] = "OpLte",
        ["&"] = "OpAnd",
        ["|"] = "OpOr",
        ["^"] = "OpXor",
        ["&&"] = "OpBoolAnd",
        ["||"] = "OpBoolOr",
        ["<<"] = "OpShl",
        [">>"] = "OpShr",
        [">>>"] = "OpUShr",
        ["%"] = "OpMod",
        ["..."] = "OpInterval",
        ["=>"] = "OpArrow",
        ["in"] = "OpIn"
    }

    for str, op in pairs(ops) do
        self.binops[str] = op

        if assignOps[str] then
            self.binops[str .. "="] = { "OpAssignOp", op }
        end
    end

    self.unops["!"] = "OpNot"
    self.unops["-"] = "OpNeg"
    self.unops["~"] = "OpNegBits"
    self.unops["++"] = "OpIncrement"
    self.unops["--"] = "OpDecrement"
end

function Macro:map(arr, fn)

    local out = {}

    for i, v in ipairs(arr) do
        out[i] = fn(v)
    end

    return out
end

function Macro:convertType(t)
    if not t then return nil end

    local tag = t.tag

    if tag == "CTOpt" then
        return { tag = "TOptional", t = self:convertType(t.t) }
    elseif tag == "CTPath" then
        local params = {}

        if t.args then
            for _, a in ipairs(t.args) do
                if a.tag == "CTExpr" then
                    table.insert(params, { tag = "TPExpr", expr = self:convert(a.e) })
                else
                    table.insert(params, { tag = "TPType", type = self:convertType(a) })
                end
            end
        end

        local pack = { table.unpack(t.pack) }
        local name = table.remove(pack)

        return {
            tag = "TPath",
            pack = pack,
            name = name,
            params = params
        }
    elseif tag == "CTParent" then
        return { tag = "TParent", t = self:convertType(t.t) }
    elseif tag == "CTFun" then
        local args = self:map(t.args, function(a)
            return self:convertType(a)
        end)

        return {
            tag = "TFunction",
            args = args,
            ret = self:convertType(t.ret)
        }
    elseif tag == "CTNamed" then
        return {
            tag = "TNamed",
            name = t.name,
            t = self:convertType(t.t)
        }
    elseif tag == "CTAnon" then
        local fields = {}

        for _, f in ipairs(t.fields) do

            table.insert(fields, {
                name = f.name,
                kind = {
                    tag = "FVar",
                    t = self:convertType(f.t)
                },
                pos = self.p
            })

        end

        return {
            tag = "TAnonymous",
            fields = fields
        }
    elseif tag == "CTExpr" then
        error("assert")
    end
end

function Macro:convert(e)
    local tag = e.tag

    local out = {}

    if tag == "EConst" then
        local c = e.c

        if c.tag == "CInt" then
            out.expr = { tag = "EConst", c = { tag = "CInt", v = tostring(c.v) } }

        elseif c.tag == "CFloat" then
            out.expr = { tag = "EConst", c = { tag = "CFloat", v = tostring(c.v) } }

        elseif c.tag == "CString" then
            out.expr = { tag = "EConst", c = { tag = "CString", v = c.v } }
        end
    elseif tag == "EIdent" then
        out.expr = { tag = "EConst", c = { tag = "CIdent", v = e.v } }
    elseif tag == "EVar" then
        out.expr = {
            tag = "EVars",
            vars = {
                {
                    name = e.n,
                    expr = e.e and self:convert(e.e) or nil,
                    type = e.t and self:convertType(e.t) or nil
                }
            }
        }
    elseif tag == "EParent" then
        out.expr = { tag = "EParenthesis", e = self:convert(e.e) }
    elseif tag == "EBlock" then
        out.expr = { tag = "EBlock", e = self:map(e.e, function(x) return self:convert(x) end) }
    elseif tag == "EField" then
        out.expr = { tag = "EField", e = self:convert(e.e), field = e.f }
    elseif tag == "EBinop" then
        local op = self.binops[e.op]

        if not op then
            error("InvalidOp " .. e.op)
        end

        out.expr = {
            tag = "EBinop",
            op = op,
            e1 = self:convert(e.e1),
            e2 = self:convert(e.e2)
        }
    elseif tag == "EUnop" then
        local op = self.unops[e.op]

        if not op then
            error("InvalidOp " .. e.op)
        end

        out.expr = {
            tag = "EUnop",
            op = op,
            postfix = not e.prefix,
            e = self:convert(e.e)
        }
    elseif tag == "ECall" then
        out.expr = {
            tag = "ECall",
            e = self:convert(e.e),
            params = self:map(e.params, function(x) return self:convert(x) end)
        }
    elseif tag == "EReturn" then
        out.expr = {
            tag = "EReturn",
            e = e.e and self:convert(e.e) or nil
        }
    else
        error("Unsupported expr " .. tostring(tag))
    end

    out.pos = self.p

    return out
end

return Macro