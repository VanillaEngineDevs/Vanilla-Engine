return graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("menu/options")),
	-- Automatically generated from options.xml
	{
		{x = 0, y = 488, width = 487, height = 111, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 1: options idle0000
		{x = 0, y = 488, width = 487, height = 111, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 2: options idle0001
		{x = 0, y = 488, width = 487, height = 111, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 3: options idle0002
		{x = 0, y = 603, width = 487, height = 111, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 4: options idle0003
		{x = 0, y = 603, width = 487, height = 111, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 5: options idle0004
		{x = 0, y = 603, width = 487, height = 111, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 6: options idle0005
		{x = 0, y = 718, width = 487, height = 111, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 7: options idle0006
		{x = 0, y = 718, width = 487, height = 111, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 8: options idle0007
		{x = 0, y = 718, width = 487, height = 111, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 9: options idle0008
		{x = 0, y = 329, width = 606, height = 155, offsetX = -2, offsetY = -1, offsetWidth = 610, offsetHeight = 163, rotated = false}, -- 10: options selected0000
		{x = 0, y = 167, width = 607, height = 158, offsetX = -3, offsetY = -1, offsetWidth = 610, offsetHeight = 163, rotated = false}, -- 11: options selected0001
		{x = 0, y = 0, width = 610, height = 163, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false} -- 12: options selected0002
	},
    {
        ["hover"] = {start = 10, stop = 12, speed = 24, offsetX = 0, offsetY = 0},
        ["idle"] = {start = 1, stop = 8, speed = 24, offsetX = 0, offsetY = 0}
    },
    "idle",
    true
)