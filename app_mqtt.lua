devid = "thermostat_"..node.chipid()
prefix = "/IoTmanager/"..devid.."/"


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

function mqttHandle(conn, topic, data) 
  print(topic .. ":" ) 
  if data ~= nil then
    print(data)
  end
  mqtttmrsetd() 
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

