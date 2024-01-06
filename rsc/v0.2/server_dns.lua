local  c = require("component")
local  e = require("event")
local  m = c.modem
local  s = require("serialization")
local  f = require("filesystem")

--- config

dnsPath = "/home/.dns"
dnsPort = 4444
---------------------"DNS init"------------------------

function DNS_Init()
  if (f.exists(dnsPath) == false)then
    f.makeDirectory(dnsPath)
  end
  m.open(dnsPort)
  if (m.isOpen(dnsPort))then
    print("[DNS open on " .. dnsPort .. "]")
  else
    print("Port " .. dnsPort .. " and already in use.")
  end
end

------------------------"SET"--------------------------

function addClient(port, mac)
  local currentPath = dnsPath .. "/" .. port

  if (f.exists(currentPath))then
    return nil
  end
  local fd = io.open(currentPath, "w")
  if not fd then
    return nil
  end

  fd:write(mac)
  fd:close()
  return currentPath
end

function setClient(clientPacket, clientMAC)
  registerPath = addClient(clientPacket.arg, clientMAC)

  if (registerPath == nil and f.exists(dnsPath .. "/" .. clientPacket.arg))then
    print("DNS: [" .. clientMAC .. "] -> Attempts to register a client already listed !")
  elseif (registerPath == nil)then
    print("DNS: [" .. clientMAC .. "] -> An error when registering a client. <Potential critical error !!>")
  else
    print("DNS: New client registered! [MAC: " .. clientMAC .. "| Port: " .. clientPacket.arg .. "] File created on <" .. registerPath .. ">.")
  end
end

----------------------"GET"----------------------------

function getMAC(port)
  local macSize = 36
  local currentPath = dnsPath .. "/" .. port
  local mac = nil

  if (f.exists(currentPath))then
    local fd = io.open(currentPath, "r")
    mac = fd:read(macSize)
    fd:close()
  else
    return nil
  end
  return mac
end

function getClient(port)
  mac = getMAC(port)

  if (mac == nil)then
    print("DNS to Client: No address assigned to port: " .. port)
  else
    print("DNS to Client: port: " .. port .. " link to address [" .. mac .. "]")
  end
end

---------------------"MAIN"-----------------------------

DNS_Init()

while true do
  local  _, to, from, port, dist, msg = e.pull("modem_message")
   pkt = s.unserialize(msg)


  if (pkt.cmd == "SET")then
    setClient(pkt, from)
  elseif (pkt.cmd == "GET")then
    getClient(pkt.arg)
  else
    print("Command not found")
  end
end
