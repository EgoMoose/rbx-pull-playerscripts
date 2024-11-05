--!strict

local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")

local targetInstance = script:WaitForChild("RbxCharacterSounds")
local versionInfo = require(script:WaitForChild("VersionInfo")) :: { version: string, guid: string }

local Forker = {}

function Forker.getVersionInfo()
	return table.clone(versionInfo)
end

function Forker.getCopy()
	return targetInstance:Clone()
end

function Forker.replace()
	local existing = StarterPlayerScripts:FindFirstChild(targetInstance.Name)
	if existing then
		existing:Destroy()
	end

	targetInstance.Parent = StarterPlayerScripts
end

return Forker
