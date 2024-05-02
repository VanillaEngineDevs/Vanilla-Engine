return graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("menu/freeplay")),
	-- Automatically generated from freeplay.xml
	{
		{x = 0, y = 524, width = 484, height = 122, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 1: freeplay idle0000
		{x = 0, y = 524, width = 484, height = 122, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 2: freeplay idle0001
		{x = 0, y = 524, width = 484, height = 122, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 3: freeplay idle0002
		{x = 0, y = 650, width = 484, height = 122, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 4: freeplay idle0003
		{x = 0, y = 650, width = 484, height = 122, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 5: freeplay idle0004
		{x = 0, y = 650, width = 484, height = 122, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 6: freeplay idle0005
		{x = 0, y = 776, width = 484, height = 122, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 7: freeplay idle0006
		{x = 0, y = 776, width = 484, height = 122, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 8: freeplay idle0007
		{x = 0, y = 776, width = 484, height = 122, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 9: freeplay idle0008
		{x = 0, y = 351, width = 627, height = 169, offsetX = 0, offsetY = 0, offsetWidth = 635, offsetHeight = 174, rotated = false}, -- 10: freeplay selected0000
		{x = 0, y = 177, width = 632, height = 170, offsetX = -3, offsetY = -1, offsetWidth = 635, offsetHeight = 174, rotated = false}, -- 11: freeplay selected0001
		{x = 0, y = 0, width = 629, height = 173, offsetX = -4, offsetY = -1, offsetWidth = 635, offsetHeight = 174, rotated = false} -- 12: freeplay selected0002
	},
    {
        ["hover"] = {start = 10, stop = 12, speed = 24, offsetX = 0, offsetY = 0},
        ["idle"] = {start = 1, stop = 8, speed = 24, offsetX = 0, offsetY = 0}
    },
    "idle",
    true
)