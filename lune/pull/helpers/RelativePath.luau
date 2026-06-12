--!strict

local fs = require("@lune/fs")
local process = require("@lune/process")

local function relativePath(path: string)
	local root = debug.info(2, "s"):gsub("\\", "/")
	local splitRoot = string.split(root, "/")

	if not fs.isDir(table.concat(splitRoot, "/")) then
		table.remove(splitRoot)
	end

	for _, step in path:split("/") do
		local onlyDots = step:match("[%.]+") == step
		if onlyDots then
			for _ = 1, #step do
				table.remove(splitRoot)
			end
		else
			table.insert(splitRoot, step)
		end
	end

	local fullPath = table.concat(splitRoot, "/")
	local rootPath = "@root/" .. fullPath:sub(#process.cwd + 1)

	return fullPath, rootPath
end

return relativePath
