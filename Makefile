

all:

loadfw:


terminal:
	screen /dev/ttyUSB0 9600

flashnode: 
	esptool/esptool.py  --port /dev/ttyUSB0 --baud 115200 write_flash 0 nodemcu/nodemcu-float.bin  --flash_mode dio --flash_size 8m
