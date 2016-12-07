-- a simple telnet server
function telnetserver(cb)
    telnet_srv = net.createServer(net.TCP, 180)
    telnet_srv:listen(2323, function(socket)
        if cb then cb() end
        local fifo = {}
        local fifo_drained = true

        local function sender(c)
            if #fifo > 0 then
                c:send(table.remove(fifo, 1))
            else
                fifo_drained = true
            end
        end
    
        local function s_output(str)
            table.insert(fifo, str)
            if socket ~= nil and fifo_drained then
                fifo_drained = false
                sender(socket)
            end
        end

        node.output(s_output, 0)   -- re-direct output to function s_ouput.
    
        socket:on("receive", function(c, l)
            table.insert(fifo, l) -- local echo
            node.input(l)           -- works like pcall(loadstring(l)) but support multiple separate line
        end)
        socket:on("disconnection", function(c)
            node.output(nil)        -- un-regist the redirect output function, output goes to serial
        end)
        socket:on("sent", sender)
    
        print("Welcome to NodeMcu world.")
    end)
end
--tmr.stop(6)
--tmr.alarm(6, 60000, 1, function()
--print(math.floor(tmr.now()/1000000), temperature, humidity, setpoint)
--end)
--require("app")
--node.compile("telnet.lua")
--=node.heap()
--setsetpoint(-40)
--node.restart()

