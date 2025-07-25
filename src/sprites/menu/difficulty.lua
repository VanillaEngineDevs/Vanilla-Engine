return graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("menu/menuDifficulties")),
	{
		{x = 0, y = 0, width = 196, height = 65, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 1: EASY0000
		{x = 206, y = 0, width = 211, height = 67, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 2: HARD0000
		{x = 427, y = 0, width = 308, height = 67, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0} -- 3: NORMAL0000
	},
    {
        ["easy"] = {start = 1, stop = 1, speed = 24, offsetX = 0, offsetY = 0},
        ["normal"] = {start = 3, stop = 3, speed = 24, offsetX = -8, offsetY = 0},
        ["hard"] = {start = 2, stop = 2, speed = 24, offsetX = 0, offsetY = 0}
    },
    "normal",
    true
)