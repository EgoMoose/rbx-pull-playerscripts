--!strict

local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")

local targetInstance = script:WaitForChild("PlayerModule")
local versionInfo = require(script:WaitForChild("VersionInfo")) :: { version: string, guid: string }

local Forker = {}

function Forker.getVersionInfo()
	return table.clone(versionInfo)
end

function Forker.getCopy()
	return targetInstance:Clone()
end

function Forker.replace(copy: ModuleScript)
	local existing = StarterPlayerScripts:FindFirstChild(targetInstance.Name)
	if existing then
		existing:Destroy()
	end

	copy.Parent = StarterPlayerScripts
end

return Forker
