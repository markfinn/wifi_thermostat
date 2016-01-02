

all:

loadfw:


terminal:
	screen /dev/ttyUSB0 9600

flashnode: 
esptool/esptool.py  --port /dev/ttyUSB0 --baud 115200 write_flash 0 nodemcu-master-16-modules-2016-01-01-22-25-11-float.bin  --flash_mode dio --flash_size 8m
