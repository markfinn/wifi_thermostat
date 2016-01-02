sdapin = 7
sclpin = 6
dispaddr = 0x3c

i2c.setup(0, sdapin, sclpin, i2c.SLOW)
disp = u8g.ssd1306_128x64_i2c(dispaddr)
disp:firstPage()
disp:setFont(u8g.font_6x10)
disp:drawStr(0,0,"hi")
disp:nextPage()
