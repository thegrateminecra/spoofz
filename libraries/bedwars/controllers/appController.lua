--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.
local lplr = game:GetService('Players').LocalPlayer

local appController = {
    Name = 'AppController',
}

function appController.isAppOpen(name: string)
    return lplr.PlayerGui:FindFirstChild(name) and lplr.PlayerGui:FindFirstChild(name).Enabled
end

return appController