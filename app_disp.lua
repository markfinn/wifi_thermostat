function iconHeat(x,y)
disp:drawXBM(x, y-12, 12, 12, "\68\4\238\14\68\4\34\2\34\2\34\2\68\4\136\8\136\8\136\8\68\4\68\4")
-- 4404 001000100010
-- ee0e 011101110111
-- 4404 001000100010
-- 2202 010001000100
-- 2202 010001000100
-- 2202 010001000100
-- 4404 001000100010
-- 8808 000100010001
-- 8808 000100010001
-- 8808 000100010001
-- 4404 001000100010
-- 4404 001000100010
end

function iconWifi(x,y, stat)
if stat == wifi.STA_IDLE then
	return

elseif stat == wifi.STA_CONNECTING then
	disp:drawXBM(x+1+4*math.floor((tmr.now()/333333)%3), y-12+9, 2, 2, "\3\3")

else
	disp:drawXBM(x, y-12, 12, 11, "\240\0\156\3\6\6\243\12\152\1\6\6\96\0\152\1\0\0\96\0\96\0")
	-- f000 000011110000
	-- 9c03 001110011100
	-- 0606 011000000110
	-- f30c 110011110011
	-- 9801 000110011000
	-- 0606 011000000110
	-- 6000 000001100000
	-- 9801 000110011000
	-- 0000 000000000000
	-- 6000 000001100000
	-- 6000 000001100000

	if stat ~= wifi.STA_GOTIP then
		disp:drawXBM(x+8, y-12+5, 4, 7, "\4\14\14\14\14\0\14")
		-- 04 0010
		-- 0e 0111
		-- 0e 0111
		-- 0e 0111
		-- 0e 0111
		-- 00 0000
		-- 0e 0111
	end
end

function iconMqtt(x,y, stat, u, d)
	if stat then
		disp:drawXBM(x, y-12, 12, 8, "\254\3\255\7\3\6\3\6\3\6\3\6\254\3\255\7")
	-- fe03 011111111100
	-- ff07 111111111110
        -- 0306 110000000110
        -- 0306 110000000110
        -- 0306 110000000110
        -- 0306 110000000110
        -- ff07 111111111110
        -- fe03 011111111100
	end
    if u then
        disp:drawXBM(x, y-12+8, 5, 3, "\4\14\31")
    -- 04 00100 0111110
    -- 0e 01110 0011100
    -- 1f 11111 0001000
    end
    if d then
        disp:drawXBM(x+5, y-12+8, 7, 3, "\62\28\8")
    -- 3e 00100 0111110
    -- 1c 01110 0011100
    -- 08 11111 0001000
    end
end


end

function doScreen()
     local sp=convtemp(screenData.setpoint, fahrenheit).."\176"
     local curr=screenData.curtemp or ""
     disp:setFont(u8g.font_fub30)
     local spw = disp:getStrWidth(sp)
     disp:setFont(u8g.font_9x15)
     local currw = disp:getStrWidth(curr)

    disp:firstPage()
    repeat
         disp:setFont(u8g.font_9x15)
         disp:drawStr((disp:getWidth()-currw)/2, 10, curr)
         disp:setFont(u8g.font_fub30)
         disp:drawStr((disp:getWidth()-spw)/2, 50, sp)
         if screenData.relay then
           iconHeat(0,disp:getHeight())
         end
         iconWifi(disp:getWidth()-12,disp:getHeight(), screenData.wstat)
         iconMqtt(disp:getWidth()-12-12,disp:getHeight(), screenData.mqstat, screenData.mqstatu, screenData.mqstatd)

    until disp:nextPage() == false
     timeoutUpdate("screen", 10)
end


function maybedisp()
    local nwstat = wifi.sta.status()
    dispUpdateNeeded=dispUpdateNeeded or nwstat ~= screenData.wstat 
    screenData.wstat = nwstat

  local xd=tmr.now() - mqtmrdn < 2000000
  local xu=tmr.now() - mqtmrup < 2000000
  dispUpdateNeeded=dispUpdateNeeded or xd ~= screenData.mqstatd or xu ~= screenData.mqstatu 
  screenData.mqstatd = xd
  screenData.mqstatu = xu

    
    if dispUpdateNeeded or tmr.now() - disptime > 3100000
    then 
        doScreen() 
        dispUpdateNeeded = false
        disptime = tmr.now()
    end 
end ) 

tmr.alarm(2, 100, 1, maybedisp)

