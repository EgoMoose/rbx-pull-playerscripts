--!strict

local fs = require("@lune/fs")

local function relativePath(path: string)
	local root = debug.info(2, "s"):sub(10, -3):gsub("\\", "/")
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

	return table.concat(splitRoot, "/")
end

return relativePath
