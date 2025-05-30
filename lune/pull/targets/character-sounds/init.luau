--!strict

local fs = require("@lune/fs")
local serde = require("@lune/serde")

local PullHelper = require("@root/lune/pull/helpers/pull-helper")
local RelativePath = require("@root/lune/pull/helpers/RelativePath")

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
			fs.copy(RelativePath("modifications/PackageInterface.luau"), "src/init.luau")
			fs.copy(tmpDirectory .. "/RbxCharacterSounds", "src/RbxCharacterSounds")

			-- return an empty table b/c we're converting to a module script
			fs.writeFile(
				"src/RbxCharacterSounds/init.luau",
				fs.readFile("src/RbxCharacterSounds/init.luau") .. "\nreturn {}"
			)

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

return main
