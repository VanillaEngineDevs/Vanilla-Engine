return graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("menu/menu_mods")),
		-- Automatically generated from menu_mods.xml
	{
		{x = 0, y = 0, width = 355, height = 139, offsetX = 0, offsetY = -1, offsetWidth = 355, offsetHeight = 140, rotated = false}, -- 1: mods basic0000
		{x = 0, y = 0, width = 355, height = 139, offsetX = 0, offsetY = -1, offsetWidth = 355, offsetHeight = 140, rotated = false}, -- 2: mods basic0001
		{x = 0, y = 0, width = 355, height = 139, offsetX = 0, offsetY = -1, offsetWidth = 355, offsetHeight = 140, rotated = false}, -- 3: mods basic0002
		{x = 356, y = 0, width = 355, height = 140, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 4: mods basic0003
		{x = 356, y = 0, width = 355, height = 140, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 5: mods basic0004
		{x = 356, y = 0, width = 355, height = 140, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 6: mods basic0005
		{x = 0, y = 141, width = 353, height = 139, offsetX = -1, offsetY = -1, offsetWidth = 355, offsetHeight = 140, rotated = false}, -- 7: mods basic0006
		{x = 0, y = 141, width = 353, height = 139, offsetX = -1, offsetY = -1, offsetWidth = 355, offsetHeight = 140, rotated = false}, -- 8: mods basic0007
		{x = 0, y = 141, width = 353, height = 139, offsetX = -1, offsetY = -1, offsetWidth = 355, offsetHeight = 140, rotated = false}, -- 9: mods basic0008
		{x = 354, y = 141, width = 395, height = 192, offsetX = 0, offsetY = -1, offsetWidth = 401, offsetHeight = 193, rotated = false}, -- 10: mods white0000
		{x = 0, y = 334, width = 401, height = 189, offsetX = 0, offsetY = 0, offsetWidth = 401, offsetHeight = 193, rotated = false}, -- 11: mods white0001
		{x = 402, y = 334, width = 400, height = 189, offsetX = 0, offsetY = -1, offsetWidth = 401, offsetHeight = 193, rotated = false} -- 12: mods white0002
	},
    {
        ["hover"] = {start = 10, stop = 12, speed = 24, offsetX = 0, offsetY = 0},
        ["idle"] = {start = 1, stop = 9, speed = 24, offsetX = 0, offsetY = 0}
    },
    "idle",
    true
)