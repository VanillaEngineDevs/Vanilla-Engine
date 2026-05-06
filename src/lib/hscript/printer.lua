local curdir = (...):match("(.-)[^%.]+$")
local class = require(curdir .. "class")

local Printer = class:extend("Printer")

function Printer:new()
    self.buf = {}
    self.tabs = ""
end

local function join(t)
    return table.concat(t)
end

function Printer:add(s)
    table.insert(self.buf, tostring(s))
end

function Printer:exprToString(e)
    self.buf = {}
    self.tabs = ""
    self:expr(e)
    return join(self.buf)
end

function Printer:typeToString(t)
    self.buf = {}
    self.tabs = ""
    self:type(t)
    return join(self.buf)
end

function Printer:type(t)
    local tag = t.tag

    if tag == "CTOpt" then
        self:add("?")
        self:type(t.t)
    elseif tag == "CTPath" then
        self:add(table.concat(t.path, "."))

        if t.params then
            self:add("<")

            for i,p in ipairs(t.params) do
                if i > 1 then self:add(", ") end
                self:type(p)
            end

            self:add(">")
        end
    elseif tag == "CTNamed" then
        self:add(t.name)
        self:add(":")
        self:type(t.t)
    elseif tag == "CTFun" then
        if #t.args == 0 then
            self:add("Void -> ")
        else
            for _,a in ipairs(t.args) do
                self:type(a)
                self:add(" -> ")
            end
        end

        self:type(t.ret)
    elseif tag == "CTAnon" then
        self:add("{")

        for i,f in ipairs(t.fields) do
            if i == 1 then
                self:add(" ")
            else
                self:add(", ")
            end

            self:add(f.name .. " : ")
            self:type(f.t)
        end

        if #t.fields == 0 then
            self:add("}")
        else
            self:add(" }")
        end
    elseif tag == "CTParent" then
        self:add("(")
        self:type(t.t)
        self:add(")")
    elseif tag == "CTExpr" then
        self:expr(t.e)
    end
end

function Printer:addType(t)
    if t then
        self:add(" : ")
        self:type(t)
    end
end

function Printer:addConst(c)
    local tag = c.tag

    if tag == "CInt" then
        self:add(c.v)
    elseif tag == "CFloat" then
        self:add(c.v)
    elseif tag == "CString" then
        local s = c.v

        s = s:gsub('"','\\"')
        s = s:gsub("\n","\\n")
        s = s:gsub("\r","\\r")
        s = s:gsub("\t","\\t")

        self:add('"')
        self:add(s)
        self:add('"')
    end
end

function Printer:expr(e)
    if not e then
        self:add("??NULL??")
        return
    end

    local tag = e.tag

    if tag == "EConst" then
        self:addConst(e.c)
    elseif tag == "EIdent" then

        self:add(e.v)
    elseif tag == "EVar" then
        self:add("var " .. e.n)

        self:addType(e.t)

        if e.e then
            self:add(" = ")
            self:expr(e.e)
        end
    elseif tag == "EFinal" then
        self:add("final " .. e.n)

        self:addType(e.t)

        if e.e then
            self:add(" = ")
            self:expr(e.e)
        end
    elseif tag == "EParent" then
        self:add("(")
        self:expr(e.e)
        self:add(")")
    elseif tag == "EBlock" then
        local el = e.e

        if #el == 0 then
            self:add("{}")
        else
            self.tabs = self.tabs .. "\t"

            self:add("{\n")

            for _,ex in ipairs(el) do
                self:add(self.tabs)
                self:expr(ex)
                self:add(";\n")
            end

            self.tabs = self.tabs:sub(2)

            self:add("}")
        end
    elseif tag == "EField" then
        self:expr(e.e)
        self:add("." .. e.f)
    elseif tag == "EBinop" then
        self:expr(e.e1)
        self:add(" " .. e.op .. " ")
        self:expr(e.e2)
    elseif tag == "EUnop" then
        if e.pre then
            self:add(e.op)
            self:expr(e.e)
        else
            self:expr(e.e)
            self:add(e.op)
        end
    elseif tag == "ECall" then
        self:expr(e.e)

        self:add("(")

        for i,a in ipairs(e.args) do
            if i > 1 then self:add(", ") end
            self:expr(a)
        end

        self:add(")")
    elseif tag == "EIf" then
        self:add("if( ")
        self:expr(e.cond)
        self:add(" ) ")

        self:expr(e.e1)

        if e.e2 then
            self:add(" else ")
            self:expr(e.e2)
        end
    elseif tag == "EReturn" then
        self:add("return")

        if e.e then
            self:add(" ")
            self:expr(e.e)
        end
    elseif tag == "EArray" then
        self:expr(e.e)
        self:add("[")
        self:expr(e.index)
        self:add("]")
    elseif tag == "EArrayDecl" then
        self:add("[")

        for i,v in ipairs(e.values) do
            if i > 1 then self:add(", ") end
            self:expr(v)
        end

        self:add("]")
    elseif tag == "EObject" then
        local fields = e.fields

        if #fields == 0 then
            self:add("{}")
        else
            self.tabs = self.tabs .. "\t"

            self:add("{\n")

            for _,f in ipairs(fields) do
                self:add(self.tabs)
                self:add(f.name .. " : ")

                self:expr(f.e)

                self:add(",\n")
            end

            self.tabs = self.tabs:sub(2)

            self:add("}")
        end
    elseif tag == "ETernary" then
        self:expr(e.c)
        self:add(" ? ")
        self:expr(e.e1)
        self:add(" : ")
        self:expr(e.e2)
    elseif tag == "EThrow" then
        self:add("throw ")
        self:expr(e.e)
    elseif tag == "EBreak" then
        self:add("break")
    elseif tag == "EContinue" then
        self:add("continue")
    else
        self:add("/* unsupported expr: " .. tostring(tag) .. " */")
    end
end

function Printer.toString(e)
    return Printer():exprToString(e)
end

function Printer.errorToString(err)
    local tag = err.tag
    local message = ""

    if tag == "EInvalidChar" then
        message = "Invalid character: '" .. tostring(err.c) .. "'"
    elseif tag == "EUnexpected" then
        message = "Unexpected token: \"" .. err.s .. "\""
    elseif tag == "EUnterminatedString" then
        message = "Unterminated string"
    elseif tag == "EUnterminatedComment" then
        message = "Unterminated comment"
    elseif tag == "EInvalidPreprocessor" then
        message = "Invalid preprocessor (" .. err.str .. ")"
    elseif tag == "EUnknownVariable" then
        message = "Unknown variable: " .. err.v
    elseif tag == "EInvalidIterator" then
        message = "Invalid iterator: " .. err.v
    elseif tag == "EInvalidOp" then
        message = "Invalid operator: " .. err.op
    elseif tag == "EInvalidAccess" then
        message = "Invalid access to field " .. err.f
    elseif tag == "ECustom" then
        message = err.msg
    else
        message = "Unknown error"
    end

    return message
end

return Printer