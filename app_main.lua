

function setup()
    screenData={}

    gpio.mode(relaypin, gpio.OUTPUT)
    relay(false)
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
    setsetpoint((70-32)/9*5)
    hysteresis=1
    
    timeouts={}

    mq=mqtt.Client(devid, 30)
    mq:lwt(prefix.."lwt", "offline", 1, 0)
    mqstat=0
    mqtmrdn=-10000000
    mqtmrup=-10000000


    timeoutUpdate("temp", 10)
    timeoutUpdate("screen", 10)
end


function timeoutUpdate(s, delay)
    timeouts[s]=tmr.now()/1000000+delay
end


setup()

doScreen()

tmr.alarm(0, 400, 1, doWdt) 
tmr.alarm(1, 1000, 1, doTemp) 
tmr.alarm(2, 100, 1, function() 
	if dispUpdateNeeded or tmr.now() - disptime > 3100000
	then 
        print("updatescreen"..tmr.now())
		doScreen() 
        dispUpdateNeeded = false
        disptime = tmr.now()
    end 
end ) 
tmr.alarm(3, 1000, 1, doManageMqtt) 


--=adc.readvdd33()
--wifi.sta.connect()
--setpoint=100

