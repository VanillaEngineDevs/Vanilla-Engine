return graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("menu/menuArrow")),
	{
		{x = 58, y = 0, width = 42, height = 75, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 1: arrow
		{x = 0, y = 0, width = 48, height = 85, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0} -- 2: arrow pressed
	},
    {
        ["arrow"] = {start = 1, stop = 1, speed = 24, offsetX = 0, offsetY = 0},
        ["arrow pressed"] = {start = 2, stop = 2, speed = 24, offsetX = 0, offsetY = 0}
    },
    "arrow",
    true
)