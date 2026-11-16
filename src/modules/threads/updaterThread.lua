local Updater = require("modules.updater")

local operation, channelName, appVersion, release = ...
local channel = love.thread.getChannel(channelName)

local ok, result, changelog, err
if operation == "check" then
	ok, result, changelog, err = pcall(Updater.check, appVersion)
elseif operation == "install" then
	ok, result, err = pcall(Updater.install, release)
else
	channel:push({ error = "Unknown updater operation." })
	return
end

if not ok then
	channel:push({ error = tostring(result) })
elseif operation == "check" then
	channel:push({
		release = result,
		changelog = result and result.changelog or changelog,
		error = err
	})
else
	channel:push({
		fileCount = result,
		error = err
	})
end
