LUA = app_disp.lua  app_mqtt.lua   app_temp.lua \
	app_enc.lua   app_other.lua  init.lua  telnet.lua \
	app.lua       app_setup.lua \

UPLOADS = $(LUA:.lua=.lua.uploaded)

all: $(UPLOADS)

%.uploaded: %
	nodemcu-uploader/nodemcu-uploader.py --port /dev/ttyUSB0 --baud 9600 upload -f $< && touch $@

loadfw: $(LUA)
	nodemcu-uploader/nodemcu-uploader.py --port /dev/ttyUSB0 --baud 9600 file restartandstop ;\
	nodemcu-uploader/nodemcu-uploader.py --port /dev/ttyUSB0 --baud 9600 upload `python -c "import sys; print ''.join(['-f %s '%a for a in sys.argv[1:]])" $(LUA)`

format:
	nodemcu-uploader/nodemcu-uploader.py --port /dev/ttyUSB0 --baud 9600 file format

restart:
	nodemcu-uploader/nodemcu-uploader.py --port /dev/ttyUSB0 --baud 9600 file restart

restartandstop:
	nodemcu-uploader/nodemcu-uploader.py --port /dev/ttyUSB0 --baud 9600 file restartandstop



terminal:
	screen /dev/ttyUSB0 9600

flashnodedownloaded: 
	esptool/esptool.py  --port /dev/ttyUSB0 --baud 115200 write_flash 0 nodemcu/nodemcu-float.bin  --flash_mode dio --flash_size 8m
flashnodebuilt: 
	esptool/esptool.py  --port /dev/ttyUSB0 --baud 115200 write_flash 0x00000 nodemcu/0x00000.bin  0x10000 nodemcu/0x10000.bin --flash_mode dio --flash_size 8m
