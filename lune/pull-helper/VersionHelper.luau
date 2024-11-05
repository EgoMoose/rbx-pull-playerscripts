--!strict

local net = require("@lune/net")

local VersionHelper = {}

local cached: {
	version: { number },
	guid: string,
}?

local function getCachedRequest()
	if not cached then
		local result = net.request({
			url = "https://clientsettings.roblox.com/v2/client-version/WindowsStudio64",
		})

		if result.ok then
			local decoded = net.jsonDecode(result.body)

			local versionArr = {}
			for _, n in decoded.version:split(".") do
				table.insert(versionArr, tonumber(n) :: number)
			end

			cached = {
				version = versionArr,
				guid = decoded.clientVersionUpload,
			}
		end
	end

	return cached :: typeof(assert(cached, ""))
end

function VersionHelper.getVersion()
	return getCachedRequest().version
end

function VersionHelper.getGuid()
	return getCachedRequest().guid
end

return VersionHelper
