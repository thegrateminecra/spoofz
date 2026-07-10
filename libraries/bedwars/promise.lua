-- Decompiled with Potassium.

local u1 = {
    ["__mode"] = "k"
}
local function v7(u2, p3) --[[ Line: 28 ]]
    local v4 = {}
    for _, v5 in ipairs(p3) do
        v4[v5] = v5
    end
    return setmetatable(v4, {
        ["__index"] = function(_, p6) --[[ Name: __index, Line 36 ]]
            --[[
            Upvalues:
                [1] = u2
            --]]
            error(string.format("%s is not in %s!", p6, u2), 2)
        end,
        ["__newindex"] = function() --[[ Name: __newindex, Line 39 ]]
            --[[
            Upvalues:
                [1] = u2
            --]]
            error(string.format("Creating new members in %s is not allowed!", u2), 2)
        end
    })
end
local u8 = {
    ["Kind"] = v7("Promise.Error.Kind", {
        "ExecutionError",
        "AlreadyCancelled",
        "NotResolvedInTime",
        "TimedOut"
    })
}
u8.__index = u8
function u8.new(p9, p10) --[[ Line: 64 ]]
    --[[
    Upvalues:
        [1] = u8
    --]]
    local v11 = p9 or {}
    local v12 = {}
    local v13 = v11.error
    v12.error = tostring(v13) or "[This error has no error text.]"
    v12.trace = v11.trace
    v12.context = v11.context
    v12.kind = v11.kind
    v12.parent = p10
    v12.createdTick = os.clock()
    v12.createdTrace = debug.traceback()
    local v14 = u8
    return setmetatable(v12, v14)
end
function u8.is(p15) --[[ Line: 77 ]]
    if type(p15) == "table" then
        local v16 = getmetatable(p15)
        if type(v16) == "table" then
            local v17
            if rawget(p15, "error") == nil then
                v17 = false
            else
                local v18 = rawget(v16, "extend")
                v17 = type(v18) == "function"
            end
            return v17
        end
    end
    return false
end
function u8.isKind(p19, p20) --[[ Line: 89 ]]
    --[[
    Upvalues:
        [1] = u8
    --]]
    local v21 = p20 ~= nil
    assert(v21, "Argument #2 to Promise.Error.isKind must not be nil")
    local v22 = u8.is(p19)
    if v22 then
        v22 = p19.kind == p20
    end
    return v22
end
function u8.extend(p23, p24) --[[ Line: 95 ]]
    --[[
    Upvalues:
        [1] = u8
    --]]
    local v25 = p24 or {}
    v25.kind = v25.kind or p23.kind
    return u8.new(v25, p23)
end
function u8.getErrorChain(p26) --[[ Line: 103 ]]
    local v27 = { p26 }
    while v27[#v27].parent do
        local v28 = v27[#v27].parent
        table.insert(v27, v28)
    end
    return v27
end
function u8.__tostring(p29) --[[ Line: 113 ]]
    local v30 = { string.format("-- Promise.Error(%s) --", p29.kind or "?") }
    for _, v31 in ipairs(p29:getErrorChain()) do
        local v32 = table.concat
        local v33 = { v31.trace or v31.error, v31.context }
        table.insert(v30, v32(v33, "\n"))
    end
    return table.concat(v30, "\n")
end
local function u34(...) --[[ Line: 137 ]]
    return select("#", ...), { ... }
end
local function u36(p35, ...) --[[ Line: 144 ]]
    return p35, select("#", ...), { ... }
end
local function u43(u37, p38, ...) --[[ Line: 171 ]]
    --[[
    Upvalues:
        [1] = u36
        [2] = u8
    --]]
    local v39 = u36
    local v40 = xpcall
    local v41 = u37 ~= nil
    assert(v41, "traceback is nil")
    return v39(v40(p38, function(p42) --[[ Line: 151 ]]
        --[[
        Upvalues:
            [1] = u8
            [2] = u37
        --]]
        if type(p42) == "table" then
            return p42
        else
            return u8.new({
                ["error"] = p42,
                ["kind"] = u8.Kind.ExecutionError,
                ["trace"] = debug.traceback(tostring(p42), 2),
                ["context"] = "Promise created at:\n\n" .. u37
            })
        end
    end, ...))
end
local u44 = {
    ["Error"] = u8,
    ["Status"] = v7("Promise.Status", {
        "Started",
        "Resolved",
        "Rejected",
        "Cancelled"
    }),
    ["_getTime"] = os.clock,
    ["_timeEvent"] = game:GetService("RunService").Heartbeat,
    ["_unhandledRejectionCallbacks"] = {},
    ["prototype"] = {}
}
u44.__index = u44.prototype
function u44._new(p45, u46, p47) --[[ Line: 230 ]]
    --[[
    Upvalues:
        [1] = u44
        [2] = u1
        [3] = u43
    --]]
    if p47 ~= nil and not u44.is(p47) then
        error("Argument #2 to Promise.new must be a promise or nil", 2)
    end
    local u48 = {
        ["_values"] = nil,
        ["_valuesLength"] = -1,
        ["_unhandledRejection"] = true,
        ["_cancellationHook"] = nil,
        ["_source"] = p45,
        ["_status"] = u44.Status.Started,
        ["_queuedResolve"] = {},
        ["_queuedReject"] = {},
        ["_queuedFinally"] = {},
        ["_parent"] = p47
    }
    local v49 = u1
    u48._consumers = setmetatable({}, v49)
    if p47 and p47._status == u44.Status.Started then
        p47._consumers[u48] = true
    end
    local v50 = u44
    setmetatable(u48, v50)
    local function u51(...) --[[ Line: 275 ]]
        --[[
        Upvalues:
            [1] = u48
        --]]
        u48:_resolve(...)
    end
    local function u52(...) --[[ Line: 279 ]]
        --[[
        Upvalues:
            [1] = u48
        --]]
        u48:_reject(...)
    end
    local function u54(p53) --[[ Line: 283 ]]
        --[[
        Upvalues:
            [1] = u48
            [2] = u44
        --]]
        if p53 then
            if u48._status == u44.Status.Cancelled then
                p53()
            else
                u48._cancellationHook = p53
            end
        end
        return u48._status == u44.Status.Cancelled
    end
    coroutine.wrap(function() --[[ Line: 295 ]]
        --[[
        Upvalues:
            [1] = u43
            [2] = u48
            [3] = u46
            [4] = u51
            [5] = u52
            [6] = u54
        --]]
        local v55, _, v56 = u43(u48._source, u46, u51, u52, u54)
        if not v55 then
            u52(v56[1])
        end
    end)()
    return u48
end
function u44.new(p57) --[[ Line: 338 ]]
    --[[
    Upvalues:
        [1] = u44
    --]]
    return u44._new(debug.traceback(nil, 2), p57)
end
function u44.__tostring(p58) --[[ Line: 342 ]]
    return string.format("Promise(%s)", p58._status)
end
function u44.defer(u59) --[[ Line: 364 ]]
    --[[
    Upvalues:
        [1] = u44
        [2] = u43
    --]]
    local u60 = debug.traceback(nil, 2)
    return u44._new(u60, function(u61, u62, u63) --[[ Line: 367 ]]
        --[[
        Upvalues:
            [1] = u44
            [2] = u43
            [3] = u60
            [4] = u59
        --]]
        local u64 = nil
        u64 = u44._timeEvent:Connect(function() --[[ Line: 369 ]]
            --[[
            Upvalues:
                [1] = u64
                [2] = u43
                [3] = u60
                [4] = u59
                [5] = u61
                [6] = u62
                [7] = u63
            --]]
            u64:Disconnect()
            local v65, _, v66 = u43(u60, u59, u61, u62, u63)
            if not v65 then
                u62(v66[1])
            end
        end)
    end)
end
u44.async = u44.defer
function u44.resolve(...) --[[ Line: 407 ]]
    --[[
    Upvalues:
        [1] = u34
        [2] = u44
    --]]
    local u67, u68 = u34(...)
    return u44._new(debug.traceback(nil, 2), function(p69) --[[ Line: 409 ]]
        --[[
        Upvalues:
            [1] = u68
            [2] = u67
        --]]
        local v70 = u68
        local v71 = u67
        p69(unpack(v70, 1, v71))
    end)
end
function u44.reject(...) --[[ Line: 424 ]]
    --[[
    Upvalues:
        [1] = u34
        [2] = u44
    --]]
    local u72, u73 = u34(...)
    return u44._new(debug.traceback(nil, 2), function(_, p74) --[[ Line: 426 ]]
        --[[
        Upvalues:
            [1] = u73
            [2] = u72
        --]]
        local v75 = u73
        local v76 = u72
        p74(unpack(v75, 1, v76))
    end)
end
function u44._try(p77, u78, ...) --[[ Line: 435 ]]
    --[[
    Upvalues:
        [1] = u34
        [2] = u44
    --]]
    local u79, u80 = u34(...)
    return u44._new(p77, function(p81) --[[ Line: 438 ]]
        --[[
        Upvalues:
            [1] = u78
            [2] = u80
            [3] = u79
        --]]
        local v82 = u80
        local v83 = u79
        p81(u78(unpack(v82, 1, v83)))
    end)
end
function u44.try(p84, ...) --[[ Line: 466 ]]
    --[[
    Upvalues:
        [1] = u44
    --]]
    return u44._try(debug.traceback(nil, 2), p84, ...)
end
function u44._all(p85, u86, u87) --[[ Line: 475 ]]
    --[[
    Upvalues:
        [1] = u44
    --]]
    if type(u86) ~= "table" then
        error(string.format("Please pass a list of promises to %s", "Promise.all"), 3)
    end
    for v88, v89 in pairs(u86) do
        if not u44.is(v89) then
            error(string.format("Non-promise value passed into %s at index %s", "Promise.all", (tostring(v88))), 3)
        end
    end
    if #u86 == 0 or u87 == 0 then
        return u44.resolve({})
    else
        return u44._new(p85, function(u90, u91, p92) --[[ Line: 493 ]]
            --[[
            Upvalues:
                [1] = u87
                [2] = u86
            --]]
            local u93 = {}
            local u94 = {}
            local u95 = 0
            local u96 = 0
            local u97 = false
            local function u100(p98, ...) --[[ Line: 511 ]]
                --[[
                Upvalues:
                    [1] = u97
                    [2] = u95
                    [3] = u87
                    [4] = u93
                    [5] = u86
                    [6] = u90
                    [7] = u94
                --]]
                if not u97 then
                    u95 = u95 + 1
                    if u87 == nil then
                        u93[p98] = ...
                    else
                        u93[u95] = ...
                    end
                    if u95 >= (u87 or #u86) then
                        u97 = true
                        u90(u93)
                        for _, v99 in ipairs(u94) do
                            v99:cancel()
                        end
                    end
                end
            end
            p92(function() --[[ Name: cancel, Line 504 ]]
                --[[
                Upvalues:
                    [1] = u94
                --]]
                for _, v101 in ipairs(u94) do
                    v101:cancel()
                end
            end)
            local u102 = u97
            for u103, v104 in ipairs(u86) do
                u94[u103] = v104:andThen(function(...) --[[ Line: 536 ]]
                    --[[
                    Upvalues:
                        [1] = u100
                        [2] = u103
                    --]]
                    u100(u103, ...)
                end, function(...) --[[ Line: 538 ]]
                    --[[
                    Upvalues:
                        [1] = u96
                        [2] = u87
                        [3] = u86
                        [4] = u94
                        [5] = u102
                        [6] = u91
                    --]]
                    u96 = u96 + 1
                    if u87 == nil or #u86 - u96 < u87 then
                        for _, v105 in ipairs(u94) do
                            v105:cancel()
                        end
                        u102 = true
                        u91(...)
                    end
                end)
            end
            if u102 then
                for _, v106 in ipairs(u94) do
                    v106:cancel()
                end
            end
        end)
    end
end
function u44.all(p107) --[[ Line: 580 ]]
    --[[
    Upvalues:
        [1] = u44
    --]]
    return u44._all(debug.traceback(nil, 2), p107)
end
function u44.fold(p108, u109, p110) --[[ Line: 609 ]]
    --[[
    Upvalues:
        [1] = u44
    --]]
    local v111 = type(p108) == "table"
    assert(v111, "Bad argument #1 to Promise.fold: must be a table")
    local v112
    if type(u109) == "function" then
        v112 = true
    elseif type(u109) == "table" then
        local v113 = getmetatable(u109)
        if v113 then
            local v114 = rawget(v113, "__call")
            v112 = type(v114) == "function"
        else
            v112 = false
        end
    else
        v112 = false
    end
    assert(v112, "Bad argument #2 to Promise.fold: must be a function")
    local u115 = u44.resolve(p110)
    return u44.each(p108, function(u116, u117) --[[ Line: 614 ]]
        --[[
        Upvalues:
            [1] = u115
            [2] = u109
        --]]
        u115 = u115:andThen(function(p118) --[[ Line: 615 ]]
            --[[
            Upvalues:
                [1] = u109
                [2] = u116
                [3] = u117
            --]]
            return u109(p118, u116, u117)
        end)
    end):andThen(function() --[[ Line: 618 ]]
        --[[
        Upvalues:
            [1] = u115
        --]]
        return u115
    end)
end
function u44.some(p119, p120) --[[ Line: 642 ]]
    --[[
    Upvalues:
        [1] = u44
    --]]
    local v121 = type(p120) == "number"
    assert(v121, "Bad argument #2 to Promise.some: must be a number")
    return u44._all(debug.traceback(nil, 2), p119, p120)
end
function u44.any(p122) --[[ Line: 666 ]]
    --[[
    Upvalues:
        [1] = u44
    --]]
    return u44._all(debug.traceback(nil, 2), p122, 1):andThen(function(p123) --[[ Line: 667 ]]
        return p123[1]
    end)
end
function u44.allSettled(u124) --[[ Line: 688 ]]
    --[[
    Upvalues:
        [1] = u44
    --]]
    if type(u124) ~= "table" then
        error(string.format("Please pass a list of promises to %s", "Promise.allSettled"), 2)
    end
    for v125, v126 in pairs(u124) do
        if not u44.is(v126) then
            error(string.format("Non-promise value passed into %s at index %s", "Promise.allSettled", (tostring(v125))), 2)
        end
    end
    if #u124 == 0 then
        return u44.resolve({})
    else
        return u44._new(debug.traceback(nil, 2), function(u127, _, p128) --[[ Line: 706 ]]
            --[[
            Upvalues:
                [1] = u124
            --]]
            local u129 = {}
            local u130 = {}
            local u131 = 0
            local function u133(p132, ...) --[[ Line: 716 ]]
                --[[
                Upvalues:
                    [1] = u131
                    [2] = u129
                    [3] = u124
                    [4] = u127
                --]]
                u131 = u131 + 1
                u129[p132] = ...
                if u131 >= #u124 then
                    u127(u129)
                end
            end
            p128(function() --[[ Line: 726 ]]
                --[[
                Upvalues:
                    [1] = u130
                --]]
                for _, v134 in ipairs(u130) do
                    v134:cancel()
                end
            end)
            for u135, v136 in ipairs(u124) do
                u130[u135] = v136:finally(function(...) --[[ Line: 735 ]]
                    --[[
                    Upvalues:
                        [1] = u133
                        [2] = u135
                    --]]
                    u133(u135, ...)
                end)
            end
        end)
    end
end
function u44.race(u137) --[[ Line: 766 ]]
    --[[
    Upvalues:
        [1] = u44
    --]]
    local v138 = type(u137) == "table"
    local v139 = string.format
    assert(v138, v139("Please pass a list of promises to %s", "Promise.race"))
    for v140, v141 in pairs(u137) do
        local v142 = u44.is(v141)
        local v143 = string.format
        local v144 = tostring(v140)
        assert(v142, v143("Non-promise value passed into %s at index %s", "Promise.race", v144))
    end
    return u44._new(debug.traceback(nil, 2), function(u145, u146, p147) --[[ Line: 773 ]]
        --[[
        Upvalues:
            [1] = u137
        --]]
        local u148 = {}
        local u149 = false
        if not p147(function(...) --[[ Line: 784 ]]
            --[[
            Upvalues:
                [1] = u148
                [2] = u149
                [3] = u146
            --]]
            for _, v150 in ipairs(u148) do
                v150:cancel()
            end
            u149 = true
            return u146(...)
        end) then
            local u151 = u149
            for v152, v153 in ipairs(u137) do
                u148[v152] = v153:andThen(function(...) --[[ Line: 784 ]]
                    --[[
                    Upvalues:
                        [1] = u148
                        [2] = u151
                        [3] = u145
                    --]]
                    for _, v154 in ipairs(u148) do
                        v154:cancel()
                    end
                    u151 = true
                    return u145(...)
                end, function(...) --[[ Line: 784 ]]
                    --[[
                    Upvalues:
                        [1] = u148
                        [2] = u151
                        [3] = u146
                    --]]
                    for _, v155 in ipairs(u148) do
                        v155:cancel()
                    end
                    u151 = true
                    return u146(...)
                end)
            end
            if u151 then
                for _, v156 in ipairs(u148) do
                    v156:cancel()
                end
            end
        end
    end)
end
function u44.each(u157, u158) --[[ Line: 861 ]]
    --[[
    Upvalues:
        [1] = u44
        [2] = u8
    --]]
    local v159 = type(u157) == "table"
    local v160 = string.format
    assert(v159, v160("Please pass a list of promises to %s", "Promise.each"))
    local v161
    if type(u158) == "function" then
        v161 = true
    elseif type(u158) == "table" then
        local v162 = getmetatable(u158)
        if v162 then
            local v163 = rawget(v162, "__call")
            v161 = type(v163) == "function"
        else
            v161 = false
        end
    else
        v161 = false
    end
    local v164 = string.format
    assert(v161, v164("Please pass a handler function to %s!", "Promise.each"))
    return u44._new(debug.traceback(nil, 2), function(p165, p166, p167) --[[ Line: 865 ]]
        --[[
        Upvalues:
            [1] = u157
            [2] = u44
            [3] = u8
            [4] = u158
        --]]
        local v168 = {}
        local u169 = {}
        local u170 = false
        p167(function() --[[ Line: 877 ]]
            --[[
            Upvalues:
                [1] = u170
                [2] = u169
            --]]
            u170 = true
            for _, v171 in ipairs(u169) do
                v171:cancel()
            end
        end)
        local v172 = u170
        local v173 = {}
        for v174, v175 in ipairs(u157) do
            if u44.is(v175) then
                if v175:getStatus() == u44.Status.Cancelled then
                    for _, v176 in ipairs(u169) do
                        v176:cancel()
                    end
                    return p166(u8.new({
                        ["error"] = "Promise is cancelled",
                        ["kind"] = u8.Kind.AlreadyCancelled,
                        ["context"] = string.format("The Promise that was part of the array at index %d passed into Promise.each was already cancelled when Promise.each began.\n\nThat Promise was created at:\n\n%s", v174, v175._source)
                    }))
                end
                if v175:getStatus() == u44.Status.Rejected then
                    for _, v177 in ipairs(u169) do
                        v177:cancel()
                    end
                    return p166(select(2, v175:await()))
                end
                local v178 = v175:andThen(function(...) --[[ Line: 910 ]]
                    return ...
                end)
                table.insert(u169, v178)
                v173[v174] = v178
            else
                v173[v174] = v175
            end
        end
        for v179, v182 in ipairs(v173) do
            if u44.is(v182) then
                local v181, v182 = v182:await()
                if not v181 then
                    for _, v183 in ipairs(u169) do
                        v183:cancel()
                    end
                    return p166(v182)
                end
            end
            if v172 then
                return
            end
            local v184 = u44.resolve(u158(v182, v179))
            table.insert(u169, v184)
            local v185, v186 = v184:await()
            if not v185 then
                for _, v187 in ipairs(u169) do
                    v187:cancel()
                end
                return p166(v186)
            end
            v168[v179] = v186
        end
        p165(v168)
    end)
end
function u44.is(p188) --[[ Line: 960 ]]
    --[[
    Upvalues:
        [1] = u44
    --]]
    if type(p188) ~= "table" then
        return false
    end
    local v189 = getmetatable(p188)
    if v189 == u44 then
        return true
    end
    if v189 ~= nil then
        if type(v189) == "table" then
            local v190 = rawget(v189, "__index")
            if type(v190) == "table" then
                local v191 = rawget(v189, "__index")
                local v192 = rawget(v191, "andThen")
                local v193
                if type(v192) == "function" then
                    v193 = true
                else
                    local v194 = type(v192) == "table" and getmetatable(v192)
                    if v194 then
                        local v195 = rawget(v194, "__call")
                        v193 = type(v195) == "function"
                    else
                        v193 = false
                    end
                end
                if v193 then
                    return true
                end
            end
        end
        return false
    end
    local v196 = p188.andThen
    if type(v196) == "function" then
        return true
    end
    local v197 = type(v196) == "table" and getmetatable(v196)
    if v197 then
        local v198 = rawget(v197, "__call")
        if type(v198) == "function" then
            return true
        end
    end
    return false
end
function u44.promisify(u199) --[[ Line: 1009 ]]
    --[[
    Upvalues:
        [1] = u44
    --]]
    return function(...) --[[ Line: 1010 ]]
        --[[
        Upvalues:
            [1] = u44
            [2] = u199
        --]]
        return u44._try(debug.traceback(nil, 2), u199, ...)
    end
end
local u200 = nil
local u201 = nil
function u44.delay(p202) --[[ Line: 1040 ]]
    --[[
    Upvalues:
        [1] = u44
        [2] = u201
        [3] = u200
    --]]
    local v203 = type(p202) == "number"
    assert(v203, "Bad argument #1 to Promise.delay, must be a number.")
    local u204 = (p202 < 0.016666666666666666 or p202 == (1 / 0)) and 0.016666666666666666 or p202
    return u44._new(debug.traceback(nil, 2), function(p205, _, p206) --[[ Line: 1048 ]]
        --[[
        Upvalues:
            [1] = u44
            [2] = u204
            [3] = u201
            [4] = u200
        --]]
        local v207 = u44._getTime()
        local v208 = v207 + u204
        local u209 = {
            ["resolve"] = p205,
            ["startTime"] = v207,
            ["endTime"] = v208
        }
        if u201 == nil then
            u200 = u209
            u201 = u44._timeEvent:Connect(function() --[[ Line: 1060 ]]
                --[[
                Upvalues:
                    [1] = u44
                    [2] = u200
                    [3] = u201
                --]]
                local v210 = u44._getTime()
                while u200 ~= nil and u200.endTime < v210 do
                    local v211 = u200
                    u200 = v211.next
                    if u200 == nil then
                        u201:Disconnect()
                        u201 = nil
                    else
                        u200.previous = nil
                    end
                    v211.resolve(u44._getTime() - v211.startTime)
                end
            end)
        elseif u200.endTime < v208 then
            local v212 = u200
            local v213 = v212.next
            while v213 ~= nil and v213.endTime < v208 do
                local v214 = v213.next
                v212 = v213
                v213 = v214
            end
            v212.next = u209
            u209.previous = v212
            if v213 ~= nil then
                u209.next = v213
                v213.previous = u209
            end
        else
            u209.next = u200
            u200.previous = u209
            u200 = u209
        end
        p206(function() --[[ Line: 1105 ]]
            --[[
            Upvalues:
                [1] = u209
                [2] = u200
                [3] = u201
            --]]
            local v215 = u209.next
            if u200 == u209 then
                if v215 == nil then
                    u201:Disconnect()
                    u201 = nil
                else
                    v215.previous = nil
                end
                u200 = v215
            else
                local v216 = u209.previous
                v216.next = v215
                if v215 ~= nil then
                    v215.previous = v216
                end
            end
        end)
    end)
end
local function v221(p217, u218, u219) --[[ Line: 1169 ]]
    --[[
    Upvalues:
        [1] = u44
        [2] = u8
    --]]
    local u220 = debug.traceback(nil, 2)
    return u44.race({ u44.delay(u218):andThen(function() --[[ Line: 1173 ]]
            --[[
            Upvalues:
                [1] = u44
                [2] = u219
                [3] = u8
                [4] = u218
                [5] = u220
            --]]
            return u44.reject(u219 == nil and u8.new({
                ["error"] = "Timed out",
                ["kind"] = u8.Kind.TimedOut,
                ["context"] = string.format("Timeout of %d seconds exceeded.\n:timeout() called at:\n\n%s", u218, u220)
            }) or u219)
        end), p217 })
end
u44.prototype.timeout = v221
function u44.prototype.getStatus(p222) --[[ Line: 1193 ]]
    return p222._status
end
local function v247(u223, u224, u225, u226) --[[ Line: 1202 ]]
    --[[
    Upvalues:
        [1] = u44
        [2] = u43
        [3] = u8
    --]]
    u223._unhandledRejection = false
    return u44._new(u224, function(u227, u228) --[[ Line: 1206 ]]
        --[[
        Upvalues:
            [1] = u225
            [2] = u224
            [3] = u43
            [4] = u226
            [5] = u223
            [6] = u44
            [7] = u8
        --]]
        local v229
        if u225 then
            local u230 = u224
            local u231 = u225
            v229 = function(...) --[[ Line: 180 ]]
                --[[
                Upvalues:
                    [1] = u43
                    [2] = u230
                    [3] = u231
                    [4] = u227
                    [5] = u228
                --]]
                local v232, v233, v234 = u43(u230, u231, ...)
                if v232 then
                    u227(unpack(v234, 1, v233))
                else
                    u228(v234[1])
                end
            end
        else
            v229 = u227
        end
        local v235
        if u226 then
            local u236 = u224
            local u237 = u226
            v235 = function(...) --[[ Line: 180 ]]
                --[[
                Upvalues:
                    [1] = u43
                    [2] = u236
                    [3] = u237
                    [4] = u227
                    [5] = u228
                --]]
                local v238, v239, v240 = u43(u236, u237, ...)
                if v238 then
                    u227(unpack(v240, 1, v239))
                else
                    u228(v240[1])
                end
            end
        else
            v235 = u228
        end
        if u223._status == u44.Status.Started then
            local v241 = u223._queuedResolve
            table.insert(v241, v229)
            local v242 = u223._queuedReject
            table.insert(v242, v235)
            return
        elseif u223._status == u44.Status.Resolved then
            local v243 = u223._values
            local v244 = u223._valuesLength
            v229(unpack(v243, 1, v244))
            return
        elseif u223._status == u44.Status.Rejected then
            local v245 = u223._values
            local v246 = u223._valuesLength
            v235(unpack(v245, 1, v246))
        elseif u223._status == u44.Status.Cancelled then
            u228(u8.new({
                ["error"] = "Promise is cancelled",
                ["kind"] = u8.Kind.AlreadyCancelled,
                ["context"] = "Promise created at\n\n" .. u224
            }))
        end
    end, u223)
end
u44.prototype._andThen = v247
function u44.prototype.andThen(p248, p249, p250) --[[ Line: 1255 ]]
    local v251
    if p249 == nil or type(p249) == "function" then
        v251 = true
    elseif type(p249) == "table" then
        local v252 = getmetatable(p249)
        if v252 then
            local v253 = rawget(v252, "__call")
            v251 = type(v253) == "function"
        else
            v251 = false
        end
    else
        v251 = false
    end
    local v254 = string.format
    assert(v251, v254("Please pass a handler function to %s!", "Promise:andThen"))
    local v255
    if p250 == nil or type(p250) == "function" then
        v255 = true
    elseif type(p250) == "table" then
        local v256 = getmetatable(p250)
        if v256 then
            local v257 = rawget(v256, "__call")
            v255 = type(v257) == "function"
        else
            v255 = false
        end
    else
        v255 = false
    end
    local v258 = string.format
    assert(v255, v258("Please pass a handler function to %s!", "Promise:andThen"))
    return p248:_andThen(debug.traceback(nil, 2), p249, p250)
end
function u44.prototype.catch(p259, p260) --[[ Line: 1275 ]]
    local v261
    if p260 == nil or type(p260) == "function" then
        v261 = true
    elseif type(p260) == "table" then
        local v262 = getmetatable(p260)
        if v262 then
            local v263 = rawget(v262, "__call")
            v261 = type(v263) == "function"
        else
            v261 = false
        end
    else
        v261 = false
    end
    local v264 = string.format
    assert(v261, v264("Please pass a handler function to %s!", "Promise:catch"))
    return p259:_andThen(debug.traceback(nil, 2), nil, p260)
end
function u44.prototype.tap(p265, u266) --[[ Line: 1296 ]]
    --[[
    Upvalues:
        [1] = u44
        [2] = u34
    --]]
    local v267
    if type(u266) == "function" then
        v267 = true
    elseif type(u266) == "table" then
        local v268 = getmetatable(u266)
        if v268 then
            local v269 = rawget(v268, "__call")
            v267 = type(v269) == "function"
        else
            v267 = false
        end
    else
        v267 = false
    end
    local v270 = string.format
    assert(v267, v270("Please pass a handler function to %s!", "Promise:tap"))
    return p265:_andThen(debug.traceback(nil, 2), function(...) --[[ Line: 1298 ]]
        --[[
        Upvalues:
            [1] = u266
            [2] = u44
            [3] = u34
        --]]
        local v271 = u266(...)
        if not u44.is(v271) then
            return ...
        end
        local u272, u273 = u34(...)
        return v271:andThen(function() --[[ Line: 1303 ]]
            --[[
            Upvalues:
                [1] = u273
                [2] = u272
            --]]
            local v274 = u273
            local v275 = u272
            return unpack(v274, 1, v275)
        end)
    end)
end
function u44.prototype.andThenCall(p276, u277, ...) --[[ Line: 1331 ]]
    --[[
    Upvalues:
        [1] = u34
    --]]
    local v278
    if type(u277) == "function" then
        v278 = true
    elseif type(u277) == "table" then
        local v279 = getmetatable(u277)
        if v279 then
            local v280 = rawget(v279, "__call")
            v278 = type(v280) == "function"
        else
            v278 = false
        end
    else
        v278 = false
    end
    local v281 = string.format
    assert(v278, v281("Please pass a handler function to %s!", "Promise:andThenCall"))
    local u282, u283 = u34(...)
    return p276:_andThen(debug.traceback(nil, 2), function() --[[ Line: 1334 ]]
        --[[
        Upvalues:
            [1] = u277
            [2] = u283
            [3] = u282
        --]]
        local v284 = u283
        local v285 = u282
        return u277(unpack(v284, 1, v285))
    end)
end
function u44.prototype.andThenReturn(p286, ...) --[[ Line: 1361 ]]
    --[[
    Upvalues:
        [1] = u34
    --]]
    local u287, u288 = u34(...)
    return p286:_andThen(debug.traceback(nil, 2), function() --[[ Line: 1363 ]]
        --[[
        Upvalues:
            [1] = u288
            [2] = u287
        --]]
        local v289 = u288
        local v290 = u287
        return unpack(v289, 1, v290)
    end)
end
function u44.prototype.cancel(p291) --[[ Line: 1379 ]]
    --[[
    Upvalues:
        [1] = u44
    --]]
    if p291._status == u44.Status.Started then
        p291._status = u44.Status.Cancelled
        if p291._cancellationHook then
            p291._cancellationHook()
        end
        if p291._parent then
            p291._parent:_consumerCancelled(p291)
        end
        for v292 in pairs(p291._consumers) do
            v292:cancel()
        end
        p291:_finalize()
    end
end
function u44.prototype._consumerCancelled(p293, p294) --[[ Line: 1405 ]]
    --[[
    Upvalues:
        [1] = u44
    --]]
    if p293._status == u44.Status.Started then
        p293._consumers[p294] = nil
        if next(p293._consumers) == nil then
            p293:cancel()
        end
    end
end
function u44.prototype._finally(u295, u296, u297, u298) --[[ Line: 1421 ]]
    --[[
    Upvalues:
        [1] = u44
        [2] = u43
    --]]
    if not u298 then
        u295._unhandledRejection = false
    end
    return u44._new(u296, function(u299, u300) --[[ Line: 1427 ]]
        --[[
        Upvalues:
            [1] = u297
            [2] = u296
            [3] = u43
            [4] = u298
            [5] = u295
            [6] = u44
        --]]
        local u301
        if u297 then
            local u302 = u296
            local u303 = u297
            u301 = function(...) --[[ Line: 180 ]]
                --[[
                Upvalues:
                    [1] = u43
                    [2] = u302
                    [3] = u303
                    [4] = u299
                    [5] = u300
                --]]
                local v304, v305, v306 = u43(u302, u303, ...)
                if v304 then
                    u299(unpack(v306, 1, v305))
                else
                    u300(v306[1])
                end
            end
        else
            u301 = u299
        end
        local v307 = u298 and function(...) --[[ Line: 1435 ]]
            --[[
            Upvalues:
                [1] = u295
                [2] = u44
                [3] = u299
                [4] = u301
            --]]
            if u295._status == u44.Status.Rejected then
                return u299(u295)
            else
                return u301(...)
            end
        end or u301
        if u295._status == u44.Status.Started then
            local v308 = u295._queuedFinally
            table.insert(v308, v307)
        else
            v307(u295._status)
        end
    end, u295)
end
function u44.prototype.finally(p309, p310) --[[ Line: 1485 ]]
    local v311
    if p310 == nil or type(p310) == "function" then
        v311 = true
    elseif type(p310) == "table" then
        local v312 = getmetatable(p310)
        if v312 then
            local v313 = rawget(v312, "__call")
            v311 = type(v313) == "function"
        else
            v311 = false
        end
    else
        v311 = false
    end
    local v314 = string.format
    assert(v311, v314("Please pass a handler function to %s!", "Promise:finally"))
    return p309:_finally(debug.traceback(nil, 2), p310)
end
function u44.prototype.finallyCall(p315, u316, ...) --[[ Line: 1499 ]]
    --[[
    Upvalues:
        [1] = u34
    --]]
    local v317
    if type(u316) == "function" then
        v317 = true
    elseif type(u316) == "table" then
        local v318 = getmetatable(u316)
        if v318 then
            local v319 = rawget(v318, "__call")
            v317 = type(v319) == "function"
        else
            v317 = false
        end
    else
        v317 = false
    end
    local v320 = string.format
    assert(v317, v320("Please pass a handler function to %s!", "Promise:finallyCall"))
    local u321, u322 = u34(...)
    return p315:_finally(debug.traceback(nil, 2), function() --[[ Line: 1502 ]]
        --[[
        Upvalues:
            [1] = u316
            [2] = u322
            [3] = u321
        --]]
        local v323 = u322
        local v324 = u321
        return u316(unpack(v323, 1, v324))
    end)
end
function u44.prototype.finallyReturn(p325, ...) --[[ Line: 1525 ]]
    --[[
    Upvalues:
        [1] = u34
    --]]
    local u326, u327 = u34(...)
    return p325:_finally(debug.traceback(nil, 2), function() --[[ Line: 1527 ]]
        --[[
        Upvalues:
            [1] = u327
            [2] = u326
        --]]
        local v328 = u327
        local v329 = u326
        return unpack(v328, 1, v329)
    end)
end
function u44.prototype.done(p330, p331) --[[ Line: 1548 ]]
    local v332
    if p331 == nil or type(p331) == "function" then
        v332 = true
    elseif type(p331) == "table" then
        local v333 = getmetatable(p331)
        if v333 then
            local v334 = rawget(v333, "__call")
            v332 = type(v334) == "function"
        else
            v332 = false
        end
    else
        v332 = false
    end
    local v335 = string.format
    assert(v332, v335("Please pass a handler function to %s!", "Promise:done"))
    return p330:_finally(debug.traceback(nil, 2), p331, true)
end
function u44.prototype.doneCall(p336, u337, ...) --[[ Line: 1562 ]]
    --[[
    Upvalues:
        [1] = u34
    --]]
    local v338
    if type(u337) == "function" then
        v338 = true
    elseif type(u337) == "table" then
        local v339 = getmetatable(u337)
        if v339 then
            local v340 = rawget(v339, "__call")
            v338 = type(v340) == "function"
        else
            v338 = false
        end
    else
        v338 = false
    end
    local v341 = string.format
    assert(v338, v341("Please pass a handler function to %s!", "Promise:doneCall"))
    local u342, u343 = u34(...)
    return p336:_finally(debug.traceback(nil, 2), function() --[[ Line: 1565 ]]
        --[[
        Upvalues:
            [1] = u337
            [2] = u343
            [3] = u342
        --]]
        local v344 = u343
        local v345 = u342
        return u337(unpack(v344, 1, v345))
    end, true)
end
function u44.prototype.doneReturn(p346, ...) --[[ Line: 1588 ]]
    --[[
    Upvalues:
        [1] = u34
    --]]
    local u347, u348 = u34(...)
    return p346:_finally(debug.traceback(nil, 2), function() --[[ Line: 1590 ]]
        --[[
        Upvalues:
            [1] = u348
            [2] = u347
        --]]
        local v349 = u348
        local v350 = u347
        return unpack(v349, 1, v350)
    end, true)
end
function u44.prototype.awaitStatus(p351) --[[ Line: 1602 ]]
    --[[
    Upvalues:
        [1] = u44
    --]]
    p351._unhandledRejection = false
    if p351._status == u44.Status.Started then
        local u352 = Instance.new("BindableEvent")
        p351:finally(function() --[[ Line: 1608 ]]
            --[[
            Upvalues:
                [1] = u352
            --]]
            u352:Fire()
        end)
        u352.Event:Wait()
        u352:Destroy()
    end
    if p351._status == u44.Status.Resolved then
        local v353 = p351._status
        local v354 = p351._values
        local v355 = p351._valuesLength
        return v353, unpack(v354, 1, v355)
    end
    if p351._status ~= u44.Status.Rejected then
        return p351._status
    end
    local v356 = p351._status
    local v357 = p351._values
    local v358 = p351._valuesLength
    return v356, unpack(v357, 1, v358)
end
local function u360(p359, ...) --[[ Line: 1625 ]]
    --[[
    Upvalues:
        [1] = u44
    --]]
    return p359 == u44.Status.Resolved, ...
end
function u44.prototype.await(p361) --[[ Line: 1650 ]]
    --[[
    Upvalues:
        [1] = u360
    --]]
    return u360(p361:awaitStatus())
end
local function u363(p362, ...) --[[ Line: 1654 ]]
    --[[
    Upvalues:
        [1] = u44
    --]]
    if p362 ~= u44.Status.Resolved then
        error(... == nil and "Expected Promise rejected with no value." or ..., 3)
    end
    return ...
end
function u44.prototype.expect(p364) --[[ Line: 1687 ]]
    --[[
    Upvalues:
        [1] = u363
    --]]
    return u363(p364:awaitStatus())
end
u44.prototype.awaitValue = u44.prototype.expect
function u44.prototype._unwrap(p365) --[[ Line: 1701 ]]
    --[[
    Upvalues:
        [1] = u44
    --]]
    if p365._status == u44.Status.Started then
        error("Promise has not resolved or rejected.", 2)
    end
    local v366 = p365._status == u44.Status.Resolved
    local v367 = p365._values
    local v368 = p365._valuesLength
    return v366, unpack(v367, 1, v368)
end
local function v377(u369, ...) --[[ Line: 1711 ]]
    --[[
    Upvalues:
        [1] = u44
        [2] = u8
        [3] = u34
    --]]
    if u369._status == u44.Status.Started then
        if u44.is((...)) then
            if select("#", ...) > 1 then
                local v370 = string.format("When returning a Promise from andThen, extra arguments are discarded! See:\n\n%s", u369._source)
                warn(v370)
            end
            local u371 = ...
            local v373 = u371:andThen(function(...) --[[ Line: 1732 ]]
                --[[
                Upvalues:
                    [1] = u369
                --]]
                u369:_resolve(...)
            end, function(...) --[[ Line: 1734 ]]
                --[[
                Upvalues:
                    [1] = u371
                    [2] = u8
                    [3] = u369
                --]]
                local v372 = u371._values[1]
                if u371._error then
                    v372 = u8.new({
                        ["context"] = "[No stack trace available as this Promise originated from an older version of the Promise library (< v2)]",
                        ["error"] = u371._error,
                        ["kind"] = u8.Kind.ExecutionError
                    })
                end
                if u8.isKind(v372, u8.Kind.ExecutionError) then
                    return u369:_reject(v372:extend({
                        ["error"] = "This Promise was chained to a Promise that errored.",
                        ["trace"] = "",
                        ["context"] = string.format("The Promise at:\n\n%s\n...Rejected because it was chained to the following Promise, which encountered an error:\n", u369._source)
                    }))
                end
                u369:_reject(...)
            end)
            if v373._status == u44.Status.Cancelled then
                u369:cancel()
            elseif v373._status == u44.Status.Started then
                u369._parent = v373
                v373._consumers[u369] = true
            end
        else
            u369._status = u44.Status.Resolved
            local v374, v375 = u34(...)
            u369._valuesLength = v374
            u369._values = v375
            for _, v376 in ipairs(u369._queuedResolve) do
                coroutine.wrap(v376)(...)
            end
            u369:_finalize()
            return
        end
    else
        if u44.is((...)) then
            (...):_consumerCancelled(u369)
        end
        return
    end
end
u44.prototype._resolve = v377
function u44.prototype._reject(u378, ...) --[[ Line: 1782 ]]
    --[[
    Upvalues:
        [1] = u44
        [2] = u34
    --]]
    if u378._status == u44.Status.Started then
        u378._status = u44.Status.Rejected
        local v379, v380 = u34(...)
        u378._valuesLength = v379
        u378._values = v380
        local v381 = u378._queuedReject
        if next(v381) == nil then
            local u382 = tostring((...))
            coroutine.wrap(function() --[[ Line: 1804 ]]
                --[[
                Upvalues:
                    [1] = u44
                    [2] = u378
                    [3] = u382
                --]]
                u44._timeEvent:Wait()
                if u378._unhandledRejection then
                    local v383 = string.format("Unhandled Promise rejection:\n\n%s\n\n%s", u382, u378._source)
                    for _, v384 in ipairs(u44._unhandledRejectionCallbacks) do
                        local v385 = task.spawn
                        local v386 = u378
                        local v387 = u378._values
                        local v388 = u378._valuesLength
                        v385(v384, v386, unpack(v387, 1, v388))
                    end
                    if not u44.TEST then
                        warn(v383)
                    end
                else
                    return
                end
            end)()
        else
            for _, v389 in ipairs(u378._queuedReject) do
                coroutine.wrap(v389)(...)
            end
        end
        u378:_finalize()
    end
end
function u44.prototype._finalize(p390) --[[ Line: 1836 ]]
    --[[
    Upvalues:
        [1] = u44
    --]]
    for _, v391 in ipairs(p390._queuedFinally) do
        coroutine.wrap(v391)(p390._status)
    end
    p390._queuedFinally = nil
    p390._queuedReject = nil
    p390._queuedResolve = nil
    if not u44.TEST then
        p390._parent = nil
        p390._consumers = nil
    end
end
local function v396(p392, p393) --[[ Line: 1871 ]]
    --[[
    Upvalues:
        [1] = u44
        [2] = u8
    --]]
    local v394 = debug.traceback(nil, 2)
    if p392._status == u44.Status.Resolved then
        return p392:_andThen(v394, function(...) --[[ Line: 1874 ]]
            return ...
        end)
    end
    local v395 = u44.reject
    if p393 == nil then
        p393 = u8.new({
            ["error"] = "This Promise was not resolved in time for :now()",
            ["kind"] = u8.Kind.NotResolvedInTime,
            ["context"] = ":now() was called at:\n\n" .. v394
        }) or p393
    end
    return v395(p393)
end
u44.prototype.now = v396
function u44.retry(u397, u398, ...) --[[ Line: 1915 ]]
    --[[
    Upvalues:
        [1] = u44
    --]]
    local v399
    if type(u397) == "function" then
        v399 = true
    elseif type(u397) == "table" then
        local v400 = getmetatable(u397)
        if v400 then
            local v401 = rawget(v400, "__call")
            v399 = type(v401) == "function"
        else
            v399 = false
        end
    else
        v399 = false
    end
    assert(v399, "Parameter #1 to Promise.retry must be a function")
    local v402 = type(u398) == "number"
    assert(v402, "Parameter #2 to Promise.retry must be a number")
    local u403 = { ... }
    local u404 = select("#", ...)
    return u44.resolve(u397(...)):catch(function(...) --[[ Line: 1921 ]]
        --[[
        Upvalues:
            [1] = u398
            [2] = u44
            [3] = u397
            [4] = u403
            [5] = u404
        --]]
        if u398 <= 0 then
            return u44.reject(...)
        end
        local v405 = u403
        local v406 = u404
        return u44.retry(u397, u398 - 1, unpack(v405, 1, v406))
    end)
end
function u44.retryWithDelay(u407, u408, u409, ...) --[[ Line: 1942 ]]
    --[[
    Upvalues:
        [1] = u44
    --]]
    local v410
    if type(u407) == "function" then
        v410 = true
    elseif type(u407) == "table" then
        local v411 = getmetatable(u407)
        if v411 then
            local v412 = rawget(v411, "__call")
            v410 = type(v412) == "function"
        else
            v410 = false
        end
    else
        v410 = false
    end
    assert(v410, "Parameter #1 to Promise.retry must be a function")
    local v413 = type(u408) == "number"
    assert(v413, "Parameter #2 (times) to Promise.retry must be a number")
    local v414 = type(u409) == "number"
    assert(v414, "Parameter #3 (seconds) to Promise.retry must be a number")
    local u415 = { ... }
    local u416 = select("#", ...)
    return u44.resolve(u407(...)):catch(function(...) --[[ Line: 1949 ]]
        --[[
        Upvalues:
            [1] = u408
            [2] = u44
            [3] = u409
            [4] = u407
            [5] = u415
            [6] = u416
        --]]
        if u408 <= 0 then
            return u44.reject(...)
        end
        u44.delay(u409):await()
        local v417 = u415
        local v418 = u416
        return u44.retryWithDelay(u407, u408 - 1, u409, unpack(v417, 1, v418))
    end)
end
function u44.fromEvent(u419, p420) --[[ Line: 1984 ]]
    --[[
    Upvalues:
        [1] = u44
    --]]
    local u421 = p420 or function() --[[ Line: 1985 ]]
        return true
    end
    return u44._new(debug.traceback(nil, 2), function(u422, _, p423) --[[ Line: 1989 ]]
        --[[
        Upvalues:
            [1] = u419
            [2] = u421
        --]]
        local u424 = nil
        local u425 = false
        local function v426() --[[ Line: 1993 ]]
            --[[
            Upvalues:
                [1] = u424
            --]]
            u424:Disconnect()
            u424 = nil
        end
        u424 = u419:Connect(function(...) --[[ Line: 2002 ]]
            --[[
            Upvalues:
                [1] = u421
                [2] = u422
                [3] = u424
                [4] = u425
            --]]
            local v427 = u421(...)
            if v427 == true then
                u422(...)
                if u424 then
                    u424:Disconnect()
                    u424 = nil
                else
                    u425 = true
                end
            else
                if type(v427) ~= "boolean" then
                    error("Promise.fromEvent predicate should always return a boolean")
                end
                return
            end
        end)
        if u425 and u424 then
            return v426()
        end
        p423(v426)
    end)
end
function u44.onUnhandledRejection(u428) --[[ Line: 2036 ]]
    --[[
    Upvalues:
        [1] = u44
    --]]
    local v429 = u44._unhandledRejectionCallbacks
    table.insert(v429, u428)
    return function() --[[ Line: 2039 ]]
        --[[
        Upvalues:
            [1] = u44
            [2] = u428
        --]]
        local v430 = table.find(u44._unhandledRejectionCallbacks, u428)
        if v430 then
            table.remove(u44._unhandledRejectionCallbacks, v430)
        end
    end
end
return u44
