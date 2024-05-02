return graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("menu/credits")),
	-- Automatically generated from credits.xml
	{
		{x = 0, y = 0, width = 520, height = 172, offsetX = -2, offsetY = -0, offsetWidth = 522, offsetHeight = 172, rotated = false}, -- 1: credits selected0001
		{x = 0, y = 172, width = 520, height = 172, offsetX = -0, offsetY = -0, offsetWidth = 522, offsetHeight = 172, rotated = false}, -- 2: credits selected0002
		{x = 0, y = 344, width = 519, height = 172, offsetX = -2, offsetY = -0, offsetWidth = 522, offsetHeight = 172, rotated = false}, -- 3: credits selected0003
		{x = 0, y = 516, width = 439, height = 124, offsetX = -0, offsetY = -0, offsetWidth = 439, offsetHeight = 124, rotated = false}, -- 4: credits idle0001
		{x = 0, y = 516, width = 439, height = 124, offsetX = -0, offsetY = -0, offsetWidth = 439, offsetHeight = 124, rotated = false}, -- 5: credits idle0002
		{x = 0, y = 516, width = 439, height = 124, offsetX = -0, offsetY = -0, offsetWidth = 439, offsetHeight = 124, rotated = false}, -- 6: credits idle0003
		{x = 0, y = 640, width = 439, height = 124, offsetX = -0, offsetY = -0, offsetWidth = 439, offsetHeight = 124, rotated = false}, -- 7: credits idle0004
		{x = 0, y = 640, width = 439, height = 124, offsetX = -0, offsetY = -0, offsetWidth = 439, offsetHeight = 124, rotated = false}, -- 8: credits idle0005
		{x = 0, y = 640, width = 439, height = 124, offsetX = -0, offsetY = -0, offsetWidth = 439, offsetHeight = 124, rotated = false}, -- 9: credits idle0006
		{x = 0, y = 764, width = 439, height = 124, offsetX = -0, offsetY = -0, offsetWidth = 439, offsetHeight = 124, rotated = false}, -- 10: credits idle0007
		{x = 0, y = 764, width = 439, height = 124, offsetX = -0, offsetY = -0, offsetWidth = 439, offsetHeight = 124, rotated = false}, -- 11: credits idle0008
		{x = 0, y = 764, width = 439, height = 124, offsetX = -0, offsetY = -0, offsetWidth = 439, offsetHeight = 124, rotated = false} -- 12: credits idle0009
	},
    {
        ["hover"] = {start = 1, stop = 3, speed = 24, offsetX = 0, offsetY = 0},
        ["idle"] = {start = 4, stop = 12, speed = 24, offsetX = 0, offsetY = 0}
    },
    "idle",
    true
)