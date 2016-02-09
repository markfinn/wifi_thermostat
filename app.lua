function runapp()
dhtpin=4 --gpio2

encsw=3 --gpio0
encqa=2 --gpio4
encqb=1 --gpio5

sdapin = 6  --gpio12
sclpin = 7 --gpio13
dispaddr = 0x3c

relaypin=8 --gpio15

print(node.heap())
require("app_setup")
print(node.heap())
require("app_temp")
print(node.heap())
require("app_mqtt")
print(node.heap())
require("app_disp")
print(node.heap())
require("app_enc")
print(node.heap())
require("app_other")
print(node.heap())

settings={onsetpoint=20,offsetpoint=5}
setsetpoint(settings.offsetpoint)
end

function install()
node.compile("init.lua")
node.compile("app.lua")
node.compile("app_setup.lua")
node.compile("app_temp.lua")
node.compile("app_mqtt.lua")
node.compile("app_disp.lua")
node.compile("app_enc.lua")
node.compile("app_other.lua")
rtcmem.write32(30,0,0,0,0,0,0,0)
end

--strip all the iotmanager stuff out.  should lower mem footprint
--runapp should set install=nil
--read setpoint(plus crc or something) from rtcmem
--timer in publish shouldn't need to be there. fix mqtt.
--I thnk I'm losing network because the display is so slow. display loop should be a callback and the loo should call system as needed, first and next should not be in user code.
--mqtt publish queue needs len and size exposed
--mqtt needs to publish faster than once a sec
--encoder module
--something might be leaking memory. having hard time finding when it disapears becasue of hoe each of my files defines and runs stuff. separate define from run
--looks like mqtt uses a ton of mem.  that internal queue?


