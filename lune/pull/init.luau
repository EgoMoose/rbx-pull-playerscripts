--!strict

local fs = require("@lune/fs")
local serde = require("@lune/serde")
local process = require("@lune/process")

local RelativePath = require("@self/helpers/RelativePath")

local function getLuneVersion()
	local child = process.create("lune", { "--version" })
	local result = child:status()
	return if result.code == 0 and result.ok then child.stdout:readToEnd():sub(6) else nil
end

local function getRokitLuneVersion()
	local rokit = serde.decode("toml", fs.readFile("rokit.toml"))
	return if rokit.tools.lune then rokit.tools.lune:match("@(.+)$") else ""
end

local function pull(target: string)
	local path = RelativePath(`targets/{target}`)
	assert(fs.isFile(path) or fs.isDir(path), `No path at {path}`)

	local pullCallback = require("@root/" .. path) :: () -> ()
	pullCallback()
end

if process.args[2] and process.args[2]:lower() == "true" then
	local luneVersion = getLuneVersion()
	local rokitLuneVersion = getRokitLuneVersion()

	assert(luneVersion == rokitLuneVersion, "Running lune version does not match rokit version.")
end

local targetName = assert(process.args[1] :: string?, "No target provided.")
pull(targetName)
