

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
