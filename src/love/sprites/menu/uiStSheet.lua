return graphics.newSprite(
	---@diagnostic disable-next-line: undefined-global
	uiStSheetImg, -- Do not add the .png extension
	{
		{x = 0, y = 0, width = 200, height = 200, offsetX = 0, offsetY = 0, offsetWidth = 200, offsetHeight = 200}, -- 1: uiStSheet boolOff0000
		{x = 200, y = 0, width = 200, height = 200, offsetX = 0, offsetY = 0, offsetWidth = 200, offsetHeight = 200}, -- 2: uiStSheet boolOn0000
		{x = 400, y = 0, width = 652, height = 58, offsetX = -23, offsetY = -40, offsetWidth = 700, offsetHeight = 150}, -- 3: uiStSheet slideBar0000
		{x = 0, y = 200, width = 96, height = 97, offsetX = -54, offsetY = -54, offsetWidth = 200, offsetHeight = 200} -- 4: uiStSheet slideDot0000
	},
	{
		["off"] = {start = 1, stop = 1, speed = 0, offsetX = 0, offsetY = 0},
        ["on"] = {start = 2, stop = 2, speed = 0, offsetX = 0, offsetY = 0},
        ["slideBar"] = {start = 3, stop = 3, speed = 0, offsetX = 0, offsetY = 0},
        ["slideDot"] = {start = 4, stop = 4, speed = 0, offsetX = 0, offsetY = 0}
	},
	"off", -- set to default animation
	false -- If the sprite repeats
)
