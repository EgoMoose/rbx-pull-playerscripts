--!strict

local fs = require("@lune/fs")
local net = require("@lune/net")

local zzlib = require("./zzlib/init")
local VersionHelper = require("./VersionHelper")

local function download(url: string)
	local content = net.request({
		url = url,
	})

	if content.ok then
		fs.writeFile("pull.zip", content.body)
		return content.body
	end

	error("Failed to download: " .. url)
end

local function extract(zip: string, manifest: { { string } })
	local files = {}
	local folders = {}
	local folderPathSet = {}

	for _, extractPath in manifest do
		-- zzlib uses \ for path delimiters we use this intitially, but very quickly
		-- switch to using / since it's cross platform agnostic and lune is smart enough
		-- to convert for windows

		local extractPathStr = table.concat(extractPath, "\\")
		local extractPathShortStr = table.concat(extractPath, "\\", 1, #extractPath - 1)

		for _, name, offset, size, packed, crc in zzlib.files(zip) do
			local isFolder = name:sub(1, 1) == "\\" and name:sub(-1, -1) == "\\"
			local path = if isFolder then name:sub(2, -2) else name

			if path:sub(1, #extractPathStr) == extractPathStr then
				local clippedPath = path:sub(#extractPathShortStr + 2):gsub("\\", "/")

				if isFolder then
					table.insert(folders, clippedPath)
					folderPathSet[clippedPath] = true
				else
					table.insert(files, {
						path = clippedPath,
						content = if packed then zzlib.unzip(zip, offset, crc) else zip:sub(offset, offset + size - 1),
					})
				end
			end
		end
	end

	-- convert to rojo / luau format
	for _, file in files do
		if file.path:sub(-4, -1) == ".lua" then
			local noExtension = file.path:sub(1, -5)
			if folderPathSet[noExtension] then
				file.path = noExtension .. "/init.luau"
			else
				file.path = noExtension .. ".luau"
			end
		end
	end

	return folders, files
end

export type PullOptions = {
	packageName: string,
	guid: string,
	manifest: { { string } },
	processor: (string) -> (),
}

local pullTicket = 0
local function pull(options: PullOptions)
	pullTicket = pullTicket + 1

	local url = `https://setup.rbxcdn.com/{options.guid}-{options.packageName}`
	local zipped = download(url)

	local tmpDirectory = options.guid .. pullTicket
	fs.writeDir(tmpDirectory)

	local folders, files = extract(zipped, options.manifest)

	for _, folderPath in folders do
		fs.writeDir(tmpDirectory .. "/" .. folderPath)
	end

	for _, file in files do
		if file.path:sub(-9, -1) == ".robloxrc" then
			continue
		end

		fs.writeFile(tmpDirectory .. "/" .. file.path, file.content)
	end

	options.processor(tmpDirectory)
	fs.removeDir(tmpDirectory)
end

return {
	pull = pull,
	getGuid = VersionHelper.getGuid,
	getVersion = VersionHelper.getVersion,
}
