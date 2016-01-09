

    screenData={}

    gpio.mode(relaypin, gpio.OUTPUT)
    gpio.write(relaypin, gpio.LOW)
do
    local encastate
    local encbstate
    local encpos=0
    local function enccb(cw)
       encpos = encpos + (cw and 1 or -1)
       print(encpos)
    end

    function enccbsw(pushed)
       print(pushed)
    end

    local function xor(a,b)
    if a and b or not a and not b then return false end
    return true
    end
    
    gpio.mode(encsw, gpio.INT, gpio.PULLUP)
    gpio.trig(encsw, "both", function(level) enccbsw(level==0) end)
    gpio.mode(encqa, gpio.INT, gpio.PULLUP)
    gpio.trig(encqa, "both", function(level) level=gpio.read(encqa)==0 enccb(xor(level, encbstate)) encastate=level end) --level doesnt seem to work
    gpio.mode(encqb, gpio.INT, gpio.PULLUP)
    gpio.trig(encqb, "both", function(level) level=gpio.read(encqb)==0 enccb(not xor(encastate, level)) encbstate=level end) --level doesnt seem to work
    encastate = gpio.read(encqa)==0
    encbstate = gpio.read(encqb)==0
end
    i2c.setup(0, sdapin, sclpin, i2c.SLOW)
    disp = u8g.ssd1306_128x64_i2c(dispaddr)

    fahrenheit=true
    setpoint=nil
    hysteresis=1
    

 dispUpdateNeeded=true




--=adc.readvdd33()
--wifi.sta.connect()
--setpoint=100

