function startup()
    print('startup.')
    dofile("telnet.lua")
    require('script2')
    end
print('starting in 5 seconds. send tmr.stop(0) to abort')
tmr.alarm(0,5000,0,startup)
