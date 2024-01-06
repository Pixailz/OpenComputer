local	e_handler = require("event_handler")
local	server = require("server")

server.listen(4444)

e_handler.set_waiting("modem_message")
data = e_handler.run()

print(data)
