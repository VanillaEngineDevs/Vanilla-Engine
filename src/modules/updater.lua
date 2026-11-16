local json = require("lib.fastjson")

local Updater = {}

local OWNER = "VanillaEngineDevs"
local REPOSITORY = "Vanilla-Engine"
local ASSET_NAME = "funkin-vanilla-engine-lovefile.zip"
local ASSET_PREFIX = "https://github.com/" .. OWNER .. "/" .. REPOSITORY .. "/releases/download/"

local function parseVersion(version)
	if type(version) ~= "string" then
		return nil
	end

	local value = version:match("^%s*(.-)%s*$"):gsub("^v", "")
	value = value:match("^([^+]+)") or value
	local base, prerelease = value:match("^([^%-]+)%-(.+)$")
	base = base or value
	local major, minor, patch = base:match("^(%d+)%.(%d+)%.(%d+)$")
	if not major then
		return nil
	end

	local function normalize(part)
		part = part:gsub("^0+", "")
		return part == "" and "0" or part
	end

	local identifiers = {}
	if prerelease then
		if prerelease:sub(1, 1) == "." or prerelease:sub(-1) == "."
			or prerelease:find("..", 1, true) or not prerelease:match("^[%w%.%-]+$") then
			return nil
		end
		for identifier in prerelease:gmatch("[^.]+") do
			identifiers[#identifiers + 1] = identifier
		end
	end

	return {
		parts = { normalize(major), normalize(minor), normalize(patch) },
		prerelease = identifiers
	}
end

local function compareNumericStrings(a, b)
	if #a ~= #b then
		return #a > #b and 1 or -1
	end
	if a == b then
		return 0
	end
	return a > b and 1 or -1
end

local function compareVersions(a, b)
	local left = parseVersion(a)
	local right = parseVersion(b)
	if not left or not right then
		return nil
	end

	for i = 1, 3 do
		local comparison = compareNumericStrings(left.parts[i], right.parts[i])
		if comparison ~= 0 then
			return comparison
		end
	end

	if #left.prerelease == 0 then
		return #right.prerelease == 0 and 0 or 1
	elseif #right.prerelease == 0 then
		return -1
	end

	for i = 1, math.min(#left.prerelease, #right.prerelease) do
		local leftId, rightId = left.prerelease[i], right.prerelease[i]
		if leftId ~= rightId then
			local leftNumeric = leftId:match("^%d+$") ~= nil
			local rightNumeric = rightId:match("^%d+$") ~= nil
			if leftNumeric and rightNumeric then
				return compareNumericStrings(leftId, rightId)
			elseif leftNumeric ~= rightNumeric then
				return leftNumeric and -1 or 1
			end
			return leftId > rightId and 1 or -1
		end
	end
	if #left.prerelease == #right.prerelease then
		return 0
	end
	return #left.prerelease > #right.prerelease and 1 or -1
end

local function request(url, headers)
	local ok, https = pcall(require, "https")
	if not ok then
		return nil, "HTTPS support is unavailable: " .. tostring(https)
	end

	local success, code, body = pcall(https.request, url, headers and { headers = headers } or nil)
	if not success then
		return nil, "HTTPS request failed: " .. tostring(code)
	end
	if code ~= 200 or type(body) ~= "string" then
		return nil, "HTTPS request failed (HTTP " .. tostring(code) .. ")."
	end
	return body
end

local function decodeReleaseList(body)
	local ok, releases = pcall(json.decode, body)
	if not ok or type(releases) ~= "table" then
		return nil, "GitHub returned invalid Releases JSON."
	end
	return releases
end

local function findUpdateRelease(releases, currentVersion)
	local newest
	for _, release in ipairs(releases) do
		if type(release) == "table" and not release.draft and not release.prerelease
			and parseVersion(release.tag_name) then
			for _, asset in ipairs(type(release.assets) == "table" and release.assets or {}) do
				if type(asset) == "table" and asset.name == ASSET_NAME
					and type(asset.browser_download_url) == "string"
					and asset.browser_download_url:sub(1, #ASSET_PREFIX) == ASSET_PREFIX then
					if not newest or compareVersions(release.tag_name, newest.tag_name) > 0 then
						newest = {
							tag_name = release.tag_name,
							asset_url = asset.browser_download_url,
							changelog = type(release.body) == "string" and release.body or ""
						}
					end
					break
				end
			end
		end
	end

	if newest and compareVersions(newest.tag_name, currentVersion) > 0 then
		return newest
	end
	return nil
end

local function isSafePath(path)
	if type(path) ~= "string" or path == "" or path:find("\\", 1, true)
		or path:find(":", 1, true) or path:sub(1, 1) == "/" then
		return false
	end
	for segment in path:gmatch("[^/]+") do
		if segment == "." or segment == ".." then
			return false
		end
	end
	return true
end

local function collectArchiveFiles(directory, relativeDirectory, files)
	local items, err = love.filesystem.getDirectoryItems(directory)
	if not items then
		return false, "Could not list update archive: " .. tostring(err)
	end

	for _, name in ipairs(items) do
		local path = relativeDirectory == "" and name or relativeDirectory .. "/" .. name
		local archivePath = directory .. "/" .. name
		if not isSafePath(path) then
			return false, "The update archive contains an unsafe path."
		end

		local info, infoError = love.filesystem.getInfo(archivePath)
		if not info then
			return false, "Could not inspect " .. path .. ": " .. tostring(infoError)
		elseif info.type == "directory" then
			local success, collectError = collectArchiveFiles(archivePath, path, files)
			if not success then
				return false, collectError
			end
		elseif info.type == "file" then
			local contents, readError = love.filesystem.read(archivePath)
			if not contents then
				return false, "Could not read " .. path .. ": " .. tostring(readError)
			end
			files[#files + 1] = { path = path, contents = contents }
		else
			return false, "The update archive contains an unsupported entry: " .. path
		end
	end
	return true
end

local function removeTemporaryFile(path)
	local removed, err = love.filesystem.remove(path)
	if not removed then
		return false, "Could not remove temporary file " .. path .. ": " .. tostring(err)
	end
	return true
end

local function getGameArchiveFiles(outerArchive)
	local mounted, err = love.filesystem.mount(outerArchive, "__updater_release", true)
	if not mounted then
		local removed, removeError = removeTemporaryFile(outerArchive)
		if not removed then
			return nil, "Could not open release archive: " .. tostring(err)
				.. " " .. removeError
		end
		return nil, "Could not open release archive: " .. tostring(err)
	end

	local archivePath = "__updater_release/funkin-vanilla-engine.love"
	local archiveInfo = love.filesystem.getInfo(archivePath)
	local contents, readError
	if archiveInfo and archiveInfo.type == "file" then
		contents, readError = love.filesystem.read(archivePath)
	else
		readError = "Release archive does not contain " .. ASSET_NAME .. "'s game archive."
	end

	local unmounted, unmountError = love.filesystem.unmount(outerArchive)
	local removed, removeError = removeTemporaryFile(outerArchive)
	if not unmounted then
		return nil, "Could not close the release archive: " .. tostring(unmountError)
	end
	if not removed then
		return nil, removeError
	end
	if not contents then
		return nil, "Could not read game archive: " .. tostring(readError)
	end

	local written, writeError = love.filesystem.write("update-game.love", contents)
	if not written then
		return nil, "Could not stage game archive: " .. tostring(writeError)
	end

	mounted, err = love.filesystem.mount("update-game.love", "__updater_game", true)
	if not mounted then
		removeTemporaryFile("update-game.love")
		return nil, "Could not open game archive: " .. tostring(err)
	end

	local files = {}
	local success
	success, err = collectArchiveFiles("__updater_game", "", files)
	unmounted, unmountError = love.filesystem.unmount("update-game.love")
	removed, removeError = removeTemporaryFile("update-game.love")
	if not unmounted then
		return nil, "Could not close game archive: " .. tostring(unmountError)
	end
	if not removed then
		return nil, removeError
	end
	if not success then
		return nil, err
	end
	return files
end

function Updater.check(appVersion)
	local currentVersion = love.filesystem.read("update-version.txt")
	if not parseVersion(currentVersion) then
		currentVersion = appVersion
	end
	if not parseVersion(currentVersion) then
		return nil, nil, "The installed game version is invalid."
	end

	local body, err = request(
		"https://api.github.com/repos/" .. OWNER .. "/" .. REPOSITORY .. "/releases?per_page=100",
		{
			Accept = "application/vnd.github+json",
			["X-GitHub-Api-Version"] = "2022-11-28",
			["User-Agent"] = "Vanilla-Engine-Updater"
		}
	)
	if not body then
		return nil, nil, err
	end

	local releases
	releases, err = decodeReleaseList(body)
	if not releases then
		return nil, nil, err
	end

	local release = findUpdateRelease(releases, currentVersion)
	if not release then
		return nil
	end
	return release
end

function Updater.install(release)
	if type(release) ~= "table" or type(release.asset_url) ~= "string"
		or release.asset_url:sub(1, #ASSET_PREFIX) ~= ASSET_PREFIX
		or not parseVersion(release.tag_name) then
		return nil, "The selected update is invalid."
	end

	local archive, err = request(release.asset_url)
	if not archive then
		return nil, "Update download failed: " .. err
	end
	local written, writeError = love.filesystem.write("update-release.zip", archive)
	if not written then
		return nil, "Could not save release archive: " .. tostring(writeError)
	end

	local files
	files, err = getGameArchiveFiles("update-release.zip")
	if not files then
		return nil, err
	end

	for _, file in ipairs(files) do
		local directory = file.path:match("^(.*)/[^/]+$")
		if directory then
			local created, createError = love.filesystem.createDirectory(directory)
			if not created then
				return nil, "Could not create directory for " .. file.path .. ": " .. tostring(createError)
			end
		end
		local success, fileError = love.filesystem.write(file.path, file.contents)
		if not success then
			return nil, "Could not install " .. file.path .. ": " .. tostring(fileError)
		end
	end

	written, writeError = love.filesystem.write("update-version.txt", release.tag_name)
	if not written then
		return nil, "Files installed, but could not save the installed version: " .. tostring(writeError)
	end
	return #files
end

return Updater
