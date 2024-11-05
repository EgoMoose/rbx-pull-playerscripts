--!strict

local Patch = {}

local redirecting = true
local catches = {}

local WARN_FAIL_MSG = "Unable to patch the CameraModule. Using unpatched value."

function Patch.redirect()
	return redirecting
end

function Patch.result()
	local recall = debug.info(2, "f")
	redirecting = false
	local default = recall()
	redirecting = true

	if #catches == 1 then
		return catches[1]
	end

	warn(WARN_FAIL_MSG)
	return default
end

function Patch.setmetatable()
	return function(...)
		local result = setmetatable(...)
		table.insert(catches, result)
		return result
	end
end

return Patch
