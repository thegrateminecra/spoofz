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

local Client = loadstring(downloadFile('spoofz/libraries/bedwars/client.lua'))();
local vape = shared.spoofz;

local matchController = {
    Name = 'MatchController',
    matchState = 0,
}

function matchController:getMatchState()
    return self.matchState
end

local matchTimer = game:GetService('Players').LocalPlayer.PlayerGui:WaitForChild('TopBarAppGui'):WaitForChild('TopBarApp'):FindFirstChild('2'):FindFirstChild('5')
local seconds, lastSeconds = 0, 0

task.spawn(function()
	repeat task.wait()
		seconds = tonumber(matchTimer.Text:split(':')[2])
	until matchController.matchState == 2
end)

task.spawn(function()
	repeat lastSeconds = seconds task.wait() until seconds > lastSeconds

	matchController.matchState = 1;
	print(matchController.matchState)
end)

vape:Clean(Client:Get('MatchEndEvent'):Connect(function(winTable: {
		winningTeamId: number
	})

	matchController.matchState = 2;
	print(matchController.matchState)
end))

return matchController