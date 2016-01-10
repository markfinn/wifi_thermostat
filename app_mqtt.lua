devid = "thermostat_"..node.chipid()
prefix = "/IoTmanager/"..devid.."/"

mq=mqtt.Client(devid, 30)
mq:lwt(prefix.."lwt", "offline", 1, 0)
mqstat=0
mqtmrdn=-10000000
mqtmrup=-10000000


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
iotpushids={}
function mqttHandle(conn, topic, data) 
  mqtttmrsetd() 
  if topic=="/IoTmanager" and data=="HELLO" then
    mqpubiotman()
  elseif topic=="/IoTmanager/ids" then
    table.insert({tmr.now(), data})
  else
    s,l,v=string.find(topic, "/IoTmanager/thermostat_1190654/".."([^/]+)/control")
    if s then
       if v=="setpoint" then pcall(function() setsetpoint(tonumber(data)/1024*35) end) end
    end
  end
end

function mqpubstat(which, value)
    pcall(function() mq:publish(prefix..which.."/status", '{"status":"'..value..'"}',1,0) end)
end

function mqpubiotman()
    mq:publish("/IoTmanager", devid,1,0)

    mq:publish(prefix.."config",cjson.encode({
    id="0",
    page="markpage",
    descr="setpoint",
    widget="range",
    topic=prefix.."setpoint",
    badge="badge-calm",
    color="red"}),1,0)

    mq:publish(prefix.."config",cjson.encode({
    id="1",
    page="markpage",
    descr="temperature",
    widget="small-badge",
    topic=prefix.."temperature"}),1,0)

    mq:publish(prefix.."config",cjson.encode({
    id="2",
    page="markpage",
    descr="humidity",
    widget="small-badge",
    topic=prefix.."humidity"}),1,0)
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
                        mqpubiotman()
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
    
    dispUpdateNeeded=dispUpdateNeeded or screenData.mqstat ~= mqstat
    screenData.mqstat = mqstat
end

tmr.alarm(3, 1000, 1, doManageMqtt) 
