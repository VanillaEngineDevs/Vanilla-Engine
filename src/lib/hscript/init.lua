local curdir = (...)
curdir = curdir .. "."

local hscript = {}

hscript.AST = require(curdir .. "expr")
hscript.Parser = require(curdir .. "parser")
hscript.InterpClass = require(curdir .. "interp")
hscript.Interp = hscript.InterpClass()
hscript.newInterp = function()
    return hscript.InterpClass()
end
hscript.Printer = require(curdir .. "printer")
hscript.Macro = require(curdir .. "macro")
hscript.Async = require(curdir .. "async")

return hscript

