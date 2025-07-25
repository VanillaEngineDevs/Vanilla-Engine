return graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("week7/tankRolling")),
		-- Automatically generated from tankRolling.xml
	{
		{x = 0, y = 0, width = 319, height = 328, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 1: BG tank w lighting instance 10000
		{x = 0, y = 332, width = 318, height = 325, offsetX = -1, offsetY = -3, offsetWidth = 319, offsetHeight = 328}, -- 2: BG tank w lighting instance 10001
		{x = 0, y = 661, width = 318, height = 325, offsetX = -1, offsetY = -3, offsetWidth = 319, offsetHeight = 328} -- 3: BG tank w lighting instance 10002
	},
    {
		["anim"] = {start = 1, stop = 3, speed = 24, offsetX = 0, offsetY = 0}
    },
    "anim",
	true
)
