local VersionUtil = {}

-- rule is like this: "2.1.x"
-- meaning everything up to .x is valid
-- so. 2.1.4 is valid, 2.1.2 is valid, 2.0.3 is not
local function satisfyVersion(raw, rule, debug)
    debug = false
    local version = raw
    local ruleParts = rule:split(".")
    local versionParts = version:split(".")
    if debug then
        print("rule", rule)
        print("version", version)
        print("ruleParts", table.concat(ruleParts, ", "))
        print("versionParts", table.concat(versionParts, ", "))
    end
    for i = 1, #ruleParts do
        if ruleParts[i] == "x" then
            if debug then
                print("ruleParts[i] == x")
            end
            break
        end
        if ruleParts[i] ~= versionParts[i] then
            return false
        end
    end

    if debug then
        print("satisfyVersion", true)
    end
    return true
end

function VersionUtil:validateVersion(version, versionRule, debug)
    local ok, err = pcall(function()
        local versionRaw = version
        return satisfyVersion(versionRaw, versionRule, debug)
    end)

    if not ok then
        return false
    end
end

function VersionUtil:reparVersion(version)

end

function VersionUtil:validateVersionStr(version, versionRule)
    local ok, err = pcall(function()
        return satisfyVersion(version, versionRule)
    end)

    if not ok then
        return false
    end
end

function VersionUtil:getVersionFromJSON(input)
    if input == nil then
        return nil
    end

    local parsed = Json.decode(input)
    if parsed == nil then
        return nil
    end
    if parsed.version == nil then
        return nil
    end
    local versionStr = parsed.version
    return versionStr
end

function VersionUtil:parseVersion(input)
    if input == nil then
        return nil
    end

    local versionStr = input
    return versionStr
end

return VersionUtil