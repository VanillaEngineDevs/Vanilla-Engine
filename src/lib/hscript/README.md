## HScript Lua Parser

A hscript parser made entirely in lua...

Why?

Well.. Why not?

This code is based off of the [FunkinCrew/hscript](https://github.com/FunkinCrew/hscript) repo

This code is purely for PROOF OF CONCEPT and STILL WIP

Do NOT expect this to be able to be used for anything, it is PURELY for fun

## Host bridge

You can expose Lua-side values and callbacks to hscript before execution:

```lua
local hscript = require("hscript")

hscript.Interp:setContext({
	hostAdd = function(a, b)
		return a + b
	end,
	bridge = {
		send = function(value)
			print("script sent:", value)
			return value
		end
	}
})

local parser = hscript.Parser()
local ast = parser:parseString([[{
	bridge.send(hostAdd(20, 22));
}]], "example")

hscript.Interp:execute(ast)
```

