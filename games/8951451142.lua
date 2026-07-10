local vape = shared.spoofz
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and vape then
		vape:CreateNotification('Spoofz', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/thegrateminecra/spoofz/'..readfile('spoofz/profiles/commit.txt')..'/'..select(1, path:gsub('spoofz/', '')), true)
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

vape.Place = 8768229691
if isfile('spoofz/games/'..vape.Place..'.lua') then
	loadstring(readfile('spoofz/games/'..vape.Place..'.lua'), 'skywars')()
else
	if not shared.SpoofzDeveloper then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/thegrateminecra/spoofz/'..readfile('spoofz/profiles/commit.txt')..'/games/'..vape.Place..'.lua', true)
		end)
		if suc and res ~= '404: Not Found' then
			loadstring(downloadFile('spoofz/games/'..vape.Place..'.lua'), 'skywars')()
		end
	end
end