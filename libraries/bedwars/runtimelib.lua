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

local u1 = loadstring(downloadFile('spoofz/libraries/bedwars/promise.lua'))()
local u2 = game:GetService("RunService")
local u11 = {
    ["Promise"] = u1,
    ["getModule"] = function(p3, p4, p5) --[[ Name: getModule, Line 17 ]]
        --[[
        Upvalues:
            [1] = u2
        --]]
        local v6
        if p5 == nil then
            v6 = "@rbxts"
        else
            v6 = p4
            p4 = p5
        end
        if u2:IsRunning() and u2:IsClient() then
            local v7 = u2:IsStudio()
            if v7 then
                v7 = p3:FindFirstAncestorWhichIsA("Plugin") ~= nil
            end
            if not (v7 or game:IsLoaded()) then
                game.Loaded:Wait()
            end
        end
        while true do
            local v8 = p3:FindFirstChild("node_modules")
            if v8 then
                local v9 = v8:FindFirstChild(v6)
                local v10 = v9 and v9:FindFirstChild(p4)
                if v10 then
                    return v10
                end
            end
            p3 = p3.Parent
            if p3 == nil then
                error("roblox-ts: " .. "Could not find module: " .. p4, 2)
                return
            end
        end
    end
}
local u12 = {}
local u13 = {}
function u11.import(p14, p15, ...) --[[ Line: 51 ]]
    --[[
    Upvalues:
        [1] = u12
        [2] = u13
        [3] = u11
    --]]
    for v16 = 1, select("#", ...) do
        p15 = p15:WaitForChild((select(v16, ...)))
    end
    if p15.ClassName ~= "ModuleScript" then
        error("roblox-ts: " .. "Failed to import! Expected ModuleScript, got " .. p15.ClassName, 2)
    end
    u12[p14] = p15
    local v17 = p15
    local v18 = 0
    while p15 do
        v18 = v18 + 1
        p15 = u12[p15]
        if p15 == v17 then
            local v19 = p15.Name
            for _ = 1, v18 do
                p15 = u12[p15]
                v19 = v19 .. "  \226\135\146 " .. p15.Name
            end
            error("roblox-ts: " .. "Failed to import! Detected a circular dependency chain: " .. v19, 2)
        end
    end
    if not u13[v17] then
        if _G[v17] then
            error("roblox-ts: " .. "Invalid module access! Do you have multiple TS runtimes trying to import this? " .. v17:GetFullName(), 2)
        end
        _G[v17] = u11
        u13[v17] = true
    end
    local v20 = require(v17)
    if u12[p14] == v17 then
        u12[p14] = nil
    end
    return v20
end
function u11.instanceof(p21, p22) --[[ Line: 111 ]]
    if type(p22) == "table" then
        local v23 = p22.instanceof
        if type(v23) == "function" then
            return p22.instanceof(p21)
        end
    end
    if type(p21) == "table" then
        local v24 = getmetatable(p21)
        while v24 ~= nil do
            if v24 == p22 then
                return true
            end
            local v25 = getmetatable(v24)
            if v25 then
                v24 = v25.__index
            else
                v24 = nil
            end
        end
    end
    return false
end
function u11.async(u26) --[[ Line: 136 ]]
    --[[
    Upvalues:
        [1] = u1
    --]]
    return function(...) --[[ Line: 137 ]]
        --[[
        Upvalues:
            [1] = u1
            [2] = u26
        --]]
        local u27 = select("#", ...)
        local u28 = { ... }
        return u1.new(function(u29, u30) --[[ Line: 140 ]]
            --[[
            Upvalues:
                [1] = u26
                [2] = u28
                [3] = u27
            --]]
            coroutine.wrap(function() --[[ Line: 141 ]]
                --[[
                Upvalues:
                    [1] = u26
                    [2] = u28
                    [3] = u27
                    [4] = u29
                    [5] = u30
                --]]
                local v31 = u28
                local v32 = u27
                local v33, v34 = pcall(u26, unpack(v31, 1, v32))
                if v33 then
                    u29(v34)
                else
                    u30(v34)
                end
            end)()
        end)
    end
end
function u11.await(p35) --[[ Line: 153 ]]
    --[[
    Upvalues:
        [1] = u1
    --]]
    if u1.is(p35) then
        local v36, v37 = p35:awaitStatus()
        if v36 == u1.Status.Resolved then
            return v37
        elseif v36 == u1.Status.Rejected then
            error(v37, 2)
        else
            error("The awaited Promise was cancelled", 2)
        end
    else
        return p35
    end
end
function u11.bit_lrsh(p38, p39) --[[ Line: 179 ]]
    local v40 = bit32.arshift(p38, p39)
    if bit32.btest(v40, 2147483648) then
        return v40 - 4294967296
    else
        return v40
    end
end
u11.TRY_RETURN = 1
u11.TRY_BREAK = 2
u11.TRY_CONTINUE = 3
function u11.try(p41, p42, p43) --[[ Line: 187 ]]
    local u44 = nil
    local u45 = nil
    local v47, v48, v49 = xpcall(p41, function(p46) --[[ Line: 191 ]]
        --[[
        Upvalues:
            [1] = u44
            [2] = u45
        --]]
        u44 = p46
        u45 = debug.traceback()
    end)
    local v50, v51
    if v47 or not p42 then
        v50 = v49
        v51 = v48
    else
        v51, v50 = p42(u44, u45)
        if not v51 then
            v50 = v49
            v51 = v48
        end
    end
    local v52, v53
    if p43 then
        v52, v53 = p43()
        if not v52 then
            v53 = v50
            v52 = v51
        end
    else
        v53 = v50
        v52 = v51
    end
    return v52, v53
end
function u11.generator(p54) --[[ Line: 211 ]]
    local u55 = coroutine.create(p54)
    return {
        ["next"] = function(...) --[[ Name: next, Line 214 ]]
            --[[
            Upvalues:
                [1] = u55
            --]]
            if coroutine.status(u55) == "dead" then
                return {
                    ["done"] = true
                }
            end
            local v56, v57 = coroutine.resume(u55, ...)
            if v56 == false then
                error(v57, 2)
            end
            return {
                ["value"] = v57,
                ["done"] = coroutine.status(u55) == "dead"
            }
        end
    }
end
return u11
