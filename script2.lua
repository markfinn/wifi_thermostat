dhtpin=4

sdapin = 7
sclpin = 6
dispaddr = 0x3c

relaypin=8



function relay(state)
    gpio.write(relaypin, state and gpio.HIGH or gpio.LOW) 
end

function disptemp(t, f)
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
    
    i2c.setup(0, sdapin, sclpin, i2c.SLOW)
    disp = u8g.ssd1306_128x64_i2c(dispaddr)

    fahrenheit=true
    setpoint=(70-32)/9*5
    hysteresis=1
    
    timeouts={}

    
    
    timeoutUpdate("temp", 10)
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

         timeoutUpdate("temp", 10)
         doScreen()
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
if stat == wifi.STA_IDLE then return
elseif stat == wifi.STA_GOTIP then
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

elseif stat == wifi.STA_CONNECTING then
disp:drawXBM(x+1+4*math.floor((tmr.now()/333333)%3), y-12+9, 2, 2, "\3\3")

else
disp:drawXBM(x, y-12, 12, 12, "\240\0\156\3\6\6\243\12\152\1\6\4\96\14\152\14\0\14\96\14\96\0\0\14")
-- f000 000011110000
-- 9c03 001110011100
-- 0606 011000000110
-- f30c 110011110011
-- 9801 000110011000
-- 0604 011000000010
-- 600e 000001100111
-- 980e 000110010111
-- 000e 000000000111
-- 600e 000001100111
-- 6000 000001100000
-- 000e 000000000111
end

end

function doScreen()
    tmr.stop(2)
     local sp=disptemp(setpoint, fahrenheit).."\176"
     local curr=disptemp(temperature, fahrenheit).."\176  "..disptemp(humidity).."%"
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
    until disp:nextPage() == false
     timeoutUpdate("screen", 3)
    tmr.alarm(2, 1000, 0, doScreen) 
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
tmr.alarm(1, 333, 1, doTemp) 
tmr.alarm(2, 100, 1, function() if dispwstat ~= wifi.sta.status() or dispwstat == wifi.STA_CONNECTING then doScreen() end end ) 

--=adc.readvdd33()
--wifi.sta.connect()
--setpoint=100
