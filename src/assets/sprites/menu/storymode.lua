return graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("menu/storymode")),
	-- Automatically generated from storymode.xml
	{
		{x = 0, y = 540, width = 615, height = 122, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 1: storymode idle0000
		{x = 0, y = 540, width = 615, height = 122, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 2: storymode idle0001
		{x = 0, y = 540, width = 615, height = 122, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 3: storymode idle0002
		{x = 0, y = 666, width = 615, height = 122, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 4: storymode idle0003
		{x = 0, y = 666, width = 615, height = 122, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 5: storymode idle0004
		{x = 0, y = 666, width = 615, height = 122, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 6: storymode idle0005
		{x = 0, y = 792, width = 615, height = 122, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 7: storymode idle0006
		{x = 0, y = 792, width = 615, height = 122, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 8: storymode idle0007
		{x = 0, y = 792, width = 615, height = 122, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- 9: storymode idle0008
		{x = 0, y = 363, width = 796, height = 173, offsetX = 0, offsetY = -3, offsetWidth = 796, offsetHeight = 181, rotated = false}, -- 10: storymode selected0000
		{x = 0, y = 185, width = 794, height = 174, offsetX = -2, offsetY = -2, offsetWidth = 796, offsetHeight = 181, rotated = false}, -- 11: storymode selected0001
		{x = 0, y = 0, width = 794, height = 181, offsetX = 0, offsetY = 0, offsetWidth = 796, offsetHeight = 181, rotated = false} -- 12: storymode selected0002
	},
    {
        ["hover"] = {start = 10, stop = 12, speed = 24, offsetX = 0, offsetY = 0},
        ["idle"] = {start = 1, stop = 8, speed = 24, offsetX = 0, offsetY = 0}
    },
    "idle",
    true
)