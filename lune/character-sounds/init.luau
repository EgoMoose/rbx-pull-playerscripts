--!strict

local fs = require("@lune/fs")
local net = require("@lune/net")
local serde = require("@lune/serde")

local PullHelper = require("../pull-helper")
local RelativePath = require("../RelativePath")

local NAME = "RbxCharacterSounds"

local function main()
	PullHelper.pull({
		packageName = "extracontent-scripts.zip",
		guid = PullHelper.getGuid(),

		manifest = {
			{ "PlayerScripts", "StarterPlayerScriptsCommon", "RbxCharacterSounds" },
			{ "PlayerScripts", "StarterPlayerScriptsCommon", "RbxCharacterSounds.lua" },
		},

		processor = function(tmpDirectory)
			if fs.isDir("src") then
				fs.removeDir("src")
			end

			fs.writeDir("src")
			fs.copy(RelativePath("./modifications/PackageInterface.luau"), "src/init.luau")
			fs.copy(tmpDirectory .. "/RbxCharacterSounds", "src/RbxCharacterSounds")

			fs.writeFile(
				"src/VersionInfo.json",
				net.jsonEncode({
					version = table.concat(PullHelper.getVersion(), "."),
					guid = PullHelper.getGuid(),
				}, true)
			)

			fs.writeFile(
				"default.project.json",
				net.jsonEncode({
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
