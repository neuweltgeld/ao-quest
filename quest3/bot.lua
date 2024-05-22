-- Initialize global variables to maintain current game state and process.
GameStatus = GameStatus or nil
ActionInProgress = ActionInProgress or false

LogEntries = LogEntries or {}

colorPalette = {
    crimson = "\27[31m",
    emerald = "\27[32m",
    azure = "\27[34m",
    neutral = "\27[0m",
    charcoal = "\27[90m"
}

function recordLog(category, message)
    LogEntries[category] = LogEntries[category] or {}
    table.insert(LogEntries[category], message)
end

function isWithinDistance(x1, y1, x2, y2, maxDist)
    return math.abs(x1 - x2) <= maxDist and math.abs(y1 - y2) <= maxDist
end

function evaluateNextMove()
    ao.send({Target = Game, Action = "RequestGameState"})
    local currentPlayer = GameStatus.Players[ao.id]
    locateNearestOpponent()
    local opponent = CurrentOpponent and GameStatus.Players[CurrentOpponent]

    if opponent then
        local opponentClose = isWithinDistance(currentPlayer.x, currentPlayer.y, opponent.x, opponent.y, 1)
        if currentPlayer.energy > 5 and opponentClose then
            print(colorPalette.crimson .. "Opponent nearby. Engaging." .. colorPalette.neutral)
            ao.send({Target = Game, Action = "ExecuteAttack", Player = ao.id, AttackEnergy = tostring(5)})
        elseif currentPlayer.energy > 0 then
            local moveDirection = calculateDirection(currentPlayer.x, currentPlayer.y, opponent.x, opponent.y)
            print(colorPalette.crimson .. "Approaching opponent. Direction: " .. moveDirection .. colorPalette.neutral)
            ao.send({Target = Game, Action = "MovePlayer", Player = ao.id, Direction = moveDirection})
        else
            print(colorPalette.charcoal .. "Insufficient energy to act." .. colorPalette.neutral)
        end
    else
        print(colorPalette.crimson .. "No opponent detected. Reevaluating actions." .. colorPalette.neutral)
    end
    ActionInProgress = false
end

function calculateDirection(x1, y1, x2, y2)
    local horMove = x2 - x1
    local verMove = y2 - y1
    local direction = ""

    if verMove > 0 then
        direction = "Downward"
    elseif verMove < 0 then
        direction = "Upward"
    end

    if horMove > 0 then
        direction = direction .. "Rightward"
    elseif horMove < 0 then
        direction = direction .. "Leftward"
    end

    return direction
end

function locateNearestOpponent()
    local currentPlayer = GameStatus.Players[ao.id]
    local minDistance = math.huge
    local closestOpponent = nil

    for id, state in pairs(GameStatus.Players) do
        if id ~= ao.id then
            local dist = math.sqrt((state.x - currentPlayer.x)^2 + (state.y - currentPlayer.y)^2)
            if dist < minDistance then
                minDistance = dist
                closestOpponent = id
            end
        end
    end

    CurrentOpponent = closestOpponent
    if CurrentOpponent then
        print(colorPalette.azure .. "Target acquired: ID " .. CurrentOpponent .. colorPalette.neutral)
    else
        print(colorPalette.crimson .. "No opponents within range." .. colorPalette.neutral)
    end
end

Handlers.add(
    "Elimination-AutoPay",
    Handlers.utils.hasMatchingTag("Action", "Eliminated"),
    function (msg)
        print(colorPalette.crimson .. "Elimination noticed. Processing autopay." .. colorPalette.neutral)
        ao.send({Target = CRED, Action = "Transfer", Recipient = Game, Quantity = "1000"})
    end
)

Handlers.add(
    "Payment-UpdateState",
    Handlers.utils.hasMatchingTag("Action", "Payment-Confirmed"),
    function (msg)
        print(colorPalette.emerald .. "Bot reactivated" .. colorPalette.neutral)
        ActionInProgress = false
        Send({Target = Game, Action = "RequestGameState", Name = Name, Owner = Owner})
    end
)

Handlers.add(
    "RequestStateOnTick",
    Handlers.utils.hasMatchingTag("Action", "Tick"),
    function ()
        ao.send({Target = Game, Action = "RequestGameState"})
    end
)

Handlers.add(
    "RefreshGameState",
    Handlers.utils.hasMatchingTag("Action", "GameStateUpdate"),
    function (msg)
        local json = require("json")
        GameStatus = json.decode(msg.Data)
        ao.send({Target = ao.id, Action = "StateUpdated"})
    end
)

Handlers.add(
    "evaluateNextMove",
    Handlers.utils.hasMatchingTag("Action", "StateUpdated"),
    function ()
        print("Analyzing surroundings..")
        evaluateNextMove()
        ao.send({Target = ao.id, Action = "Tick"})
    end
)

Handlers.add(
    "CounterAttack",
    Handlers.utils.hasMatchingTag("Action", "Hit"),
    function (msg)
        local playerEnergy = GameStatus.Players[ao.id].energy
        if playerEnergy < 5 then
            print(colorPalette.crimson .. "Player exhausted." .. colorPalette.neutral)
        else
            print(colorPalette.crimson .. "Initiating counterattack..." .. colorPalette.neutral)
            ao.send({Target = Game, Action = "PlayerAttack", AttackEnergy = tostring(playerEnergy)})
        end
        ao.send({Target = ao.id, Action = "Tick"})
    end
)

Handlers.add(
    "CollectRewards",
    function (msg)
        return msg.Action == "Credit-Notice" and msg.From == Game and "continue" or false
    end,
    function (msg)
        print(colorPalette.emerald .. "Collecting rewards" .. colorPalette.neutral)
        ao.send({Target = Game, Action = "Withdraw"})
    end
)

Handlers.add(
    "AutoRejoin",
    Handlers.utils.hasMatchingTag("Action", "Removed"),
    function (msg)
        print("Processing automatic fee payment.")
        ao.send({Target = CRED, Action = "Transfer", Recipient = Game, Quantity = "1000"})
    end
)
