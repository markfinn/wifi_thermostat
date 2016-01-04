function startup()
    print('startup.')
    require('script2')
    end
print('starting in 5 seconds. send tmr.stop(0) to abort')
tmr.alarm(0,5000,0,startup)

--=loadfile('script2.lc')
--node.compile('disptest.lua')
--tmr.stop(0)


    conn=net.createConnection(net.TCP, 0)
    conn:on("receive", function(conn, payload) print(payload) end )
    conn:on("disconnection", function(conn, payload) print(payload) end )
    conn:on("connection", function(c)
        conn:send("GET /thermostat/test.lua HTTP/1.1\r\nHost: sheevaplug.bluesparc.net\r\n"
            .."Connection: keep-alive\r\nAccept: */*\r\n\r\n") 
        end)
    conn:connect(80,"192.168.13.3")--"raw.githubusercontent.com")


require('Upgrader')
Upgrader.update('test.lua', 'http://192.168.13.122:8000/init.lua')
--Upgrader.updateEspClient()

=wifi.sta.status()    