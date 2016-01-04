devid = "thermostat_"..node.chipid()
prefix = "/IoTmanager/"..devid.."/"

mq=mqtt.Client(devid, 30)
mq:lwt(prefix.."lwt", "offline", 1, 0)
mq:on("connect", function(con) print ("connected") end)
mq:on("offline", function(con) print ("offline") end)
mq:on("message", function(conn, topic, data) 
  print(topic .. ":" ) 
  if data ~= nil then
    print(data)
  end
end)

mq:connect("192.168.13.3", 1883, 0, function(conn)     print("connected") end)

-- subscribe topic with qos = 0
mq:subscribe(prefix.."#",1, function(conn)     print("subscribe success") end)

-- publish a message with data = hello, QoS = 0, retain = 0

mq:publish(prefix.."config",cjson.encode({
id="0",
page="a",
descr="asdf",
widget="range",
topic=prefix.."setpoint",
badge="badge-calm",
min="32",
max="90",
color="red"}) 
,1,0, function(conn) 
    print("sent") 
end)

mq:publish("/IoTmanager", devid,1,0, function(conn)  print("sent") end)


--mq:publish(prefix.."setpoint/status", "500",1,1, function(conn)  print("sent") end)
