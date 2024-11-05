--!strict

local function relativePath(path: string)
	local root = debug.info(2, "s"):sub(10, -3):gsub("\\", "/")
	local splitRoot = root:split("/")

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
