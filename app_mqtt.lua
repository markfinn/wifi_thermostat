devid = "thermostat_"..node.chipid()
prefix = "/"..devid.."/"

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

mqpub=nil
function mqttPublish(t,m)
	function mqttPublisher(c)
		if not mqpub or #mqpub==0 then
		  mqpub=nil

		  return
			end

      v = table.remove(mqpub,1)
	    t,m=unpack(v)
    --  print('send',t,m)
	    mq:publish(t,m,1,0,mqttPublisher)
--	    if mq:publish('/republisher/in',cjson.encode(mqpub),1,0, function () tmr.stop(6) mqttPublisher() end) then
--	      mqpub={}
  --		end
		  tmr.alarm(6,10000,0,function () mq:close() tmr.alarm(6,1000,0,function () mq:connect("192.168.13.2", 1883, true, true) end) end)
	end

  if not screenData.mqstat then return end
  if mqpub and #mqpub > 10 then return end

  if not mqpub then
    mqpub={{t,m}}
		mqttPublisher(mq)
  else
    table.insert(mqpub, {t,m})
	end
end

iotpushids={}
function mqttHandle(conn, topic, data) 
  mqtttmrsetd() 
  s,l,v=string.find(topic, prefix.."([^/]+)/control")
  if s then
     if v=="setpoint" then pcall(function() setsetpoint(tonumber(data)) end) end
  end
end

function mqpubstat(which, value)
	  local a,b,t
		a,b=rtctime.get()
		t=a+b/1000000  
    mqttPublish(prefix..which.."/status", '{"status":"'..value..'","time":"'..t..'"}')
end



function doMqttStart()
    dispUpdateNeeded=dispUpdateNeeded or screenData.mqstat
    screenData.mqstat = false
    mqpub=nil
    if wifi.sta.status() ~= wifi.STA_GOTIP then
        tmr.alarm(3, 1000, 0, doMqttStart) 
        return
    end
mq=mqtt.Client(devid, 30)
mq:lwt(prefix.."lwt", "offline", 1, 0)
    mq:on("offline", function(con) 
        dispUpdateNeeded=dispUpdateNeeded or screenData.mqstat
        screenData.mqstat = false
    end)

    mq:on("message", mqttHandle)

    mq:on("connect", function(con) 
        mqtttmrsetd() 
        mq:subscribe(prefix.."#",1, function(conn) 
            mqtttmrsetu() 
            mqtttmrsetd() 
            mqpub=nil
            dispUpdateNeeded=dispUpdateNeeded or not screenData.mqstat
            screenData.mqstat = true
            end) 
    end)

    mqtttmrsetu() 
    mq:connect("192.168.13.2", 1883, true, true)
end

doMqttStart() 

