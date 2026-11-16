local UpdateState = {}

local CHANNEL_NAME = "updater.result"
local WORKER_PATH = "modules/threads/updaterThread.lua"
local APP_VERSION_PATH = "assets/data/version.txt"

local function startWorker(operation, appVersion, release)
	local channel = love.thread.getChannel(CHANNEL_NAME)
	channel:clear()

	local thread = love.thread.newThread(WORKER_PATH)
	thread:start(operation, CHANNEL_NAME, appVersion, release)
	return thread, channel
end

function UpdateState:enter(_, nextState)
	self.nextState = nextState
	self.appVersion = love.filesystem.read(APP_VERSION_PATH) or "vUnknown"
	if love.system.getOS() == "NX" then
		self:continueToGame()
		return
	end
	self.status = "Checking for updates..."
	self.changelog = ""
	self.release = nil
	self.worker, self.channel = startWorker("check", self.appVersion)
	self.mode = "checking"
end

function UpdateState:continueToGame()
	self.mode = "done"
	Gamestate.switch(self.nextState)
end

function UpdateState:showError(message)
	self.status = "Update check failed: " .. tostring(message)
	love.window.showMessageBox("Update check failed", tostring(message), "info")
	self:continueToGame()
end

function UpdateState:beginInstall()
	self.status = "Downloading and installing " .. self.release.tag_name .. "..."
	self.mode = "installing"
	self.worker, self.channel = startWorker("install", self.appVersion, self.release)
end

function UpdateState:update()
	if self.mode == "checking" then
		local result = self.channel:pop()
		if result then
			if result.error then
				self:showError(result.error)
			elseif result.release then
				self.release = result.release
				self.changelog = result.changelog or ""
				self.status = "Version " .. self.release.tag_name .. " is available."
				self.mode = "prompt"
			else
				self:continueToGame()
			end
		elseif not self.worker:isRunning() then
			self:showError(self.worker:getError() or "The update check stopped unexpectedly.")
		end
	elseif self.mode == "prompt" then
		if input:pressed("confirm") then
			self:beginInstall()
		elseif input:pressed("back") then
			self:continueToGame()
		end
	elseif self.mode == "installing" then
		local result = self.channel:pop()
		if result then
			if result.error then
				self.status = "Update failed: " .. tostring(result.error)
				self.mode = "failed"
			elseif result.fileCount then
				love.event.quit("restart")
			else
				self.status = "Update failed: The installer returned no result."
				self.mode = "failed"
			end
		elseif not self.worker:isRunning() then
			self.status = "Update failed: " .. tostring(self.worker:getError()
				or "The installer stopped unexpectedly.")
			self.mode = "failed"
		end
	elseif self.mode == "failed" and (input:pressed("confirm") or input:pressed("back")) then
		self:continueToGame()
	end
end

function UpdateState:draw()
	local width = push:getWidth()
	local height = push:getHeight()

	love.graphics.setFont(uiFont)
	love.graphics.printf(self.status or "", 100, 170, width - 200, "center")

	if self.mode == "prompt" then
		love.graphics.printf(
			"Installed version: " .. self.appVersion .. "\nNew version: " .. self.release.tag_name,
			100,
			225,
			width - 200,
			"center"
		)
		local changelogY = 315
		local changelogHeight = math.max(0, height - changelogY - 140)
		local _, lines = uiFont:getWrap(self.changelog, width - 260)
		local contentHeight = #lines * uiFont:getHeight()
		self.changelogScroll = math.min(
			self.changelogScroll or 0,
			math.max(0, contentHeight - changelogHeight)
		)
		love.graphics.setScissor(130, changelogY, width - 260, changelogHeight)
		love.graphics.setColor(0.85, 0.85, 0.85, 1)
		love.graphics.printf(
			self.changelog,
			130,
			changelogY - self.changelogScroll,
			width - 260,
			"left"
		)
		love.graphics.setScissor()
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.printf("Confirm: install update    Back: skip", 100, height - 90, width - 200, "center")
	elseif self.mode == "failed" then
		love.graphics.printf("Press Confirm to continue to the game.", 100, height - 90, width - 200, "center")
	end
end

function UpdateState:wheelmoved(_, y)
	if self.mode == "prompt" then
		self.changelogScroll = math.max(0, (self.changelogScroll or 0) - y * 30)
	end
end

return UpdateState
