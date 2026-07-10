local run = function(func) func() end
local cloneref = cloneref or function(obj) return obj end
local hookmetamethod = hookmetamethod or function() return 'aids executor' end

local runService = cloneref(game:GetService('RunService'))
local playersService = cloneref(game:GetService('Players'))
local replicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local inputService = cloneref(game:GetService('UserInputService'))

local lplr = playersService.LocalPlayer
local vape = shared.spoofz
local entitylib = vape.Libraries.entity
local sessioninfo = vape.Libraries.sessioninfo

local function notif(...)
	return vape:CreateNotification(...)
end

local getNearest = function(numb)
    numb = numb or math.huge

    local nearest, distance = nil, math.huge
    for index, value in workspace:GetChildren() do
        if not value:IsA('Model') or not value:GetAttribute('deployed') or value == game:GetService('Players').LocalPlayer.Character then
            continue
        end

        if not value.PrimaryPart or not value:FindFirstChild('Head') then
            continue
        end

        local Dist = game:GetService('Players').LocalPlayer:DistanceFromCharacter(value.PrimaryPart.Position)

        if Dist <= numb and Dist < distance and value:FindFirstChild('Humanoid') and value:FindFirstChild('Humanoid').Health > 0 then
            nearest = value
            distance = Dist
        end
    end

    return nearest, distance
end

for _, v in {'AntiRagdoll', 'TriggerBot', 'SilentAim', 'Disabler', 'Timer', 'ServerHop', 'MouseTP', 'MurderMystery', 'Reach', 'AutoClicker', 'Killaura', 'Invisible', 'Jesus', 'Swim', 'StaffDetector', 'AntiFall', 'Health'} do
	vape:Remove(v);
end

local Onetap = {
    ByteNetReliable = replicatedStorage:WaitForChild('ByteNetReliable'),

    Controllers = {
        Weapon = require(playersService.LocalPlayer.PlayerScripts.Start.Game.WeaponClient),
        Viewmodel = require(playersService.LocalPlayer.PlayerScripts.Start.Game.ViewmodelClient),
    }
}

local currTarget;
run(function()
    local old;
    local Wallbang;

    local SilentAim; SilentAim = vape.Categories.Combat:CreateModule({
        Name = 'SilentAim',
        Function = function(callback)
            if callback then
                task.spawn(function()
                    repeat
                        task.wait()

                        currTarget = getNearest();
                    until not SilentAim.Enabled
                end)

                old = hookmetamethod(game, '__namecall', newcclosure(function(self, ...)
                    if getnamecallmethod() == 'FireServer' and self == Onetap.ByteNetReliable and currTarget then
                        local args = {...}

                        if typeof(args[2]) == 'table' and typeof(args[2][1]) == 'Instance' then
                            args[2][1] = currTarget
                            args[2][2] = currTarget.Head
                        end
                    end

                    return old(self, ...)
                end))
            else
                hookmetamethod(game, '__namecall', old)
            end
        end,
        ExtraText = function()
            return 'Onetap'
        end
    })
end)

run(function()
    local AutoShootDelay;
    local AutoShoot; AutoShoot = vape.Categories.Combat:CreateModule({
        Name = 'AutoShoot',
        Function = function(callback)
            if callback then
                repeat
                    task.wait(AutoShootDelay.Value)
                    Onetap.Controllers.Weapon.fire()
                until not AutoShoot.Enabled
            end
        end
    })
    AutoShootDelay = AutoShoot:CreateSlider({
        Name = 'Delay',
        Min = 0,
        Max = 1,
        Default = 0.05,
        Decimal = 20,
    })
end)

run(function()
    local NoShootDelay; NoShootDelay = vape.Categories.Utility:CreateModule({
        Name = 'NoShootDelay',
        Function = function(callback)
            if callback then
                NoShootDelay:Clean(runService.Heartbeat:Connect(function()
                    Onetap.Controllers.Weapon.resetBullets(true)
                end))
            end
        end
    })
end)

run(function()
    local old;

    local NoShootDelay; NoShootDelay = vape.Categories.Render:CreateModule({
        Name = 'Viewmodel',
        Function = function(callback)
            if callback then
                old = Onetap.Controllers.Viewmodel.shoot
                Onetap.Controllers.Viewmodel.shoot = function() end
            else
                Onetap.Controllers.Viewmodel.shoot = old
            end
        end
    })
end)

run(function()
    local old;
    local UseKeybind
    local ForceThirdPerson; ForceThirdPerson = vape.Categories.Render:CreateModule({
        Name = 'ThirdPerson',
        Function = function(callback)
            if callback then
                if not UseKeybind.Enabled then
                    playersService.LocalPlayer.CameraMode = Enum.CameraMode.Classic
                end

                local isInThirdPerson = false
                ForceThirdPerson:Clean(playersService.LocalPlayer:GetPropertyChangedSignal('CameraMode'):Connect(function()
                    if playersService.LocalPlayer.CameraMode ~= Enum.CameraMode.Classic and (not UseKeybind or isInThirdPerson) then
                        playersService.LocalPlayer.CameraMode = Enum.CameraMode.Classic
                    end
                end))

                old = Onetap.Controllers.Weapon.scope
                if not UseKeybind.Enabled then
                    Onetap.Controllers.Weapon.scope = function() end
                end

                ForceThirdPerson:Clean(inputService.InputBegan:Connect(function(input: InputObject)
                    if not UseKeybind.Enabled then
                        return
                    end

                    if input.KeyCode ~= Enum.KeyCode.V then
                        return
                    end

                    isInThirdPerson = not isInThirdPerson

                    if isInThirdPerson then
                        playersService.LocalPlayer.CameraMode = Enum.CameraMode.Classic
                        Onetap.Controllers.Weapon.scope = function() end
                    else
                        Onetap.Controllers.Weapon.scope = old
                        playersService.LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
                    end
                end))
            else
                Onetap.Controllers.Weapon.scope = old
            end
        end
    })
    UseKeybind = ForceThirdPerson:CreateToggle({
        Name = 'Use Keybind',
        Tooltip = 'V is the bind to toggle 3rd person'
    })
end)
