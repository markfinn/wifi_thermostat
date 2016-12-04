

    screenData={}

    gpio.mode(relaypin, gpio.OUTPUT)
    gpio.write(relaypin, gpio.LOW)
    i2c.setup(0, sdapin, sclpin, i2c.SLOW)
    disp = u8g.ssd1306_128x64_i2c(dispaddr)
    rotary.setup(0,encqa,encqb,encsw)

    fahrenheit=true
    setpoint=nil
    hysteresis=1
    

 dispUpdateNeeded=true




--=adc.readvdd33()
--wifi.sta.connect()
--setpoint=100

