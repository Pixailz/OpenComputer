--Cient

-- Get API
local component = require("component")
local modem = component.modem
local s = require("serialization")
-- Local Function

function openPort(port)
  if (modem.isOpen(port) == false)then
    modem.open(port)
    print("Client redy on port: " .. port)
  else
    print("Error port " .. port .. " already used.")
    modem.close(port)
    os.exit()
  end
end

function sendBroadcast(port, cmd, arg)


  data = {}
  data.cmd = cmd
  data.arg = arg

  if(modem.broadcast(port, s.serialize(data)))then
    print("Broadcast send on port: " .. port .. " | Cmd = ".. cmd .. " | Arg = " .. arg)
  else
    print("failed to send message.")
  end
end

-- Client Config

args = {...}

DNS_PORT = 4444
CMD = args[1] or "GET"
PORT = args[2] or "1234"


sendBroadcast(DNS_PORT, CMD, PORT)

modem.close(port)
