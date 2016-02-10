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

--mqtt doer
--provisioning. continue mine, or use http module that has no file support?
--spif 0x6B000 0x7c000 -cf file.bin https://github.com/DiUS/spiffsimg
--get off republisher. use publish return code
--build iotmanager config server / republisher
--runapp should set install=nil
--read setpoint(plus crc or something) from rtcmem
--I thnk I'm losing network because the display is so slow. display loop should be a callback and the loo should call system as needed, first and next should not be in user code.
--encoder module


