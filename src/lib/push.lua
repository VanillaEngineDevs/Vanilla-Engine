--[[
push.lua v1.0

The MIT License (MIT)

Copyright (c) 2018 Ulysse Ramage

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
--]]

-- Modified for VE by Fukita

local settings

local baseWidth, baseHeight
local pushWidth, pushHeight
local windowWidth, windowHeight

local safeX, safeY
local safeWidth, safeHeight

local scale = {x = 0, y = 0}
local offset = {x = 0, y = 0}

local cutoutSize = {x = 0, y = 0}
local gameCutoutSize = {x = 0, y = 0}

local drawWidth, drawHeight

local canvases
local canvasOptions

local MAX_ASPECT_RATIO = 20 / 9

local function updateSafeArea()
	if love.window.getSafeArea then
		safeX, safeY, safeWidth, safeHeight = love.window.getSafeArea()
	else
		safeX, safeY = 0, 0
		safeWidth, safeHeight = windowWidth, windowHeight
	end

	if safeWidth <= 0 or safeHeight <= 0 then
		safeX, safeY = 0, 0
		safeWidth, safeHeight = windowWidth, windowHeight
	end
end

local function updateGameSize()
	local gameRatio = baseWidth / baseHeight
	local screenRatio = safeWidth / safeHeight

	if screenRatio >= gameRatio then
		pushHeight = baseHeight
		pushWidth = math.floor(safeWidth * baseHeight / safeHeight + 0.5)

		if pushWidth / pushHeight > MAX_ASPECT_RATIO then
			pushWidth = math.floor(pushHeight * MAX_ASPECT_RATIO + 0.5)
		end
	else
		pushWidth = baseWidth
		pushHeight = math.floor(safeHeight * baseWidth / safeWidth + 0.5)
	end

	print(gameRatio, screenRatio, pushHeight, pushWidth)
end

local function updateDeviceCutout()
	cutoutSize.x = 0
	cutoutSize.y = 0

	if safeX > 0 then
		cutoutSize.x = safeX
	end

	if safeY > 0 then
		cutoutSize.y = safeY
	end

	if safeX + safeWidth < windowWidth then
		cutoutSize.x = math.max(cutoutSize.x, windowWidth - (safeX + safeWidth))
	end

	if safeY + safeHeight < windowHeight then
		cutoutSize.y = math.max(cutoutSize.y, windowHeight - (safeY + safeHeight))
	end

	gameCutoutSize.x = cutoutSize.x / scale.x
	gameCutoutSize.y = cutoutSize.y / scale.y
end

local function initValues()
	updateSafeArea()
	updateGameSize()

	scale.x = safeWidth / pushWidth
	scale.y = safeHeight / pushHeight

	if settings.upscale == "normal" or settings.upscale == "pixel-perfect" then
		local scaleVal = math.min(scale.x, scale.y)

		if scaleVal >= 1 and settings.upscale == "pixel-perfect" then
			scaleVal = math.floor(scaleVal)
		end

		scale.x = scaleVal
		scale.y = scaleVal
	elseif settings.upscale == "stretched" then
		scale.x = safeWidth / pushWidth
		scale.y = safeHeight / pushHeight
	else
		error("Invalid upscale setting")
	end

	updateDeviceCutout()

	drawWidth = pushWidth * scale.x
	drawHeight = pushHeight * scale.y

	offset.x = math.floor(safeX + (safeWidth - drawWidth) / 2)
	offset.y = math.floor(safeY + (safeHeight - drawHeight) / 2)
end

local function createCanvas(width, height)
	return love.graphics.newCanvas(width, height)
end

local function setupCanvas(canvasTable)
	table.insert(canvasTable, {name = "_render", private = true})

	canvases = {}

	for i = 1, #canvasTable do
		local params = canvasTable[i]

		table.insert(
			canvases,
			{
				name = params.name,
				private = params.private,
				shader = params.shader,
				canvas = createCanvas(pushWidth, pushHeight),
				stencil = params.stencil
			}
		)
	end

	canvasOptions = {canvases[1].canvas, stencil = true}
end

local function resizeCanvases()
	if not settings.canvas or not canvases then
		return
	end

	local oldCanvases = canvases
	canvases = {}

	for i = 1, #oldCanvases do
		local old = oldCanvases[i]

		table.insert(
			canvases,
			{
				name = old.name,
				private = old.private,
				shader = old.shader,
				canvas = createCanvas(pushWidth, pushHeight),
				stencil = old.stencil
			}
		)

		if old.canvas then
			old.canvas:release()
		end
	end

	canvasOptions = {canvases[1].canvas, stencil = true}
end

local function getCanvasTable(name)
	for i = 1, #canvases do
		if canvases[i].name == name then
			return canvases[i]
		end
	end
end

local function start()
	if settings.canvas then
		love.graphics.push()
		love.graphics.setCanvas(canvasOptions)
	else
		love.graphics.translate(offset.x, offset.y)
		love.graphics.setScissor(offset.x, offset.y, drawWidth, drawHeight)
		love.graphics.push()
		love.graphics.scale(scale.x, scale.y)
	end
end

local function applyShaders(canvas, shaders)
	local shader = love.graphics.getShader()

	if #shaders <= 1 then
		love.graphics.setShader(shaders[1])
		love.graphics.draw(canvas)
	else
		local canvas = love.graphics.getCanvas()
		local tmp = getCanvasTable("_tmp")
		local outputCanvas
		local inputCanvas

		if not tmp then
			table.insert(
				canvases,
				{
					name = "_tmp",
					private = true,
					canvas = createCanvas(pushWidth, pushHeight)
				}
			)

			tmp = getCanvasTable("_tmp")
		end

		love.graphics.push()
		love.graphics.origin()

		for i = 1, #shaders do
			inputCanvas = i % 2 == 1 and canvas or tmp.canvas
			outputCanvas = i % 2 == 0 and canvas or tmp.canvas

			love.graphics.setCanvas(outputCanvas)
			love.graphics.clear()
			love.graphics.setShader(shaders[i])
			love.graphics.draw(inputCanvas)
			love.graphics.setCanvas(inputCanvas)
		end

		love.graphics.pop()

		love.graphics.setCanvas(canvas)
		love.graphics.draw(outputCanvas)
	end

	love.graphics.setShader(shader)
end

local function finish(shader)
	if settings.canvas then
		local render = getCanvasTable("_render")

		love.graphics.pop()

		love.graphics.setCanvas(render.canvas)

		for i = 1, #canvases do
			local canvasTable = canvases[i]

			if not canvasTable.private then
				local shader = canvasTable.shader
				applyShaders(canvasTable.canvas, type(shader) == "table" and shader or {shader})
			end
		end

		love.graphics.setCanvas()

		love.graphics.translate(offset.x, offset.y)
		love.graphics.push()
		love.graphics.scale(scale.x, scale.y)

		do
			local shader = shader or render.shader
			applyShaders(render.canvas, type(shader) == "table" and shader or {shader})
		end

		love.graphics.pop()

		for i = 1, #canvases do
			love.graphics.setCanvas(canvases[i].canvas)
			love.graphics.clear()
		end

		love.graphics.setCanvas()
		love.graphics.setShader()
	else
		love.graphics.pop()
		love.graphics.setScissor()
	end
end

return {
	setupScreen = function(width, height, settingsTable)
		baseWidth, baseHeight = width, height
		pushWidth, pushHeight = width, height

		windowWidth, windowHeight = love.graphics.getDimensions()

		settings = settingsTable

		initValues()

		if settings.canvas then
			setupCanvas({"default"})
		end
	end,

	setupCanvas = setupCanvas,

	setCanvas = function(name)
		local canvasTable

		if not settings.canvas then
			return true
		end

		canvasTable = getCanvasTable(name)

		return love.graphics.setCanvas({canvasTable.canvas, stencil = true})
	end,

	setShader = function(name, shader)
		if not shader then
			getCanvasTable("_render").shader = name
		else
			getCanvasTable(name).shader = shader
		end
	end,

	updateSettings = function(settingsTable)
		settings.upscale = settingsTable.upscale or settings.upscale
		settings.canvas = settingsTable.canvas or settings.canvas
	end,

	toGame = function(x, y)
		x, y = x - offset.x, y - offset.y

		local normalX = x / drawWidth
		local normalY = y / drawHeight

		x = (x >= 0 and x <= drawWidth) and math.floor(normalX * pushWidth) or false
		y = (y >= 0 and y <= drawHeight) and math.floor(normalY * pushHeight) or false

		return x, y
	end,

	toReal = function(x, y)
		local realX = offset.x + (drawWidth * x) / pushWidth
		local realY = offset.y + (drawHeight * y) / pushHeight

		return realX, realY
	end,

	start = start,
	finish = finish,

	resize = function(width, height)
		windowWidth, windowHeight = width, height

		local oldWidth = pushWidth
		local oldHeight = pushHeight

		initValues()

		if settings.canvas and (oldWidth ~= pushWidth or oldHeight ~= pushHeight) then
			resizeCanvases()
		end
	end,

	getWidth = function()
		return pushWidth
	end,

	getHeight = function()
		return pushHeight
	end,

	getDimensions = function()
		return pushWidth, pushHeight
	end,

	getScale = function()
		return scale.x, scale.y
	end,

	getOffset = function()
		return offset.x, offset.y
	end,

	getSafeArea = function()
		return safeX, safeY, safeWidth, safeHeight
	end,

	getCutoutSize = function()
		return {x = cutoutSize.x, y = cutoutSize.y}
	end,

	getGameCutoutSize = function()
		return {x = gameCutoutSize.x, y = gameCutoutSize.y}
	end,
}