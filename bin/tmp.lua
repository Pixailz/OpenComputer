local	component = require("component")

-- local	e_handler = require("event_handler")
-- e_handler.set_waiting("touch", "interrupted")
local	log	= require("log")

--[==[
AD_ARRIVAL
AD_END

AC_ARRIVAL
AC_END
AC_DEADEND
]==]--

local plate = component.proxy(component.get("98bc6aca"))
local homeplate = component.proxy(component.get("51318106"))
local plate3 = component.proxy(component.get("a2fcba4f"))
local red2 = component.proxy(component.get("fc814c69"))

print("Running Arrival")
plate.setThrottle(0)
print("Throttle Set To 0")
plate.setBrake(0.295)
print("Brake Applied")
plate.horn()
plate.bell()
print("Arrival Completed")

while true do
	if red2.getInput(sides.top) > 0 then
		homeplate.setBrake(1)
		os.sleep(0.2)
		break
	else
		print("Waiting For Train To Stop")
		os.sleep(0.2)
	end
	print("---------- ----------")
	os.sleep(0.2)
end

print("Train Succesfully Stopped")
print("Departing In 60 Seconds")
os.sleep(10)
print("Departing in 50 Seconds")
os.sleep(10)
print("Departing in 40 Seconds")
os.sleep(10)
print("Departing in 30 Seconds")
os.sleep(10)
print("Departing in 20 Seconds")
os.sleep(10)
print("Departing in 10 Seconds")
os.sleep(10)
print("Train Is Departing")
os.execute("traindeparture")
