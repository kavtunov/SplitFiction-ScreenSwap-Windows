--[[
  ScreenSwapMod for Split Fiction
  Hotkeys:
    F8  - swap both players' viewport sides (Mio <-> Zoe layout)
    F7  - dump current LocalPlayer viewport Origin/Size to UE4SS log
    F6  - try force standard left/right split (fallback experiment)

  IMPORTANT:
  Hazelight uses a custom split-screen system. Simple Origin/Size swap
  may work in some scenes and break in others. Use F7 first, then F8,
  and check ue4ss/UE4SS.log after each attempt.
]]

local UEHelpers = require("UEHelpers")

local MOD_NAME = "ScreenSwapMod"
local swapped = false

local function log(msg)
    print(string.format("[%s] %s\n", MOD_NAME, tostring(msg)))
end

local function isValid(obj)
    return obj ~= nil and obj:IsValid()
end

local function getLocalPlayers()
    local players = {}
    local engine = UEHelpers.GetEngine()
    if not isValid(engine) then
        log("Engine invalid")
        return players
    end

    local gameViewport = engine.GameViewport
    if not isValid(gameViewport) then
        log("GameViewport invalid")
        return players
    end

    local world = gameViewport.World
    if not isValid(world) then
        -- Fallback: try FindFirstOf World
        world = FindFirstOf("World")
    end

    -- Preferred: GameInstance local players
    local gameInstance = nil
    if isValid(world) and world.OwningGameInstance then
        gameInstance = world.OwningGameInstance
    end

    if isValid(gameInstance) and gameInstance.LocalPlayers then
        local localPlayers = gameInstance.LocalPlayers
        local num = localPlayers:Num()
        for i = 0, num - 1 do
            local lp = localPlayers:Get(i)
            if isValid(lp) then
                table.insert(players, lp)
            end
        end
    end

    -- Fallback: find all ULocalPlayer
    if #players < 2 then
        players = {}
        local found = FindAllOf("LocalPlayer")
        if found then
            for _, lp in pairs(found) do
                if isValid(lp) then
                    table.insert(players, lp)
                end
            end
        end
    end

    return players
end

local function describePlayer(lp, index)
    local origin = lp.Origin
    local size = lp.Size
    local controllerName = "?"
    if isValid(lp.PlayerController) then
        controllerName = lp.PlayerController:GetFullName()
    end

    log(string.format(
        "P%d Origin=(%.3f, %.3f) Size=(%.3f, %.3f) Controller=%s",
        index,
        origin.X or origin.x or 0,
        origin.Y or origin.y or 0,
        size.X or size.x or 0,
        size.Y or size.y or 0,
        controllerName
    ))
end

local function dumpViewports()
    log("--- viewport dump ---")
    local players = getLocalPlayers()
    log(string.format("LocalPlayers found: %d", #players))
    for i, lp in ipairs(players) do
        describePlayer(lp, i)
    end
    log("--- end dump ---")
end

local function setVec2(target, x, y)
    -- UE4SS property writes can be field-by-field or whole struct depending on game
    if target == nil then
        return
    end
    if target.X ~= nil then
        target.X = x
        target.Y = y
    elseif target.x ~= nil then
        target.x = x
        target.y = y
    end
end

local function copyVec2(from)
    if from == nil then
        return { X = 0, Y = 0 }
    end
    return {
        X = from.X or from.x or 0,
        Y = from.Y or from.y or 0,
    }
end

local function swapViewports()
    ExecuteInGameThread(function()
        local players = getLocalPlayers()
        if #players < 2 then
            log(string.format("Need 2 local players, got %d. Are you in couch co-op?", #players))
            dumpViewports()
            return
        end

        local a = players[1]
        local b = players[2]

        local aOrigin = copyVec2(a.Origin)
        local aSize = copyVec2(a.Size)
        local bOrigin = copyVec2(b.Origin)
        local bSize = copyVec2(b.Size)

        log("Before swap:")
        describePlayer(a, 1)
        describePlayer(b, 2)

        -- Swap Origin + Size so BOTH sides move (Mio <-> Zoe)
        setVec2(a.Origin, bOrigin.X, bOrigin.Y)
        setVec2(a.Size, bSize.X, bSize.Y)
        setVec2(b.Origin, aOrigin.X, aOrigin.Y)
        setVec2(b.Size, aSize.X, aSize.Y)

        -- Some UE builds need assigning whole structs
        pcall(function()
            a.Origin = { X = bOrigin.X, Y = bOrigin.Y }
            a.Size = { X = bSize.X, Y = bSize.Y }
            b.Origin = { X = aOrigin.X, Y = aOrigin.Y }
            b.Size = { X = aSize.X, Y = aSize.Y }
        end)

        swapped = not swapped
        log(string.format("Swap applied. swapped=%s", tostring(swapped)))
        log("After swap:")
        describePlayer(a, 1)
        describePlayer(b, 2)
    end)
end

local function forceClassicLeftRight()
    ExecuteInGameThread(function()
        local players = getLocalPlayers()
        if #players < 2 then
            log("Need 2 players for force layout")
            return
        end

        -- If already swapped, invert the classic layout
        local left = players[1]
        local right = players[2]
        if swapped then
            left, right = right, left
        end

        setVec2(left.Origin, 0.0, 0.0)
        setVec2(left.Size, 0.5, 1.0)
        setVec2(right.Origin, 0.5, 0.0)
        setVec2(right.Size, 0.5, 1.0)

        pcall(function()
            left.Origin = { X = 0.0, Y = 0.0 }
            left.Size = { X = 0.5, Y = 1.0 }
            right.Origin = { X = 0.5, Y = 0.0 }
            right.Size = { X = 0.5, Y = 1.0 }
        end)

        log("Forced classic L/R layout (respecting swapped flag)")
        dumpViewports()
    end)
end

RegisterKeyBind(Key.F7, dumpViewports)
RegisterKeyBind(Key.F8, swapViewports)
RegisterKeyBind(Key.F6, forceClassicLeftRight)

log("Loaded. F7=dump, F8=swap both sides, F6=force classic L/R")
