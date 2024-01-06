--[[ DNS CLASS

- dns.port
- dns.root_path

- dns.init()

]]--

local	dns = {}

-- IMPORT

	-- VANILLA

	-- CUSTOM
local	log = require("log")
log.setup_log_file("/var/log/dns.log")

local	server = require("server")
local	utils = require("utils")
local	e_handler = require("event_handler")

-- BEGIN

	-- ATTRIBUTS
dns.port = 4444
dns.root_path = "/usr/dns"

function	dns.server_init()
	utils.mkdir(dns.root_path)
	server.listen(dns.port)
end

return dns


------------------------"SET"--------------------------

function dns.addClient(port, mac, pub_key)
	local currentPath = dns.root_path .. "/" .. port

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

  function dns.setClient(clientPacket, clientMAC)
	registerPath = dns.addClient(clientPacket.arg, clientMAC)

	if (registerPath == nil and f.exists(dns.root_path .. "/" .. clientPacket.arg))then
	  log.warn("DNS: [" .. clientMAC .. "] -> Attempts to register a client already listed !")
	elseif (registerPath == nil)then
	  log.fail("DNS: [" .. clientMAC .. "] -> An error when registering a client. <Potential critical error !!>")
	else
	  log.print("DNS: New client registered! [MAC: " .. clientMAC .. "| Port: " .. clientPacket.arg .. "] File created on <" .. registerPath .. ">.")
	end
  end

  ----------------------"GET"----------------------------

function dns.getMAC(port)
	local macSize = 36
	local currentPath = dns.root_path .. "/" .. port
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
	mac = dns.getMAC(port)

	if (mac == nil)then
		server.send("DNS to Client: No address assigned to port: " .. port)
	else
		server.send("DNS to Client: port: " .. port .. " link to address [" .. mac .. "]")
	end
end

---------------------"MAIN"-----------------------------

while true do
	local clientPacket = e_handler.pull("modem_message")

	clientPacket = s.unserialize(msg)

	if (pkt.cmd == "SET")then
	  setClient(pkt, from)
	elseif (pkt.cmd == "GET")then
	  getClient(pkt.arg)
	else
	  print("Command not found")
	end
  end
