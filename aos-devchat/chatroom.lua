

Colors = {
    red = "\27[31m",
    green = "\27[32m",
    blue = "\27[34m",
    reset = "\27[0m",
    gray = "\27[90m"
}

Members = Members or {}

Handlers.add(
  "Register",
  Handlers.utils.hasMatchingTag("Action", "Register"),
  function (msg)
    local isAddMembers=true;
    for index, value in ipairs(Members) do
      if value==msg.From then
        isAddMembers=false
        break
      end
    end
    if isAddMembers==true then
      table.insert(Members, msg.From)
    end
    Handlers.utils.reply("registered")(msg)
  end
)

Handlers.add(
  "UnRegister",
  Handlers.utils.hasMatchingTag("Action", "UnRegister"),
  function (msg)
    for index, value in ipairs(Members) do
      if value==msg.From then
        table.remove(Members, index)
      end
    end
  end
)

Handlers.add(
  "Broadcast",
  Handlers.utils.hasMatchingTag("Action", "Broadcast"),
  function (msg)
    Broadcast(msg)
  end
)


Handlers.add(
  "BroadcastDiscord",
  Handlers.utils.hasMatchingTag("Action", "BroadcastDiscord"),
  function (msg)
    BroadcastDiscord(msg)
  end
)


Handlers.add(
  "Announcement",
  Handlers.utils.hasMatchingTag("Action", "Announcement"),
  function (msg)
    print(Colors.green..msg.Event..Colors.red.." : "..Colors.reset.. msg.Data)
  end
)

function BroadcastDiscord(msg)
    for _, recipient in ipairs(Members) do
        ao.send({Target = recipient,Action = "Announcement", Data = msg.Data,Event=msg.Event})
    end
end

function Broadcast(msg)
    local fromText
    for _, recipient in ipairs(Members) do
        if #msg.From>10 then
            local firstFour = string.sub(msg.From, 1, 4)
            local lastFour = string.sub(msg.From, -4)
            fromText=firstFour.."...."..lastFour
        end
        ao.send({Target = recipient,Action = "Announcement", Data = msg.Data,Event=fromText})
    end
    ao.send({Target = ao.id,Action = "SendDiscordMsg", Data = msg.Data,Event=fromText,OriginatingFrom=msg.From})
end





