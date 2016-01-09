function startup2()
    print('main startup.')
    require('app')
    end

function startup1()
    print('telnet startup.')
    require("telnet")
    telnetserver(function() tmr.stop(0) end)
    telnetserver = nil
    print('starting main in 3 seconds. send tmr.stop(0) to abort')
    tmr.alarm(0,3000,0,startup2)
    end
print('starting telnet server in 2 seconds. send tmr.stop(0) to abort')
tmr.alarm(0,2000,0,startup1)

