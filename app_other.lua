

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

function timeoutUpdate(s, delay)
    timeouts[s]=tmr.now()/1000000+delay
end

    timeouts={}
    timeoutUpdate("temp", 10)
    timeoutUpdate("screen", 10)

tmr.alarm(0, 400, 1, doWdt) 

v1sc=0
tmr.alarm(5, 1000, 1, function()
v1m,v15m,v2h,v24h,v3d,v7d,v30d=rtcmem.read32(30,7)
v1m=v1m  *.9833333333 + (screenData.relay and 35791394 or 0)
v15m=v15m*.9988888888 + (screenData.relay and 2386093 or 0)
v2h=v2h  *.9998611111 + (screenData.relay and 298261 or 0)
v24h=v24h*.999988426 + (screenData.relay and 24855 or 0)
v3d=v3d  *.999996142 + (screenData.relay and 8285 or 0)
v7d=v7d  *.999998347 + (screenData.relay and 3550.7 or 0)
v30d=v30d*.999999614 + (screenData.relay and 828.5 or 0)
rtcmem.write32(30,v1m,v15m,v2h,v24h,v3d,v7d,v30d)
v1sc=(v1sc+1)%15
if v1sc==0 then
v1m=v1m/21474836.48
v15m=v15m/21474836.48
v2h=v2h/21474836.48
v24h=v24h/21474836.48
v3d=v3d/21474836.48
v7d=v7d/21474836.48
v30d=v30d/21474836.48

         mqpubstat("heat", cjson.encode({v1m,v15m,v2h,v24h,v3d,v7d,v30d}))
         mqpubstat("stat", cjson.encode({rtctime.get(), tmr.now(), node.heap()}))
end

end)


function dotime()
    if wifi.sta.status() ~= wifi.STA_GOTIP then
        tmr.alarm(4, 1000, 0, dotime) 
        return
    end
    pcall(function() sntp.sync('192.168.13.3')end)
    s,ss = rtctime.get()
    if s==0 then
      tmr.alarm(4, 1000, 0, dotime) 
      return
    end

    tmr.alarm(4, 1000000, 0, dotime) 
end

tmr.alarm(4, 1000, 0, dotime) 

