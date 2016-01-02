dhtpin=4
sdapin = 7
sclpin = 6
relaypin=8
dispaddr = 0x3c

gpio.mode(relaypin, gpio.OUTPUT)
gpio.write(relaypin, gpio.HIGH)
gpio.write(relaypin, gpio.LOW) 


while true do
    local status,temp,humi=dht.readxx(dhtpin)
    if status == dht.OK then
        print("DHT Temperature:"..temp..";".."Humidity:"..humi)
        tmr.wdclr()
    end
end

-- reading seems delayed...


i2c.setup(0, sdapin, sclpin, i2c.SLOW)
disp = u8g.ssd1306_128x64_i2c(dispaddr)
disp:setFont(u8g.font_6x10)
disp:drawStr(0,0,"hi")
