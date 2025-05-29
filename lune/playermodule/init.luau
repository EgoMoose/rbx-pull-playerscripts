--!strict

local fs = require("@lune/fs")
local serde = require("@lune/serde")

local PullHelper = require("@root/lune/pull-helper")
local RelativePath = require("@root/lune/RelativePath")

local NAME = "PlayerModule"

local function main()
	PullHelper.pull({
		packageName = "extracontent-scripts.zip",
		guid = PullHelper.getGuid(),

		manifest = {
			{ "PlayerScripts", "StarterPlayerScripts", "PlayerModule.module" },
			{ "PlayerScripts", "StarterPlayerScripts", "PlayerModule.module.lua" },
		},

		processor = function(tmpDirectory)
			if fs.isDir("src") then
				fs.removeDir("src")
			end

			fs.writeDir("src")
			fs.copy(RelativePath("modifications/PackageInterface.luau"), "src/init.luau")
			fs.copy(tmpDirectory .. "/PlayerModule.module", "src/PlayerModule")

			fs.copy(RelativePath("modifications/Patch.luau"), "src/PlayerModule/Patch.luau")

			local cameraModuleContent = fs.readFile("src/PlayerModule/CameraModule/init.luau")
			local cameraModuleHeader = fs.readFile(RelativePath("modifications/CameraModuleHeader.luau"))
			fs.writeFile("src/PlayerModule/CameraModule/init.luau", cameraModuleHeader .. "\n" .. cameraModuleContent)

			fs.writeFile(
				"src/VersionInfo.json",
				serde.encode("json", {
					version = table.concat(PullHelper.getVersion(), "."),
					guid = PullHelper.getGuid(),
				}, true)
			)

			fs.writeFile(
				"default.project.json",
				serde.encode("json", {
					name = NAME,
					tree = {
						["$path"] = "src",
					},
				}, true)
			)

			local wally = serde.decode("toml", fs.readFile("wally.toml"))
			local scope = select(1, unpack(string.split(wally.package.name, "/")))
			wally.package.version = table.concat(PullHelper.getVersion(), ".", 2)
			wally.package.name = `{scope}/{NAME:lower()}`
			fs.writeFile("wally.toml", serde.encode("toml", wally, false))
		end,
	})
end

main()
