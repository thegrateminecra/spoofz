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

local Images = loadstring(readfile('spoofz/libraries/bedwars/images.lua'))()
local Client = loadstring(readfile('spoofz/libraries/bedwars/client.lua'))()

local blockController = {
    Name = 'BlockController'
}

local function clientBlockPlace(itemType: string, position: Vector3)
    local Part = Instance.new('Part')
    Part.Parent = workspace
    Part.Size = Vector3.new(2.99, 2.99, 2.99)
    Part.Transparency = 0
    Part.CanCollide = true
    Part.CanQuery = false
    Part.CanTouch = false
    Part.Anchored = true
    Part.CFrame = CFrame.new(position)

    for _, value in Enum.NormalId:GetEnumItems() do
        local Texture = Instance.new('Decal')
        Texture.Parent = Part
        --Texture.UVOffset = Vector2.new(3, 3)
        --Texture.UVScale = Vector2.new(3, 3)
        Texture.ZIndex = 2
        Texture.Texture = Images[itemType] or ''
        Texture.Face = value
    end

    task.delay(0.5, function()
        Part:Destroy()
    end)
end

local function correctClientPosition(Pos: Vector3)
    local X = math.floor(Pos.X / 3 + 0.5) * 3
    local Y = math.floor(Pos.Y / 3) * 3
    local Z = math.floor(Pos.Z / 3 + 0.5) * 3

    return Vector3.new(X, Y, Z)
end

function blockController.correctBlockPosition(Pos: Vector3)
    local X = math.round(Pos.X) / 3
    local Y = math.round(Pos.Y) / 3
    local Z = math.round(Pos.Z) / 3

    return Vector3.new(X, Y, Z)
end

function blockController:placeBlock(data: {
        itemType: string,
        position: Vector3,
    })

    clientBlockPlace(data.itemType, correctClientPosition(data.position))

    data.position = self.correctBlockPosition(data.position);

    return Client:Get('PlaceBlock'):CallServerAsync({
        position = data.position,
        blockType = data.itemType,
        blockData = 0,
        mouseBlockInfo = {
            placementPosition = data.position,
        }
    }).returned;
end

return blockController