repeat task.wait() until game:IsLoaded()
if shared.spoofz then
    shared.spoofz:Uninject()
    task.wait()
end

local vape
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and vape then
		vape:CreateNotification('Spoofz', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local queue_on_teleport = queue_on_teleport or function() end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end

local getcommit = function()
	return isfile('spoofz/profiles/commit.txt') and readfile('spoofz/profiles/commit.txt') or 'production'
end

local cloneref = cloneref or function(obj)
	return obj
end
local playersService = cloneref(game:GetService('Players'))
local httpService = cloneref(game:GetService('HttpService'))

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/thegrateminecra/spoofz/'..getcommit().. '/'..select(1, path:gsub('spoofz/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function finishLoading()
	vape.Init = nil
	vape:Load()
	task.spawn(function()
		repeat
			vape:Save()
			task.wait(10)
		until not vape.Loaded
	end)

	task.spawn(function()
		repeat
			task.wait(30)
			if not vape.Loaded then break end
			if shared.SpoofzDeveloper or shared.SpoofzDeveloper then break end
			local success, res = pcall(function()
			return game:HttpGet('https://api.github.com/repos/thegrateminecra/spoofz/commits/main', true)
		end)

		if success then
			local json = httpService:JSONDecode(res)
				if json.sha == readfile('spoofz/profiles/commit.txt') then return end
				writefile('spoofz/profiles/commit.txt', json.sha or 'production')
				delfolder('spoofz/games')
				delfolder('spoofz/guis')
				delfolder('spoofz/libraries')
				vape:CreateNotification('Updated', 'A new update will be applied on reload. Reinject now to update immediately.')
			end
		until not vape.Loaded
	end)

	local teleportedServers
	vape:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
		if (not teleportedServers) and (not shared.SpoofzIndependent) then
			teleportedServers = true
			local teleportScript = [[
				shared.spoofzreload = true
				loadstring(downloadFile('spoofz/main.lua'), 'main')()
			]]
			if shared.SpoofzDeveloper then
				teleportScript = 'shared.SpoofzDeveloper = true\n'..teleportScript
			end
			if shared.SpoofzCustomProfile then
				teleportScript = 'shared.SpoofzCustomProfile = "'..shared.SpoofzCustomProfile..'"\n'..teleportScript
			end
			vape:Save()
			queue_on_teleport(teleportScript)
		end
	end))

	if not shared.spoofzreload then
		if not vape.Categories then return end
		if vape.Categories.Main.Options['GUI bind indicator'].Enabled then
			vape:CreateNotification('Finished Loading', vape.VapeButton and 'Press the button in the top right to open GUI' or 'Press '..table.concat(vape.Keybind, ' + '):upper()..' to open GUI', 5)
		end
	end
end

if not isfile('spoofz/profiles/gui.txt') then
	writefile('spoofz/profiles/gui.txt', 'new')
end
local gui = readfile('spoofz/profiles/gui.txt')

if not isfolder('spoofz/assets/'..gui) then
	makefolder('spoofz/assets/'..gui)
end
vape = loadstring(downloadFile('spoofz/guis/'..gui..'.lua'), 'gui')()
shared.spoofz = vape

if not shared.SpoofzIndependent then
	loadstring(downloadFile('spoofz/games/universal.lua'), 'universal')()
	if isfile('spoofz/games/'..game.PlaceId..'.lua') then
		loadstring(readfile('spoofz/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
	else
		if not shared.SpoofzDeveloper then
			local suc, res = pcall(function()
				return game:HttpGet('https://raw.githubusercontent.com/thegrateminecra/spoofz/'..getcommit()..'/games/'..game.PlaceId..'.lua', true)
			end)
			if suc and res ~= '404: Not Found' then
				loadstring(downloadFile('spoofz/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
			end
		end
	end
	finishLoading()
else
	vape.Init = finishLoading
	return vape
end
