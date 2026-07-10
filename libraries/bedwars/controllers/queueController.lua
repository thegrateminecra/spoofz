--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.
local getcommit = function()
	return isfile('spoofz/profiles/commit.txt') and readfile('spoofz/profiles/commit.txt') or 'main'
end

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/thegrateminecra/spoofz/'..getcommit()..'/'..select(1, path:gsub('spoofz/', '')), true)
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

local Client = loadstring(downloadFile('spoofz/libraries/bedwars/client.lua'))()

local queueController = {
    Name = 'QueueController'
}

function queueController:joinQueue(queue: string)
    Client:Get('joinQueue'):SendToServer({
		['queueType'] = queue
	})
end

return queueController