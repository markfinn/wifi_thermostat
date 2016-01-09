
function relay(state)
    gpio.write(relaypin, state and gpio.HIGH or gpio.LOW) 
    dispUpdateNeeded=dispUpdateNeeded or state ~= screenData.relay
end

function convtemp(t, f)
    if not t then
        return "XX"
    elseif f then
        t=t*9/5+32
     end
     return string.format("%3d", t+.5)
end

function setsetpoint(t)
           setpoint=t
         dispUpdateNeeded=dispUpdateNeeded or setpoint~= screenData.setpoint 
         screenData.setpoint = setpoint
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

         local newcurr=convtemp(temp, fahrenheit).."\176  "..convtemp(humidity).."%"

         dispUpdateNeeded=dispUpdateNeeded or newcurr~= screenData.curtemp 
         screenData.curtemp = newcurr
         timeoutUpdate("temp", 10)
    end
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

