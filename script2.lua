dhtpin=3 --gpio0

encsw=4 --gpio2
encqa=2 --gpio4
encqb=1 --gpio5

sdapin = 6  --gpio12
sclpin = 7 --gpio13
dispaddr = 0x3c

relaypin=8 --gpio15

devid = "thermostat_"..node.chipid()
prefix = "/IoTmanager/"..devid.."/"


function relay(state)
    gpio.write(relaypin, state and gpio.HIGH or gpio.LOW) 
end

function convtemp(t, f)
    if not t then
        return "XX"
    elseif f then
        t=t*9/5+32
     end
     return string.format("%3d", t+.5)
end



function setup()
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
    setpoint=(70-32)/9*5
    hysteresis=1
    
    timeouts={}

    mq=mqtt.Client(devid, 30)
    mq:lwt(prefix.."lwt", "offline", 1, 0)
    mqstat=0
    mqtmrdn=-10000000
    mqtmrup=-10000000

    screenData={}

    timeoutUpdate("temp", 10)
    timeoutUpdate("screen", 10)
end

function mqtttmrsetd() 
  mqtmrdn=tmr.now()
  dispUpdateNeeded=dispUpdateNeeded or not screenData.mqstatd 
  screenData.mqstatd = true
end
function mqtttmrsetu() 
  mqtmrup=tmr.now()
  dispUpdateNeeded=dispUpdateNeeded or not screenData.mqstatu 
  screenData.mqstatu = true
end

function mqttHandle(conn, topic, data) 
  print(topic .. ":" ) 
  if data ~= nil then
    print(data)
  end
  mqtttmrsetd() 
end

function doManageMqtt()

    if mqstat~=5 and wifi.sta.status() == wifi.STA_GOTIP then
        if not pcall(function()
            if mqstat > 1 then
                mq:close()
                mqstat=1
                tmr.alarm(3, 2000, 1, doManageMqtt) 
                return
            end
            mq:on("offline", function(con) 
                mqstat=1 
                mq:close()
		dispUpdateNeeded=true
                tmr.alarm(3, 2000, 1, doManageMqtt) 
            end)
            mq:on("message", mqttHandle)
            mqstat=2
            mqtttmrsetu() 
            mq:connect("192.168.13.3", 1883, 0, function(conn) 
                mqstat=3
                mqtttmrsetu() 
                mqtttmrsetd() 
                tmr.alarm(3, 2000, 1, doManageMqtt) 
                mq:subscribe(prefix.."#",1, function(conn) 
                    mqstat=4
                    mqtttmrsetu() 
                    mqtttmrsetd() 
                    tmr.alarm(3, 2000, 1, doManageMqtt) 
                    mq:subscribe("/IoTmanager",1, function(conn) 
                        mqstat=5
                        mqtttmrsetd() 
              		dispUpdateNeeded=true
                        tmr.alarm(3, 15000, 1, doManageMqtt) 
                    end) 
                end) 
            end)
        end) then
            mqstat=1 
            mq:close()
            tmr.alarm(3, 2000, 1, doManageMqtt) 
        end
    end
end

function timeoutUpdate(s, delay)
    timeouts[s]=tmr.now()/1000000+delay
end

function doTemp()
    local status,temp,humi=dht.readxx(dhtpin)
    if status == dht.OK then
         temperature=temp
         humidity=humi

         if gpio.read(relaypin)==1 and temp > setpoint+hysteresis then
           relay(false)
         elseif gpio.read(relaypin)==0 and temp < setpoint-hysteresis then
           relay(true)
         end

         dispUpdateNeeded=dispUpdateNeeded or temp~= screenData.temp or humi~= screenData.humi 
         screenData.temp = temp
         screenData.humi = humi
         timeoutUpdate("temp", 10)
    end
end

function iconHeat(x,y)
disp:drawXBM(x, y-12, 12, 12, "\68\4\238\14\68\4\34\2\34\2\34\2\68\4\136\8\136\8\136\8\68\4\68\4")
-- 4404 001000100010
-- ee0e 011101110111
-- 4404 001000100010
-- 2202 010001000100
-- 2202 010001000100
-- 2202 010001000100
-- 4404 001000100010
-- 8808 000100010001
-- 8808 000100010001
-- 8808 000100010001
-- 4404 001000100010
-- 4404 001000100010
end

function iconWifi(x,y, stat)
if stat == wifi.STA_IDLE then
	return

elseif stat == wifi.STA_CONNECTING then
	disp:drawXBM(x+1+4*math.floor((tmr.now()/333333)%3), y-12+9, 2, 2, "\3\3")

else
	disp:drawXBM(x, y-12, 12, 11, "\240\0\156\3\6\6\243\12\152\1\6\6\96\0\152\1\0\0\96\0\96\0")
	-- f000 000011110000
	-- 9c03 001110011100
	-- 0606 011000000110
	-- f30c 110011110011
	-- 9801 000110011000
	-- 0606 011000000110
	-- 6000 000001100000
	-- 9801 000110011000
	-- 0000 000000000000
	-- 6000 000001100000
	-- 6000 000001100000

	if stat ~= wifi.STA_GOTIP then
		disp:drawXBM(x+8, y-12+5, 4, 7, "\4\14\14\14\14\0\14")
		-- 04 0010
		-- 0e 0111
		-- 0e 0111
		-- 0e 0111
		-- 0e 0111
		-- 00 0000
		-- 0e 0111
	end
end

function iconMqtt(x,y, stat, u, d)
	if stat==5 then
		disp:drawXBM(x, y-12, 12, 8, "\254\3\255\7\3\6\3\6\3\6\3\6\254\3\255\7")
	-- fe03 011111111100
	-- ff07 111111111110
        -- 0306 110000000110
        -- 0306 110000000110
        -- 0306 110000000110
        -- 0306 110000000110
        -- ff07 111111111110
        -- fe03 011111111100
	end
    if u then
        disp:drawXBM(x, y-12+8, 5, 3, "\4\14\31")
    -- 04 00100 0111110
    -- 0e 01110 0011100
    -- 1f 11111 0001000
    end
    if d then
        disp:drawXBM(x+5, y-12+8, 7, 3, "\227\192\128")
    -- e3 00100 0111110
    -- c0 01110 0011100
    -- 80 11111 0001000
    end
end


end
here
function doScreen()
     local sp=convtemp(screenData.setpoint, fahrenheit).."\176"
     local curr=convtemp(screenData.temp, fahrenheit).."\176  "..convtemp(humidity).."%"
     disp:setFont(u8g.font_fub30)
     local spw = disp:getStrWidth(sp)
     disp:setFont(u8g.font_9x15)
     local currw = disp:getStrWidth(curr)

    disp:firstPage()
    repeat
         disp:setFont(u8g.font_9x15)
         disp:drawStr((disp:getWidth()-currw)/2, 10, curr)
         disp:setFont(u8g.font_fub30)
         disp:drawStr((disp:getWidth()-spw)/2, 50, sp)
         if gpio.read(relaypin)~=0 then
           iconHeat(0,disp:getHeight())
         end
         dispwstat = wifi.sta.status()
         iconWifi(disp:getWidth()-12,disp:getHeight(), dispwstat)
         dispmqstat = mqstat
         iconMqtt(disp:getWidth()-12-12,disp:getHeight(), dispmqstat, mqstatu, mqstatd)

    until disp:nextPage() == false
     timeoutUpdate("screen", 10)
     disptime=tmr.now()
end


function doWdt()
      local now=tmr.now()/1000000
      for k,v in pairs(timeouts) do
        if v < now then
          print('timeout '..k)
          relay(false)
          node.restart()
          while true do end
          return
        end
      end
      tmr.wdclr()
end

setup()
doScreen()
tmr.alarm(0, 400, 1, doWdt) 
tmr.alarm(1, 1000, 1, doTemp) 
tmr.alarm(2, 100, 1, function() 
	newmqstatd = tmr.now() - mqtmrdn < 1000000
	newmqstatu = tmr.now() - mqtmrup < 1000000
	if tmr.now() - disptime > 1000000
	or disptemp ~= temp
    or disphumidity ~= humidity
    or dispsetpoint ~= setpoint
	or dispwstat ~= wifi.sta.status() 
	or dispwstat == wifi.STA_CONNECTING
	or dispmqstat ~= mqstat
	or newmqstatd ~= mqstatd  
	or newmqstatu ~= mqstatu  
	then 
        print("here")
		mqstatd = newmqstatd  
		mqstatu = newmqstatu  
        disptemp = temp
        disphumidity = humidity
        dispsetpoint = setpoint
		doScreen() 
	end 
end ) 
tmr.alarm(3, 1000, 1, doManageMqtt) 


--=adc.readvdd33()
--wifi.sta.connect()
--setpoint=100
