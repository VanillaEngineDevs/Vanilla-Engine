local baton = require("lib.baton")

local CONFIG_PATH = "inputconfig.lua"

local input = {}

local function getDefaultControls()
	local controls = {
		left = {"key:left",  "axis:leftx-", "button:dpleft"},
		down = {"key:down",  "axis:lefty+", "button:dpdown"},
		up = {"key:up",    "axis:lefty-", "button:dpup"},
		right = {"key:right", "axis:leftx+", "button:dpright"},

		confirm = {"key:return", "button:a"},
		back = {"key:escape", "button:b"},
		tab = {"key:tab", "button:back"},
		pause = {"button:start", "key:return"},

		debugZoomOut = {"key:["},
		debugZoomIn = {"key:]"},

		gameLeft = {
			"key:left",
			"key:a",
			"axis:triggerleft+",
			"axis:leftx-",
			"axis:rightx-",
			"button:dpleft",
			"button:x"
		},
		gameDown = {
			"key:down",
			"key:s",
			"axis:lefty+",
			"axis:righty+",
			"button:leftshoulder",
			"button:dpdown",
			"button:a"
		},
		gameUp = {
			"key:up",
			"key:w",
			"axis:lefty-",
			"axis:righty-",
			"button:rightshoulder",
			"button:dpup",
			"button:y"
		},
		gameRight = {
			"key:right",
			"key:d",
			"axis:triggerright+",
			"axis:leftx+",
			"axis:rightx+",
			"button:dpright",
			"button:b"
		},

		gameBack = {"key:escape", "button:start"},
	}

	if love.system.getOS() == "NX" then
		lume.extend(controls, {
			confirm = {"button:b", "key:return"},
			back = {"button:a", "key:escape"},

			left = {"axis:leftx-", "button:dpleft", "key:left"},
			down = {"axis:lefty+", "button:dpdown", "key:down"},
			up = {"axis:lefty-", "button:dpup", "key:up"},
			right = {"axis:leftx+", "button:dpright", "key:right"},

			gameLeft = {
				"axis:triggerleft+",
				"axis:leftx-",
				"axis:rightx-",
				"button:dpleft",
				"button:x",
				"key:left",
				"key:a"
			},
			gameDown = {
				"axis:lefty+",
				"axis:righty+",
				"button:leftshoulder",
				"button:dpdown",
				"button:a",
				"key:down",
				"key:s"
			},
			gameUp = {
				"axis:lefty-",
				"axis:righty-",
				"button:rightshoulder",
				"button:dpup",
				"button:y",
				"key:up",
				"key:w"
			},
			gameRight = {
				"axis:triggerright+",
				"axis:leftx+",
				"axis:rightx+",
				"button:dpright",
				"button:b",
				"key:right",
				"key:d"
			},

			gameBack = {"button:start", "key:escape"},
		})
	end

	return controls
end


local function saveConfig(data)
	local serialized = "return " .. lume.serialize(data)
	love.filesystem.write(CONFIG_PATH, serialized)
end

local function loadConfig()
	if love.filesystem.getInfo(CONFIG_PATH) then
		local chunk = love.filesystem.load(CONFIG_PATH)
		local ok, data = pcall(chunk)

		if ok and type(data) == "table" then
			return data
		end
	end

	local defaults = {
		controls = getDefaultControls()
	}

	saveConfig(defaults)
	return defaults
end

function input.createController()
	local data = loadConfig()

	local mergedControls = lume.merge(
		getDefaultControls(),
		data.controls or {}
	)

	data.controls = mergedControls
	saveConfig(data)

	return baton.new {
		controls = mergedControls,
		joystick = love.joystick.getJoysticks()[1]
	}
end

function input.saveControls(newControls)
	local data = loadConfig()
	data.controls = lume.clone(newControls)
	saveConfig(data)
end

function input.getControls()
	local data = loadConfig()
	return lume.clone(data.controls)
end

return input
