return graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("menu/merch")),
	-- Automatically generated from merch.xml
	{
		{x = 0, y = 0, width = 484, height = 177, offsetX = -0, offsetY = -2, offsetWidth = 484, offsetHeight = 179, rotated = false}, -- 1: merch selected0001
		{x = 0, y = 177, width = 475, height = 179, offsetX = -1, offsetY = -0, offsetWidth = 484, offsetHeight = 179, rotated = false}, -- 2: merch selected0002
		{x = 0, y = 356, width = 475, height = 174, offsetX = -0, offsetY = -3, offsetWidth = 484, offsetHeight = 179, rotated = false}, -- 3: merch selected0003
		{x = 0, y = 530, width = 386, height = 124, offsetX = -0, offsetY = -0, offsetWidth = 386, offsetHeight = 124, rotated = false}, -- 4: merch idle0001
		{x = 0, y = 530, width = 386, height = 124, offsetX = -0, offsetY = -0, offsetWidth = 386, offsetHeight = 124, rotated = false}, -- 5: merch idle0002
		{x = 0, y = 530, width = 386, height = 124, offsetX = -0, offsetY = -0, offsetWidth = 386, offsetHeight = 124, rotated = false}, -- 6: merch idle0003
		{x = 0, y = 654, width = 386, height = 124, offsetX = -0, offsetY = -0, offsetWidth = 386, offsetHeight = 124, rotated = false}, -- 7: merch idle0004
		{x = 0, y = 654, width = 386, height = 124, offsetX = -0, offsetY = -0, offsetWidth = 386, offsetHeight = 124, rotated = false}, -- 8: merch idle0005
		{x = 0, y = 654, width = 386, height = 124, offsetX = -0, offsetY = -0, offsetWidth = 386, offsetHeight = 124, rotated = false}, -- 9: merch idle0006
		{x = 0, y = 778, width = 386, height = 124, offsetX = -0, offsetY = -0, offsetWidth = 386, offsetHeight = 124, rotated = false}, -- 10: merch idle0007
		{x = 0, y = 778, width = 386, height = 124, offsetX = -0, offsetY = -0, offsetWidth = 386, offsetHeight = 124, rotated = false}, -- 11: merch idle0008
		{x = 0, y = 778, width = 386, height = 124, offsetX = -0, offsetY = -0, offsetWidth = 386, offsetHeight = 124, rotated = false} -- 12: merch idle0009
	},
    {
        ["hover"] = {start = 1, stop = 3, speed = 24, offsetX = 0, offsetY = 0},
        ["idle"] = {start = 4, stop = 12, speed = 24, offsetX = 0, offsetY = 0}
    },
    "idle",
    true
)